
// Group of vertex buffers
function GPrimitive(_mesh = undefined) constructor {
	mesh				= _mesh
	vbuffer				= undefined;
	material			= undefined
	
	final_matrix		= matrix_build_identity()
	model_matrix		= matrix_build_identity()
	tinv_model_matrix	= matrix_build_identity()
	transform_matrix	= matrix_build_identity()
	
	static Submit = function() {
		static _tex_white			= sprite_get_texture(spr_white, 0);
		
		static _tex_metal_rough		= sprite_get_texture(spr_metal_rough, 0);
		static _tex_normal			= sprite_get_texture(spr_normal, 0);
		static _tex_emissive		= sprite_get_texture(spr_emissive, 0);
		static _tex_occlusion		= sprite_get_texture(spr_occlusion, 0);
		
		static _u_tex_metal_rough	= shader_get_sampler_index(shd_passthrough, "u_tex_metal_rough");
		static _u_tex_normal		= shader_get_sampler_index(shd_passthrough, "u_tex_normal");
		static _u_tex_emissive		= shader_get_sampler_index(shd_passthrough, "u_tex_emissive");
		static _u_tex_occlusion		= shader_get_sampler_index(shd_passthrough, "u_tex_occlusion");
		
		static _u_base_color_fac	= shader_get_uniform(shd_passthrough, "u_matl_color");
		static _u_matl_met_rou_cut	= shader_get_uniform(shd_passthrough, "u_matl_met_rou_cut");
		
		if (vbuffer != undefined) {
			var _shader			= shader_current();
			
			var _base_color_tex		= pointer_null;
			var _metal_rough_tex	= pointer_null;
			var _normal_tex			= pointer_null;
			var _emissive_tex		= pointer_null;
			var _occlusion_tex		= pointer_null;
			
			var _base_color_fac		= [1, 1, 1, 1];
			var _metal_fac			= 1;
			var _rough_fac			= 0;
			var _cutoff				= 0.5;
			

			// Search for material data
			if (material != undefined) {
				with (mesh.model.materials[$ material]) {
					_base_color_tex		= base_color_tex;
					_metal_rough_tex	= metal_rough_tex;
					_normal_tex			= normal_tex;
					_emissive_tex		= emissive_tex;
					_occlusion_tex		= occlusion_tex;
					
					_base_color_fac		= base_color_fac;
					_metal_fac			= metal_fac
					_rough_fac			= rough_fac
					_cutoff				= alpha_cutoff
				}
			}
			
			//show_debug_message(material)
			//show_debug_message(_metal_fac)
			//show_debug_message(_rough_fac)
			
			// If data does not exists, use default values
			_base_color_tex		??= _tex_white;
			_metal_rough_tex	??= _tex_metal_rough;
			_normal_tex			??= _tex_normal;
			_emissive_tex		??= _tex_emissive;
			_occlusion_tex		??= _tex_occlusion;

			// Send textures
			texture_set_stage(_u_tex_metal_rough, _metal_rough_tex);
			texture_set_stage(_u_tex_normal, _normal_tex);
			texture_set_stage(_u_tex_emissive, _emissive_tex);
			texture_set_stage(_u_tex_occlusion, _occlusion_tex);
			
			// Send material factors
			shader_set_uniform_f_array(_u_base_color_fac, _base_color_fac);
			shader_set_uniform_f_array(_u_matl_met_rou_cut, [_metal_fac, _rough_fac, _cutoff]);
			
			// Submit mesh
			vertex_submit(vbuffer, pr_trianglelist, _base_color_tex);
		}
		return self;
	}
	
	static Freeze = function() {
		if (vbuffer != undefined) {
			vertex_freeze(vbuffer)
		}
	}
	
	static Delete = function() {
		if (vbuffer != undefined) {
			vertex_delete_buffer(vbuffer);
		}
	}
}