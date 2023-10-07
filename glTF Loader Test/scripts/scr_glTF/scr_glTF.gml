
// Gloader - glTF Loader for GameMaker


#macro __GLTF_VERSION	"0.8.6"

#region STARTUP

	#macro KEY_GLTF	0x46546C67
	#macro KEY_JSON 0x4E4F534A
	#macro KEY_BIN	0x004E4942
	#macro KEY_PNG	0x474E5089
	#macro KEY_JPG	0xE0FFD8FF

	vertex_format_begin() {
		vertex_format_add_position_3d()			// 12
		vertex_format_add_color()				// 4
		vertex_format_add_normal()				// 12
		vertex_format_add_texcoord()			// 8
		global.vformat = vertex_format_end()
	}

	global.vbuff = vertex_create_buffer()

	//0x0AA10A0D474E5089

	enum Content {
		Header,
		JSON,
		BIN,
		PNG,
		JPG
	}
	
	enum Attributes {
		NONE,
		Position,
		Normal,
		Tangent,
		TexCoord,
		Color,
		Joints,
		Weights,
		SIZE,
	}

	enum Texture {
		BaseColor,
		Normal,
		MetallicRoughness,
		Occlusion,
		Emissive,
	}
	
	enum ComponentType {
		BYTE					= 5120,	// s8
		UNSIGNED_BYTE			= 5121,	// u8
		SHORT					= 5122,	// s16
		UNSIGNED_SHORT			= 5123,	// u16
		UNSIGNED_INT			= 5125,	// u32
		FLOAT					= 5126,	// f32
	}
		
	enum BufferViewTarget {
		ARRAY_BUFFER			= 34962,
		ELEMENT_ARRAY_BUFFER	= 34963,
	}
	
	enum PrimitiveMode {
		POINTS,
		LINES,
		LINE_LOOP,
		LINE_STRIP,
		TRIANGLES,
		TRIANGLE_LIST,
		TRIANGLE_FAN,
	}

	enum MagFilter {
		NEAREST = 9728,
		LINEAR	= 9729,
	}
	
	enum MinFilter {
		NEAREST					= 9728,
		LINEAR					= 9729,
		NEAREST_MIPMAP_NEAREST	= 9984,
		LINEAR_MIPMAP_NEAREST	= 9985,
		NEAREST_MIPMAP_LINEAR	= 9986,
		LINEAR_MIPMAP_LINEAR	= 9987,
	}
	
	enum Wrap {
		CLAMP_TO_EDGE			= 33071,
		MIRRORED_REPEAT			= 33648,
		REPEAT					= 10497,
	}
	
	
#endregion


// Animation data for a model
function GAnimator() constructor {
	
}

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
			var _metal_fac			= 1
			var _rough_fac			= 0
			var _cutoff				= 0.5
			
			

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
			
			show_debug_message(material)
			show_debug_message(_metal_fac)
			show_debug_message(_rough_fac)
			
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

// Group of primitives, matrices and materials
function GMesh(_model = undefined) constructor {
	name				= "gmesh";
	model				= _model;
	primitives			= [];
	mesh_index			= undefined;
	
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
		static _u_inv_model_mat	= shader_get_uniform(shd_passthrough, "u_inv_model_mat");

		// Update matrices - TODO optmize static meshes and do some better caching
		world_matrix		= matrix_get(matrix_world)
		final_matrix		= matrix_multiply(model_matrix, world_matrix);
		tinv_model_matrix	= mat_transpose(mat_invert_fast(final_matrix));
		
		shader_set_uniform_f_array(_u_inv_model_mat, tinv_model_matrix);
		
		matrix_set(matrix_world, final_matrix);
		for (var i = array_length(primitives) - 1; i >= 0; --i)	{
			primitives[i].Submit();
		}
		matrix_set(matrix_world, world_matrix)
		
		return self;
	}
	
	static Delete = function() {
		if (vbuffer != undefined) {
			vertex_delete_buffer(vbuffer);
		}
	}
}

