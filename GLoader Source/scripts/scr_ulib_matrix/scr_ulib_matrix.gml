
// TODO:: add more fun functions like transpose, inverse etc...

///@func matrix_print_pretty(matrix, min_int, min_dec)
function matrix_print_pretty(_m, _i = 1, _d = 2) {
	static pad = function(n, i, d) {
		return string_replace_all(string_format(n, i, d), " ", "0")
	}
	
	var _str = "";
	for (var i = 0; i < 16; i++) {
		_str += pad(_m[i], _i, _d);
		if (i < 16) _str += ", ";
		if (i mod 4 == 3) _str += "\n";
	}
	
	return _str
}



function matrix_set_world(_x, _y, _z, _xrot = 0, _yrot = 0, _zrot = 0, _xscal = 1, _yscal = 1, _zscal = 1) {
	matrix_set(matrix_world, matrix_build(_x, _y, _z, _xrot, _yrot, _zrot, _xscal, _yscal, _zscal))
}


function matrix_reset() {
	static identity = matrix_build_identity()
	matrix_set(matrix_world, identity)
}
	
function matrix_build_srt(_x, _y, _z, _xrot, _yrot, _zrot, _xscale, _yscale, _zscale) {
	
	var _mat_t = matrix_build(_x, _y, _z,	0, 0, 0,				1, 1, 1);
	var _mat_r = matrix_build(0, 0, 0,		_xrot, _yrot, _zrot,	1, 1, 1);
	var _mat_s = matrix_build(0, 0, 0,		0, 0, 0,				_xscale, _yscale, _zscale);
	
	var _mat_rs = matrix_multiply(_mat_s, _mat_r)
	var _mat_srt = matrix_multiply(_mat_rs, _mat_t)
	return _mat_srt;
}

function matrix_transform_vertex_array(_mat, _array) {
	if (array_length(_array) < 4) {
		var _w = 1
	} else {
		var _w = _array[3]
	}
	return matrix_transform_vertex(_mat, _array[0], _array[1], _array[2], _w)
}