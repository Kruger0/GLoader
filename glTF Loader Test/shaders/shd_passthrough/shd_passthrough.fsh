
// Attribures
varying vec2		v_vTexcoord;
varying vec4		v_vColour;
varying vec3		v_vNormal;
					
// Reflection		
varying vec3		v_EyeDir;
					
uniform vec4		u_matl_color;
uniform vec3		u_eye_pos;

// Material
uniform sampler2D	u_tex_metal_rough;
uniform sampler2D	u_tex_normal;
uniform sampler2D	u_tex_emissive;
uniform sampler2D	u_tex_occlusion;

// Enviroment
uniform sampler2D	u_tex_enviroment;

mediump vec2 octahedralProjection(mediump vec3 dir) {
	dir/= dot(vec3(1.0), abs(dir));
	mediump vec2 rev = abs(dir.zx) - vec2(1.0,1.0);
	mediump vec2 neg = vec2(dir.x < 0.0 ? rev.x : -rev.x,
	dir.z < 0.0 ? rev.y : -rev.y);
	mediump vec2 uv = dir.y < 0.0 ? neg : dir.xz;
	return 0.5*uv + vec2(0.5,0.5);
}

mat3 getTBN(vec3 normal, vec3 eye, vec2 uv) {
    // get edge vectors of the pixel triangle
    vec3 dp1 = dFdx(eye);
    vec3 dp2 = dFdy(eye);
    vec2 duv1 = dFdx(uv);
    vec2 duv2 = dFdy(uv);
    
    // solve the linear system
    vec3 dp2perp = cross(dp2, normal);
    vec3 dp1perp = cross(normal, dp1);
    vec3 tangent = dp2perp * duv1.x + dp1perp * duv2.x;
    vec3 bitangent = dp2perp * duv1.y + dp1perp * duv2.y;
    
    // construct a scale-invariant frame 
    float invmax = 1.0 / sqrt(max(dot(tangent, tangent), dot(bitangent, bitangent)));
    return mat3(normalize(tangent * invmax), normalize(bitangent * invmax), normal);
}


void main() {
	vec2 uv = vec2(v_vTexcoord);
	
	vec4 base_color		= texture2D(gm_BaseTexture, uv);
	vec3 normal			= texture2D(u_tex_normal, uv).xyz*2.0-1.0;
	vec4 metal_rough	= texture2D(u_tex_metal_rough, uv);
	vec4 emissive		= texture2D(u_tex_emissive, uv);
	vec4 occlusion		= texture2D(u_tex_occlusion, uv);
	
	// Normal map
	mat3 TBN = getTBN(normalize(v_vNormal), normalize(v_EyeDir), uv);
	normal = normalize(TBN * normal.rgb);	
	
	// Compose base + factor + vertex
	vec4 final_col = base_color * u_matl_color * v_vColour;
	
	// Metalic Roughness
	vec3 reflection = reflect(v_EyeDir, normal);
	vec2 uv_oct = octahedralProjection(reflection.xzy);
	vec3 col_enviroment = texture2D(u_tex_enviroment, uv_oct).rgb;
	final_col.rgb = mix(final_col.rgb, mix(col_enviroment, vec3(0.7), metal_rough.g), metal_rough.b*0.7);
		
	// Basic directional lighing
	vec3 light_dir = normalize(vec3(-1.0, 1.0, 1.0));
	vec3 light_col = vec3(1.0);
	vec3 amb_col = vec3(0.4);
	vec3 v_normal = normalize(v_vNormal);
	float NdotL = max(0.1, dot(light_dir, normal));
	vec3 col = (light_col * NdotL) + amb_col;
	final_col.rgb = final_col.rgb * col;
	
	// Occlude
	final_col.rgb *= occlusion.r;
	
	// Emissive
	final_col += emissive;
	
	//final_col.rgb = normal;
    gl_FragColor = final_col;
}
