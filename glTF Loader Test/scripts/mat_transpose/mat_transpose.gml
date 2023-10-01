/// @description mat_transpose(M)
/// @param M[16]
function mat_transpose(argument0) {
	var M = argument0;
	var R = array_create(16);

	R[0] = M[0];
	R[1] = M[4];
	R[2] = M[8];
	R[3] = M[12];

	R[4] = M[1];
	R[5] = M[5];
	R[6] = M[9];
	R[7] = M[13];

	R[8] = M[2];
	R[9] = M[6];
	R[10] = M[10];
	R[11] = M[14];

	R[12] = M[3];
	R[13] = M[7];
	R[14] = M[11];
	R[15] = M[15];

	return R;


}
