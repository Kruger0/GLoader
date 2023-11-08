

// Attributes
attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord0;
//attribute vec4 in_TextureCoord1; // bone weights
//attribute vec4 in_TextureCoord2; // bone indices

uniform mat4 u_inv_model_mat;


varying vec3 v_normal;
varying vec4 v_colour;
varying vec2 v_texcoord;
varying vec3 v_view_dir;


void main() {
	vec4 world_pos	= gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0);
    vec4 view_pos	= gm_Matrices[MATRIX_VIEW] * world_pos;
	vec3 normal		= vec4(u_inv_model_mat * vec4(-in_Normal, 0.0)).xyz;
	vec3 view_dir	= -(gm_Matrices[MATRIX_VIEW][3] * gm_Matrices[MATRIX_VIEW]).xyz; // TODO: pass as uniform to avoid interpolation

	gl_Position		= gm_Matrices[MATRIX_PROJECTION] * view_pos;
	v_normal		= normal;
	v_colour		= in_Colour;
	v_texcoord		= in_TextureCoord0;
	v_view_dir		= world_pos.xyz - view_dir;
}
