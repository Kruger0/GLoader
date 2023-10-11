/// @description mat_create_up(x, y, z, to[3], up[3])
/// @param x
/// @param y
/// @param z
/// @param to[3]
/// @param up[3]
function mat_create_up(argument0, argument1, argument2, argument3, argument4) {
	//Creates a 4x4 matrix with the up-direction as master
	/*
	Script made by TheSnidr

	www.thesnidr.com
	*/
	gml_pragma("forceinline");
	var vTo, vUp, vSi;
	vUp = vector_normalize(argument4);
	vTo = vector_normalize(vector_orthogonalize(vUp, argument3));
	vSi = vector_normalize(vector_cross(vUp, vTo));
	return [vTo[0], vTo[1], vTo[2], 0,
			vSi[0], vSi[1], vSi[2], 0,
			vUp[0], vUp[1], vUp[2], 0,
			argument0, argument1, argument2, 1];


}
