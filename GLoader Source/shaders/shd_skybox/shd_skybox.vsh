
attribute vec3 in_Position;   

varying vec3 v_view_dir;

void main() {
	mat4 view_mat	= gm_Matrices[MATRIX_VIEW];
	vec3 view_dir	= -(view_mat[3] * view_mat).xyz;
	vec4 world_pos	= gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0) + vec4(view_dir, 0.0);
	vec4 view_pos	= view_mat * world_pos;
	gl_Position		= (gm_Matrices[MATRIX_PROJECTION] * view_pos).xyww; // Give a depth of 1.0 for the sky
	v_view_dir		= world_pos.xyz - view_dir;
}
