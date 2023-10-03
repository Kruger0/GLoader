

attribute vec3 in_Position;               
attribute vec3 in_Normal;                 
attribute vec4 in_Colour;                 
attribute vec2 in_TextureCoord;  

uniform mat4 u_inv_model_mat;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;

void main() {
    vec4 object_space_pos = vec4(in_Position, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	
	vec3 Normal = vec4(u_inv_model_mat * vec4(-in_Normal, 0.0)).xyz;
    
	v_vColour	= in_Colour;
	v_vNormal	= Normal;
	v_vTexcoord	= in_TextureCoord;
}
