/// @description vector_lerp(u[3], v[3], amount)
/// @param u[3]
/// @param v[3]
/// @param amount
function vector_lerp(argument0, argument1, argument2) {
	var u = argument0;
	var v = argument1;
	var t = argument2;
	return [lerp(u[0], v[0], t), lerp(u[1], v[1], t), lerp(u[2], v[2], t)];


}
