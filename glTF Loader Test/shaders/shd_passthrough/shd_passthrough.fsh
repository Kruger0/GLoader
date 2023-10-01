

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;

uniform vec4	u_matl_color;

uniform sampler2D u_tex_metal_rough;
uniform sampler2D u_tex_normal;
uniform sampler2D u_tex_emissive;
uniform sampler2D u_tex_occlusion;


void main() {
	vec2 uv = vec2(v_vTexcoord);
	vec4 fragcol = texture2D(gm_BaseTexture, uv) * u_matl_color * v_vColour;
	vec4 cnormal = texture2D(u_tex_normal, uv);
	vec4 metrough	= texture2D(u_tex_metal_rough, uv);
	vec4 emissive	= texture2D(u_tex_emissive, uv);
	vec4 occlusion	= texture2D(u_tex_occlusion, uv);
	
	vec3 light_dir = normalize(vec3(1.0));
	vec3 light_col = vec3(1.0);
	vec3 amb_col = vec3(0.1);
	
	vec3 normal = normalize(v_vNormal);
	float NdotL = max(0.1, dot(light_dir, normal));
	vec3 col = light_col * NdotL;
	fragcol.rgb = fragcol.rgb * col;
	
	//fragcol.rgb = metrough.rgb;
	//fragcol.rgb = vec3(uv, 0.0);
	fragcol += emissive;
	fragcol.rgb *= occlusion.r;
	//fragcol.rgb = vec3(metrough.b);
	//fragcol.rgb = cnormal.rgb;
	//fragcol.a = 1.0;
	
    gl_FragColor = fragcol;
}
