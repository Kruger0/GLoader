

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;


void main() {
	vec2 uv = vec2(v_vTexcoord);
	vec4 fragcol = texture2D(gm_BaseTexture, uv);
	
	vec3 light_dir = normalize(vec3(1.0));
	vec3 light_col = vec3(1.0);
	vec3 amb_col = vec3(0.1);
	
	vec3 normal = normalize(v_vNormal);
	float NdotL = max(0.1, dot(light_dir, normal));
	vec3 col = light_col * NdotL;
	fragcol.rgb = fragcol.rgb * col;
	
	//fragcol.rgb = vec3(uv, 0.0);
	
    gl_FragColor = v_vColour * fragcol;
}
