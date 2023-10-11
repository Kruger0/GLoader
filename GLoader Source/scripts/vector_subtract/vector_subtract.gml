/// @description vector_subtract(u[3], v[3])
/// @param u[3]
/// @param v[3]
function vector_subtract(argument0, argument1) {
	gml_pragma("forceinline");
	var u = argument0;
	var v = argument1;
	return [u[0] - v[0], u[1] - v[1], u[2] - v[2]];


}
