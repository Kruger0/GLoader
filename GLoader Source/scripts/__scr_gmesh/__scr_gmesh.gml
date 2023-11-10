
// Group of primitives, matrices and materials
function GMesh(_model = undefined) constructor {
	name				= "gmesh";
	model				= _model;
	primitives			= [];
	mesh_index			= undefined;
	is_static			= false;

	test_0				= true;
	test_1				= true;
	test_2				= true;
	//test_3				= true;
	//test_4				= true;
	//test_5				= true;
	//test_6				= true;
	//test_7				= true;

	world_matrix		= matrix_get(matrix_world)
	final_matrix		= matrix_build_identity()
	model_matrix		= matrix_build_identity()
	tinv_model_matrix	= matrix_build_identity()
	transform_matrix	= matrix_build_identity()
	
	static Freeze = function() {
		for (var i = array_length(primitives) - 1; i >= 0; --i)	{
			primitives[i].Freeze();
		}
		return self;
	}
	
	static Submit = function() {
		static _u_inv_model_mat	= shader_get_uniform(__shd_passthrough, "u_inv_model_mat");

		//if (is_static) {
		//	if !(matrix_updated) {
		//		//world_matrix		= matrix_get(matrix_world)
		//		//final_matrix		= matrix_multiply(model_matrix, world_matrix);
		//		//tinv_model_matrix	= mat_transpose(mat_invert(final_matrix));
		//		//matrix_updated = true
		//	}
		//} else {
			
		//}
		
		world_matrix		= matrix_get(matrix_world)
		final_matrix		= matrix_multiply(model_matrix, world_matrix);
		tinv_model_matrix	= mat_transpose(mat_invert(final_matrix));
		
		shader_set_uniform_f_array(_u_inv_model_mat, tinv_model_matrix);
		
		matrix_set(matrix_world, final_matrix);
		for (var i = array_length(primitives) - 1; i >= 0; --i)	{
			primitives[i].Submit();
		}
		matrix_set(matrix_world, world_matrix)
		
		return self;
	}
	
	static Render = function() {
		
	}
	
	static Delete = function() {
		if (vbuffer != undefined) {
			vertex_delete_buffer(vbuffer);
		}
	}
}