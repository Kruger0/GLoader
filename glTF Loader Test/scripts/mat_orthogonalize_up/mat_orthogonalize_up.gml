/// @description mat_orthogonalize_up(Matrix)
/// @param 4x4matrix
function mat_orthogonalize_up(argument0) {
	//Orthogonalizes and normalizes a given matrix
	/*
	Script made by TheSnidr

	www.thesnidr.com
	*/
	gml_pragma("forceinline");
	var M = argument0, vTo, vSi, vUp;
	vUp = vector_normalize([M[8], M[9], M[10]]);
	M[@ 8] = vUp[0];
	M[@ 9] = vUp[1];
	M[@ 10] = vUp[2];
	M[@ 11] = 0;

	vTo = vector_normalize(vector_orthogonalize([M[8], M[9], M[10]], [M[0], M[1], M[2]]));
	M[@ 0] = vTo[0];
	M[@ 1] = vTo[1];
	M[@ 2] = vTo[2];
	M[@ 3] = 0;

	vSi = vector_normalize(vector_cross([M[8], M[9], M[10]], [M[0], M[1], M[2]]));
	M[@ 4] = vSi[0];
	M[@ 5] = vSi[1];
	M[@ 6] = vSi[2];
	M[@ 7] = 0;
	M[@ 15] = 1;

	return M;


}