// Group of texture pointers
function GMaterial(_name = "gmatl") constructor {
	
	name			= _name;
	base_color_tex	= pointer_null;
	metal_rough_tex	= pointer_null;
	normal_tex		= pointer_null;
	occlusion_tex	= pointer_null;
	emissive_tex	= pointer_null;
	occlusion_tex	= pointer_null;
	
	base_color_fac	= [1, 1, 1, 1];
	metal_fac		= 1;
	rough_fac		= 1;
	emissive_fac	= [0, 0, 0];
	
	alpha_mode		= "OPAQUE";
	alpha_cutoff	= 0.5;
	double_sided	= false;
	
	static Delete = function() {
		return undefined;
	}
}

// Group of meshes
function GModel(_name = "gmodel") constructor {
	name		= _name
	is_loaded	= false;
	is_cached	= false
	meshes		= [];
	materials	= {};
	textures	= {};
	animations	= {}
	vtx_count	= 0;
	load_time	= 0
	world_matrix	= matrix_build_identity()
	
	static Load = function(_file) {
		
		static __def_col	= [1, 1, 1, 1];
		static __def_norm	= [0, 1, 1];
		static __def_uv		= [0, 0];
		
		static __load_accessor = function(_acess_index) {
			var _acess			= json_root.accessors[_acess_index];
			var _buff_view		= json_root.bufferViews[_acess.bufferView];
			var _buff_id		= json_root.buffers[_buff_view.buffer];
			
			var _type = undefined
			switch (_acess.componentType) {		
				case ComponentType.BYTE:			{ _type = buffer_s8		} break;
				case ComponentType.UNSIGNED_BYTE:	{ _type = buffer_u8		} break;
				case ComponentType.SHORT:			{ _type = buffer_s16	} break;
				case ComponentType.UNSIGNED_SHORT:	{ _type = buffer_u16	} break;
				case ComponentType.UNSIGNED_INT:	{ _type = buffer_u32	} break;
				case ComponentType.FLOAT:			{ _type = buffer_f32	} break;
			}

			var _size = undefined;
			switch (_acess.type) {
				case "SCALAR":	{ _size = 01 } break;
				case "VEC2":	{ _size = 02 } break;
				case "VEC3":	{ _size = 03 } break;
				case "VEC4":	{ _size = 04 } break;
				case "MAT2":	{ _size = 04 } break;
				case "MAT3":	{ _size = 09 } break;
				case "MAT4":	{ _size = 16 } break;
			}
			
			var _type_size		= buffer_sizeof(_type);
			var _group_size		= _size * _type_size;
			var _view_count		= _acess.count;
			var _view_offset	= _acess[$ "byteOffset"] ?? 0;
			var _buff_offset	= _buff_view[$ "byteOffset"] ?? 0; 
			var _buff_stride	= _buff_view[$ "byteStride"] ?? _group_size;
			var _buff_length	= _buff_view.byteLength;
			var _total_offset	= _view_offset + _buff_offset;
			var _byte_stride	= _buff_stride - _group_size;
			
			buffer_seek(_buff_id, buffer_seek_start, _total_offset);		
		
			var _arr = [];
			while (buffer_tell(_buff_id) != _total_offset + _buff_length) {
				if (_size > 1) {
					var _group_arr = [];
					repeat(_size) {
						// For some reason the color value goes way higher so this division fix it
						// Edit: this fix is dumb cuz there are colors in VEC3 :(
						var _color_fix = (_size == 4 && _type == buffer_u16 ? 65535 : 1)
						array_push(_group_arr, buffer_read(_buff_id, _type) / _color_fix);
					}
					
					array_push(_arr, _group_arr);
					buffer_seek(_buff_id, buffer_seek_relative, _byte_stride);
					
					//show_debug_message(_group_arr)
				} else {
					var _scale = buffer_read(_buff_id, _type)
					
					array_push(_arr, _scale);
					buffer_seek(_buff_id, buffer_seek_relative, _byte_stride);
				}
				_view_count--
				if !(_view_count) break;
				
			}	
			//show_message("Finished a reading!")
			return _arr;
		}
		
		static __get_node_matrix = function(_node) {
			static __def_scl	= [1, 1, 1];
			static __def_rot	= [0, 0, 0, 1];
			static __def_trl	= [0, 0, 0];
			var _model_matrix	= _node[$ "matrix"]
			if !(is_undefined(_model_matrix)) {
				_model_matrix = (_model_matrix) // TODO check if its necessary
			} else {
				var _trl	= _node[$ "translation"]	?? __def_trl;
				var _rot	= _node[$ "rotation"]		?? __def_rot;
				var _scl	= _node[$ "scale"]			?? __def_scl;									
												
				var _mat_t = matrix_build(				_trl[0], _trl[1], _trl[2],	0, 0, 0,		1, 1, 1);
				var _mat_r = matrix_build_quaternion(	0, 0, 0,					_rot,			1, 1, 1);
				var _mat_s = matrix_build(				0, 0, 0,					0, 0, 0,		_scl[0], _scl[1], _scl[2]);
				
				var _mat_1 = matrix_multiply(_mat_s, _mat_r)
				var _mat_2 = matrix_multiply(_mat_1, _mat_t)
				_model_matrix = _mat_2
			}
			return _model_matrix;
		}
		
		static __transform_childs = function(_nodes) {
			var _hierarchy = undefined
			//// Read and hierarchies all children's
			///*
			//8: {
			//	7: {
				
			//	},
			//	6: {
			//		5: {
					
			//		},
			//		4: {
			//			3: {
						
			//			},
			//			2: {
						
			//			},
			//			1: {
						
			//			},
			//			0: {
						
			//			},
			//		},
			//	},
			//}
			//*/
			//static __rec = function(_nodes) {
			//	var _t = {
			//	}
			//	_t[$ 8] = 4
			//	show_message(_t)
			//}
			//if (_node[$ ]
			//for (var i = array_length(_nodes)
			
			return _hierarchy
			
			// Set the matrix of each mesh before building the vbuffer
		}
		
		static __parse2json = function(_file) {
			
			var _json = undefined
			switch (filename_ext(_file)) {
				case ".glb": {
					// TODO support binary file
				} break;
			
				case ".gltf": {
					// Load base file
					var _buffer		= buffer_load(_file);
					if (_buffer == -1) show_error($"glTF error: coulnd't load file {_file}", true)
					var _string		= buffer_read(_buffer, buffer_string);
					_json			= json_parse(_string);
					buffer_delete(_buffer)
				
				
					// Load all buffers
					var _buffers = _json.buffers
					for (var i = 0; i < array_length(_buffers); i++) {
						var _buff		= undefined;
						var _buff_id	= _buffers[i];
						var _buff_uri	= _buff_id.uri;
						var _path_bin	= filename_path(_file) + _buff_uri;
				
						if (string_copy(_buff_uri, 0, 4) == "data") {
							_buff = buffer_base64_decode(string_split(_buff_uri, ",")[1]);
						} else if (file_exists(_path_bin)) {
							_buff = buffer_load(_path_bin);
						} else {
							show_error($"glTF error: can't load buffer {i} from {_file}", true);
						}

						_json[$ "buffers"][i] = _buff;
					}
				
					// Load all images
					var _imgs = _json[$ "images"] ?? []
					for (var i = 0; i < array_length(_imgs); i++) {
						var _img		= _imgs[i]
						var _img_uri	= _img[$ "uri"];
						var _spr		= undefined;
						var _path_temp	= $"img_{i}.temp"
				
						if (_img_uri == undefined) {
							var _buff_view			= _json[$ "bufferViews"][_img[$ "bufferView"]]
							var _buff_id			= _json[$ "buffers"][_buff_view[$ "buffer"]]
							var _buff_offset		= _buff_view[$ "byteOffset"]
							var _buff_length		= _buff_view[$ "byteLength"]
					
							var _buff_temp			= buffer_create(_buff_length, buffer_fixed, 1)
							buffer_copy(_buff_id, _buff_offset, _buff_length, _buff_temp, 0)
							buffer_save(_buff_temp, _path_temp)
					
							_spr = sprite_add(_path_temp, 1, false, false, 0, 0)
					
							buffer_delete(_buff_temp)
							file_delete(_path_temp)
						} else {
							var _img_path	= /*filename_path(_file) +*/ _img_uri;
							if (string_copy(_img_uri, 0, 4) == "data") {
								var _b64		= string_split(_img_uri, ",")[1]
								var _buff_temp	= buffer_base64_decode(_b64)
								buffer_save(_buff_temp, _path_temp)
						
								_spr = sprite_add(_path_temp, 1, false, false, 0, 0)
						
								buffer_delete(_buff_temp)
								file_delete(_path_temp)
							} else {
								_img_path = string_replace_all(_img_path, "%20", " ") // Names with space
								if (file_exists(_img_path)) {
									_spr = sprite_add(_img_path, 1, false, false, 0, 0);
								} else {
									_spr = spr_white
								}
						
							}
						}
						_json[$ "textures"][i] = _spr // TODO rescue sampler info on future
					}
				} break;
			}
			return _json
		}

		static __mesh_duplicate = function() {
			
		}

		//Loadtime tracing
		load_time = get_timer();
		show_debug_message("Scene load started!");
		
		// Loads data according to extension type
		json_root	= __parse2json(_file);
		
		
		// JSON and pointers are ready, proceeds to assemble scene
		var _keys = struct_get_names(json_root)
		for (var i = 0; i < array_length(_keys); i++) {
			var _key = _keys[i]
			switch (_key) {
				case "asset": {
					var _asset = json_root.asset;
				} break;
					
				case "scenes": {
						
				} break;
				
				case "nodes": {
					var _nodes = json_root.nodes;
					//__transform_childs(_nodes)
					
					// Check for childrens
					
					for (var j = array_length(_nodes); j--;) {	
						var _node		= _nodes[j];
						var _parent = _node
						if (_node[$ "children"] != undefined) {
						// Transform next nodes

							var _parent_matrix = __get_node_matrix(_node)
							
							//show_message(_parent_matrix)
							for (var l = array_length(_node.children); l--;) {
								var _child_id	= _node.children[l];
								//show_message(_child_id)
								var _child		= _nodes[_child_id]
								var _child_mat	= __get_node_matrix(_child)
								var _new_mat	= matrix_multiply(_child_mat, _parent_matrix)
								//show_message(_child_mat)
								//show_message(_new_mat)
								_child.matrix	= _new_mat
								//show_message(_child.matrix)
											
								//// Find mesh if already loaded
								//for (var m = 0; m < array_length(meshes); m++) {
								//	var _mesh_index = meshes[m].mesh_index
								//	if (_child_id == _mesh_index) {
								//		meshes[m].model_matrix = matrix_multiply(_this_mesh.model_matrix, meshes[m].model_matrix)
								//	}
								//}
							}
						}
					}
					
					
					for (var j = 0; j < array_length(_nodes); j++) {	
						var _node		= _nodes[j];
						var _node_keys	= struct_get_names(_node);
						
						
						for (var k = 0; k < array_length(_node_keys); k++) {
							var _node_key = _node_keys[k]
							
							switch (_node_key) {
								case "name": {
									var _node_name = (_node.name)
								} break;
								
								case "mesh": {
									var _mesh		= json_root.meshes[_node.mesh];
									var _mesh_keys	= struct_get_names(_mesh);
									
									// Check if mesh has already beeing builded
									if (_mesh[$ "mesh_loaded"] != undefined) {
										// Somehow dupe the mesh data
									}
									
									// Start new mesh group
									var _this_mesh				= new GMesh(self);
									_this_mesh.mesh_index		= j;
									_this_mesh.model_matrix		= __get_node_matrix(_node);
									
									//show_message(_this_mesh.mesh_index)
									
									
									
									for (var l = 0; l < array_length(_mesh_keys); l++) {
										var _mesh_key = _mesh_keys[l];
							
										switch (_mesh_key) {
											case "name": {
												_this_mesh.name = _mesh[$ "name"] ?? $"mesh_{l}";
											} break;	
											
											case "primitives": {
												var _prims = _mesh.primitives;
												
												for (var m = 0; m < array_length(_prims); m++) {
													var _prim		= _prims[m];
													var _prim_keys	= struct_get_names(_prim);
													
													// Start new primitive assembling
													var _prim_data		= [];
													var _prim_flags		= 0x00;
													var _vbuffer		= vertex_create_buffer();
													var _this_prim		= new GPrimitive(_this_mesh)
													var _matl_num		= 0
																																						
													// Get mesh data 
													for (var n = 0; n < array_length(_prim_keys); n++) {
														var _prim_key = _prim_keys[n]
														
														switch (_prim_key) {
															case "attributes": {
																var _attrib = _prim.attributes;
																var _attrib_keys = struct_get_names(_attrib)
																
																for (var o = 0; o < array_length(_attrib_keys); o++) {
																	var _attrib_key = _attrib_keys[o]
																	
																	var _data_type = Attributes.NONE;
																	switch (string_letters(_attrib_key)) {
																		case "POSITION":	{ _data_type = Attributes.Position	} break;
																		case "NORMAL":		{ _data_type = Attributes.Normal	} break
																		case "COLOR":		{ _data_type = Attributes.Color		} break;
																		case "TEXCOORD":	{ _data_type = Attributes.TexCoord	} break;
																		case "TANGENT":		{ _data_type = Attributes.Tangent	} break;
																		case "JOINTS":		{ _data_type = Attributes.Joints	} break;
																		case "WEIGHTS":		{ _data_type = Attributes.Weights	} break;
																	}
																	
																	if (_data_type != Attributes.NONE) {
																		_prim_flags = _prim_flags | 0x01 << _data_type
																		var _acess_index = _attrib[$ _attrib_key]
																		_prim_data[_data_type] = __load_accessor(_acess_index)
																	}
																}
															} break;
															
															case "indices": {
																// TODO add non-indexed geometry support
																var _vtx_id = __load_accessor(_prim.indices)
															} break;
															
															case "material": {
																
																var _matl = json_root.materials[_prim.material];
																
																// Check if material already exists
																var _matl_name	= _matl[$ "name"] ?? $"matl_{_matl_num}";
																_this_prim.material = _matl_name;
																if (!is_undefined(self.materials[$ _matl_name])) {
																	continue;
																}
																
																//show_message(_matl_name)
																
																// If not, then load a new one
																var _this_matl	= new GMaterial();		
																_this_matl.name = _matl_name;
																
																var _matl_keys = struct_get_names(_matl);
																for (var o = 0; o < array_length(_matl_keys); o++) {
																	var _matl_key = _matl_keys[o]
																	
																	switch (_matl_key) {
																		case "pbrMetallicRoughness": {
																			var _pbr = _matl.pbrMetallicRoughness;
																			var _pbr_keys = struct_get_names(_pbr)
																			for (var p = 0; p < array_length(_pbr_keys); p++) {
																				var _pbr_key = _pbr_keys[p]
																				
																				switch (_pbr_key) {
																					case "baseColorTexture": {
																						var _tex_id		= _pbr.baseColorTexture.index
																						var _spr		= json_root.textures[_tex_id]
																						_this_matl.base_color_tex = sprite_get_texture(_spr, 0)
																					} break;
																					
																					case "baseColorFactor": {
																						var _c_val	= _pbr.baseColorFactor;
																						var _gamma = 1/2.2;
																						_this_matl.base_color_fac = [
																							// Gamma space convertion - readjust on shader
																							power(_c_val[0], _gamma),
																							power(_c_val[1], _gamma),
																							power(_c_val[2], _gamma),
																							power(_c_val[3], _gamma),
																						]
																					} break;
																					
																					case "metallicRoughnessTexture": {
																						var _tex_id					= _pbr.metallicRoughnessTexture.index
																						var _spr					= json_root.textures[_tex_id]
																						_this_matl.metal_rough_tex	= sprite_get_texture(_spr, 0)
																					} break;
																			
																					case "metallicFactor": {
																						_this_matl.metal_fac = _pbr.metallicFactor
																						
																					} break;
																			
																					case "roughnessFactor": {
																						_this_matl.rough_fac = _pbr.roughnessFactor
																						
																					} break;
																				}
																			}
																		} break;
																		
																		case "normalTexture": {
																			var _tex_id				= _matl.normalTexture.index;
																			var _spr				= json_root.textures[_tex_id];
																			_this_matl.normal_tex	= sprite_get_texture(_spr, 0);
																		} break;
																			
																		case "occlusionTexture": {
																			var _tex_id				= _matl.occlusionTexture.index;
																			var _spr				= json_root.textures[_tex_id];
																			_this_matl.occlusion_tex = sprite_get_texture(_spr, 0);
																		} break;
																			
																		case "emissiveTexture": {
																			var _tex_id				= _matl.emissiveTexture.index;
																			var _spr				= json_root.textures[_tex_id];
																			_this_matl.emissive_tex = sprite_get_texture(_spr, 0);
																		} break;
																			
																		case "emissiveFactor": {
																			_this_matl.emissive_fac	= _matl.emissiveFactor;
																		} break;
																			
																		case "alphaMode": {
																			// OPAQUE - default
																			// MASK
																			// BLEND
																			_this_matl.alpha_mode	= _matl.alphaMode;
																		} break;
																			
																		case "alphaCutoff": {
																			_this_matl.alpha_cutoff = _matl.alphaCutoff;
																		} break;
																			
																		case "doubleSided": {
																			// false
																		} break;
																	}
																}
																
																self.materials[$ _matl_name] = _this_matl
																_matl_num++
																
																//show_message($"metal of {_this_matl.metal_fac}")
																//show_message($"rough of {_this_matl.rough_fac}")
															} break;													
															
															case "mode": {
																	
															} break;
																
															case "targets": {
																	
															} break;
														}
													}
													
													
													
													// Mesh data collected, now assemble it
													vertex_begin(_vbuffer, global.vformat)
													
														var _flag_col	= _prim_flags >> Attributes.Color & 0x01;
														var _flag_uv	= _prim_flags >> Attributes.TexCoord & 0x01;
														var _flag_norm	= _prim_flags >> Attributes.Normal & 0x01;
																											
														for (var _vtx = 0; _vtx < array_length(_vtx_id); _vtx++) {
															var _id = _vtx_id[_vtx]
															vtx_count++
															
															var _pos	= _prim_data[Attributes.Position][_id]
															var _col	= _flag_col		? _prim_data[Attributes.Color][_id]		: __def_col;
															var _norm	= _flag_norm	? _prim_data[Attributes.Normal][_id]	: __def_norm;
															var _uv		= _flag_uv		? _prim_data[Attributes.TexCoord][_id]	: __def_uv;
							
															// TODO test if bitshift is faster
															var _col_rgb = make_color_rgb(_col[0]*255, _col[1]*255, _col[2]*255)
															
															vertex_position_3d(_vbuffer, _pos[0], _pos[1], _pos[2])
															vertex_color(_vbuffer, _col_rgb, _col[3]*255)
															vertex_normal(_vbuffer, _norm[0], _norm[1], _norm[2])
															vertex_texcoord(_vbuffer, _uv[0], _uv[1])
														}
														
													vertex_end(_vbuffer)
													
													// Update mesh object
													_this_prim.vbuffer	= _vbuffer;
													
													// Current primitive fully assembled, now save it in the model
													array_push(_this_mesh.primitives, _this_prim);
												}
												
											} break;
											
											case "weights": {
													
											} break;
										}
									}
								
									// Current mesh fully assembled, now save it in the model
									array_push(meshes, _this_mesh);
									
									// Ended mesh building
									_mesh.mesh_loaded = true
								
								} break;
							}
						}
					}
				}
			}
		}
		
		// Model fully loaded
		is_loaded = true;
		
		// Clear stuff
		for (var i = 0; i < array_length(json_root.buffers); i++) {
			buffer_delete(json_root.buffers[i])
		}
		delete json_root;
		
		// Trace load time
		load_time = (get_timer() - load_time)/1_000
		show_debug_message($"Scene loaded! Load time: {load_time}ms ({load_time/1000}sec)")
		
		return self;
	}
	
	static Update = function() {
		
	}
	
	static Animate = function() {
		
	}
	
	static Submit = function() {
		if (!is_loaded) return self;

		for (var i = array_length(meshes) - 1; i >= 0; --i)	{
			meshes[i].Submit();
		}
		return self;
	}
	
	static Freeze = function() {
		for (var i = array_length(meshes) - 1; i >= 0; --i)	{
			meshes[i].Freeze();
		}
		return self;
	}
}


