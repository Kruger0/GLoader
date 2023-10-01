

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
	
	vec4 base_color		= texture2D(gm_BaseTexture, uv);
	vec4 normal			= texture2D(u_tex_normal, uv);
	vec4 metal_rough	= texture2D(u_tex_metal_rough, uv);
	vec4 emissive		= texture2D(u_tex_emissive, uv);
	vec4 occlusion		= texture2D(u_tex_occlusion, uv);
	
	vec4 final_col = base_color * u_matl_color * v_vColour;
	
	vec3 light_dir = normalize(vec3(1.0));
	vec3 light_col = vec3(1.0);
	vec3 amb_col = vec3(0.1);
	
	vec3 v_normal = normalize(v_vNormal);
	float NdotL = max(0.1, dot(light_dir, v_normal));
	vec3 col = light_col * NdotL;
	final_col.rgb = final_col.rgb * col;
	
	//final_col.rgb = metrough.rgb;
	//final_col.rgb = vec3(uv, 0.0);
	final_col += emissive;
	final_col.rgb *= occlusion.r;
	//final_col = vec4(1.0);
	//final_col.rgb = vec3(metrough.b);
	//final_col.rgb = cnormal.rgb;
	//final_col.a = 1.0;
	
    gl_FragColor = final_col;
}
