
#define GAMMA		1.0

varying vec4		v_colour;
varying vec3		v_normal;
varying vec2		v_texcoord;
varying vec3		v_view_dir;
					
// Material
uniform vec4		u_matl_color;
uniform vec4		u_matl_met_rou_cut;

uniform sampler2D	u_tex_normal;
uniform sampler2D	u_tex_metal_rough;
uniform sampler2D	u_tex_occlusion;
uniform sampler2D	u_tex_emissive;

// Enviroment
uniform sampler2D	u_tex_enviroment;

#region Extra

mediump vec2 octahedralProjection(mediump vec3 dir) {
	dir = vec3(dir.x, -dir.y, dir.z);
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

#endregion

void main() {
	
	// Samplers
	vec4 base_color		= texture2D(gm_BaseTexture,		v_texcoord) * u_matl_color;
	vec3 normal			= texture2D(u_tex_normal,		v_texcoord).xyz*2.0-1.0;
	vec4 metal_rough	= texture2D(u_tex_metal_rough,	v_texcoord);
	vec4 occlusion		= texture2D(u_tex_occlusion,	v_texcoord);
	vec4 emissive		= texture2D(u_tex_emissive,		v_texcoord);
	
	
	// Extract material data
	float metal_fac	= clamp(metal_rough.b * u_matl_met_rou_cut.r, 0.0, 1.0);
	float rough_fac	= clamp(metal_rough.g * u_matl_met_rou_cut.g, 0.0, 1.0);
	float cutof_fac	= u_matl_met_rou_cut.b;
	
	
	// Math stuff
	vec3 view_dir = normalize(v_view_dir);
	
	
	// Normal map
	if (v_texcoord == vec2(0.0)) {	// TODO may there is a better way of cheching the lack of UVs in a model	
		normal = v_normal;
	} else {
		mat3 TBN = getTBN(normalize(v_normal), view_dir, v_texcoord);
		normal = (TBN * normal.rgb);	
	}
	normal = normalize(normal);
	
	
	// Compose base + factor + vertex
	vec4 final_col = base_color * v_colour;
	
	
	// Gamma encode
	final_col.rgb = pow(final_col.rgb, vec3(1.0/GAMMA));
	
	
	// Alpha cutoff
	if (final_col.a < cutof_fac) {
		discard;
	}

	
	// Metalic Roughness
	vec3 reflection = reflect(view_dir, normal);
	vec2 uv_oct = octahedralProjection(reflection.xzy);
	vec3 col_enviroment = texture2D(u_tex_enviroment, uv_oct).rgb;
	final_col.rgb = mix(final_col.rgb, mix(col_enviroment * final_col.rgb, final_col.rgb, rough_fac), metal_fac);
		
	
	// Basic directional lighing
	vec3 light_dir = normalize(vec3(-1.2, 1.3, 1.5)); // Hard-coded directional light
	vec3 light_col = vec3(1.0);
	vec3 amb_col = vec3(0.4);
	
	float NdotL = max(0.1, dot(light_dir, normal));
	vec3 col = (light_col * NdotL) + amb_col;
	final_col.rgb = final_col.rgb * col;
	
	
	// Add simple fresnel color
	float fresnel_fac = 1.0-pow(max(0.1, dot(view_dir, normal)), 0.1);
	final_col.rgb += vec3(1.0) * fresnel_fac * 1.0;
	
	
	// Occlude
	final_col.rgb *= occlusion.r;
	
	
	// Emissive
	final_col += emissive;
	
	
	// Debug
	//final_col.rgb = v_texcoord.rgg;
	//final_col.rgb = vec3(metal_fac);
	//final_col.rgb = normal;
	
	
	// Gamma decode
	final_col.rgb = pow(final_col.rgb, vec3(GAMMA));
	
	// Color output
    gl_FragColor = final_col;
}
