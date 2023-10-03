
attribute vec3 in_Position;   

varying vec3 v_EyeDir;

void main() {
	mat4 view_mat	= gm_Matrices[MATRIX_VIEW];
	vec3 eye_pos	= -(view_mat[3] * view_mat).xyz;
	vec4 world_pos	= gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0) + vec4(eye_pos, 0.0);
	vec4 view_pos	= view_mat * world_pos;
	gl_Position		= gm_Matrices[MATRIX_PROJECTION] * view_pos;
	v_EyeDir		= world_pos.xyz - eye_pos;
}
