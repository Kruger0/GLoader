/// @description vector_scale(u[3], scalar)
/// @param u[3]
/// @param scalar
function vector_scale(argument0, argument1) {
	var u = argument0;
	var scalar = argument1;
	return [u[0] * scalar, u[1] * scalar, u[2] * scalar];


}
