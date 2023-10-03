

attribute vec3 in_Position;               
attribute vec3 in_Normal;                 
attribute vec4 in_Colour;                 
attribute vec2 in_TextureCoord;  

uniform mat4 u_inv_model_mat;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;

varying vec3 v_EyeDir;


void main() {
	vec4 world_pos	= gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0);
    vec4 view_pos	= gm_Matrices[MATRIX_VIEW] * world_pos;
	gl_Position		= gm_Matrices[MATRIX_PROJECTION] * view_pos;
	
	vec3 normal = vec4(u_inv_model_mat * vec4(-in_Normal, 0.0)).xyz;
	vec3 view_dir = -(gm_Matrices[MATRIX_VIEW][3] * gm_Matrices[MATRIX_VIEW]).xyz;

	v_EyeDir	= world_pos.xyz - view_dir;
	v_vColour	= in_Colour;
	v_vNormal	= normal;
	v_vTexcoord	= in_TextureCoord;
}
