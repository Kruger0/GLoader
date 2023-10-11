/// @description mat_invert_fast(matrix)
/// @param matrix
function mat_invert_fast(argument0) {
	/*
		Inverts the given 4x4 matrix.
		Assumes M[3], M[7] and M[11] equal 0, while M[15] equals 1.
	*/

	var M = argument0;
	var inv = array_create(16);
	var inv = [
				M[5] * M[10] - M[9] * M[6],
				M[9] * M[2]  - M[1] * M[10],
				M[1] * M[6]  - M[5] * M[2],
				0,
			
				M[8] * M[6]  - M[4] * M[10],
				M[0] * M[10] - M[8] * M[2],
				M[4] * M[2]  - M[0] * M[6],
				0,
			
				M[4] * M[9]  - M[8] * M[5],
				M[8] * M[1]  - M[0] * M[9],
				M[0] * M[5]  - M[4] * M[1],
				0,
			
				M[12] * (M[6] * M[9]  - M[5] * M[10]) +
	            M[13] * (M[4] * M[10] - M[8] * M[6]) + 
	            M[14] * (M[8] * M[5]  - M[4] * M[9]),
			
	            M[12] * (M[1] * M[10] - M[2] * M[9]) +
	            M[13] * (M[8] * M[2]  - M[0] * M[10]) + 
				M[14] * (M[0] * M[9]  - M[8] * M[1]),
			
	            M[12] * (M[2] * M[5]  - M[1] * M[6]) + 
	            M[13] * (M[0] * M[6]  - M[4] * M[2]) +
				M[14] * (M[4] * M[1]  - M[0] * M[5]),
			
				1];

	var _det = M[0] * inv[0] + M[1] * inv[4] + M[2] * inv[8];
	if ( _det == 0 ) {
	    show_error( "The determinant is zero.", false );
	    return M;
	}

	_det = 1 / _det;
	for( var i = 0; i < 16; i++ ){inv[i] *= _det;}
	return inv;


}
