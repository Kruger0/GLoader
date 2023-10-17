
// Group of meshes
function GModel(_name = "gmodel") constructor {
	name		= _name
	filename	= ""
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
		
		filename = _file
		
		//Loadtime tracing
		load_time = get_timer();
		show_debug_message("Scene load started!");
		
		static __matl_num	= 0;
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
				_model_matrix = (_model_matrix) // TODO: check if its necessary
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
		
		static __transform_child_matrices = function(_nodes) {
			//// Set the matrix of each mesh before building the vbuffer
			//for (var i = array_length(_nodes); i--;) {	
			//	var _node		= _nodes[i];
			//	var _parent		= _node
			//	if (_node[$ "children"] != undefined) {
			//		// Transform next nodes
			//		// TODO: wondering if matrix stack functions are better for that
			//		var _parent_matrix = __get_node_matrix(_node)
			//		for (var l = array_length(_node.children); l--;) {
			//			var _child_id	= _node.children[l];
			//			var _child		= _nodes[_child_id]
			//			var _child_mat	= __get_node_matrix(_child)
			//			var _new_mat	= matrix_multiply(_child_mat, _parent_matrix)
			//			_child.matrix	= _new_mat
			//		}
			//	}				
			//}
		}
		
		static __parse2json = function(_file) {
			
			var _json = undefined
			switch (filename_ext(_file)) {
				case ".glb": {
					// Load base file
					var _buffer		= buffer_load(_file);
					if (_buffer == -1) show_error($"glTF error: coulnd't load file {_file}", true)
					
					buffer_seek(_buffer, buffer_seek_start, 0)
					
					// Read buffer header
					var _key_gltf = buffer_read(_buffer, buffer_u32)
					if (_key_gltf == KEY_GLTF) {
						var _version	= buffer_read(_buffer, buffer_u32)
						var _total_len	= buffer_read(_buffer, buffer_u32)
						show_debug_message($"Valid glb format detected! Version {_version}")
					}
										
					// Read binary chunks
					var _buffer_count = 0
					while (buffer_tell(_buffer) < buffer_get_size(_buffer)) {
						var _chunk_length	= buffer_read(_buffer, buffer_u32)
						var _chunk_content	= buffer_read(_buffer, buffer_u32)
						var _seek_pos		= buffer_tell(_buffer)
						
						
						switch (_chunk_content) {
							case KEY_JSON: { 
								var _string = buffer_read(_buffer, buffer_string)
								_json = json_parse(_string)
								buffer_seek(_buffer, buffer_seek_start, _seek_pos + _chunk_length)
							} break;
						
							case KEY_BIN: {
								var _buffer_bin = buffer_create(_chunk_length, buffer_fixed, 1);
								repeat(_chunk_length / SIZE_U32) {
									var _byte = buffer_read(_buffer, buffer_u32)
									buffer_write(_buffer_bin, buffer_u32, _byte)
								}
								_json.buffers[_buffer_count] = _buffer_bin;
								_buffer_count++;
							} break;
							
							default: {
								show_message($"Unidentified key 0x{dec_to_hex(_chunk_content)} founded in file {_file}")
							}
						}
					}
					
					// Delet main buffer
					buffer_delete(_buffer)
									
					// Rebuild images
					var _imgs = _json[$ "images"] ?? []
					for (var i = 0; i < array_length(_imgs); i++) {
						var _img				= _imgs[i]	// TODO: check if using strings is too slow for this. Most of those keys MUST be presene in the JSON anyway
						var _path_temp			= $"img_{i}.temp";
						var _buff_view			= _json[$ "bufferViews"][_img[$ "bufferView"]];
						var _buff_id			= _json[$ "buffers"][_buff_view[$ "buffer"]];
						var _buff_offset		= _buff_view[$ "byteOffset"] ?? 0;
						var _buff_length		= _buff_view[$ "byteLength"];

						var _buff_temp			= buffer_create(_buff_length, buffer_fixed, 1)
						buffer_copy(_buff_id, _buff_offset, _buff_length, _buff_temp, 0)
						buffer_save(_buff_temp, _path_temp)
						
						var _spr = sprite_add(_path_temp, 1, false, false, 0, 0)
						
						buffer_delete(_buff_temp)
						file_delete(_path_temp)
						_json[$ "textures"][i] = _spr // TODO: rescue sampler info on future
					}
					
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
							var _img_path	= filename_path(_file) + _img_uri;
							if (string_copy(_img_uri, 0, 4) == "data") {
								var _b64		= string_split(_img_uri, ",")[1]
								var _buff_temp	= buffer_base64_decode(_b64)
								buffer_save(_buff_temp, _path_temp)
						
								_spr = sprite_add(_path_temp, 1, false, false, 0, 0)
						
								buffer_delete(_buff_temp)
								file_delete(_path_temp)
							} else {
								_img_path = string_replace_all(_img_path, "%20", " ") // Names with space
								//show_message(_img_path)
								if (file_exists(_img_path)) {
									_spr = sprite_add(_img_path, 1, false, false, 0, 0);
								} else {
									_spr = spr_white
								}
						
							}
						}
						_json[$ "textures"][i] = _spr // TODO: rescue sampler info on future
					}
				} break;
			}
			return _json
		}

		static __mesh_duplicate = function() {
			
		}
		
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
					
					// Check for childrens - TODO: make this recursive somehow
					for (var j = array_length(_nodes); j--;) {	
						var _node		= _nodes[j];
						var _parent		= _node
						if (_node[$ "children"] != undefined) {
							
						// Transform next nodes
							var _parent_matrix = __get_node_matrix(_node)
							for (var l = array_length(_node.children); l--;) {
								var _child_id	= _node.children[l];
								var _child		= _nodes[_child_id]
								var _child_mat	= __get_node_matrix(_child)
								var _new_mat	= matrix_multiply(_child_mat, _parent_matrix)
								_child.matrix	= _new_mat
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
													var _vtx_id			= undefined
																																						
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
																		_prim_flags = _prim_flags | 0x01 << _data_type;
																		var _acess_index = _attrib[$ _attrib_key];
																		_prim_data[_data_type] = __load_accessor(_acess_index);
																	}
																}
															} break;
															
															case "indices": {
																_vtx_id = __load_accessor(_prim.indices);
															} break;
															
															case "material": {
																
																var _matl = json_root.materials[_prim.material];
																
																// If matl doesn't have a name, assign a number
																var _matl_name = _matl[$ "name"];
																if (is_undefined(_matl_name)) {
																	_matl_name = $"matl_{__matl_num}";
																	__matl_num++;																	
																}
																
																
																// Check if material already exists
																_this_prim.material = _matl_name;
																if (!is_undefined(self.materials[$ _matl_name])) {
																	// If so, reference it and continue
																	continue;
																}
																
																
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
																		
																		case "extensions": { // TODO: oh boy...
																			// Dirty base color
																			var _tex_id		= _matl.extensions.KHR_materials_pbrSpecularGlossiness.diffuseTexture.index
																			var _spr		= json_root.textures[_tex_id]
																			_this_matl.base_color_tex = sprite_get_texture(_spr, 0)
																			
																			// Dirty metalRough
																			var _tex_id					= _matl.extensions.KHR_materials_pbrSpecularGlossiness.specularGlossinessTexture.index
																			var _spr					= json_root.textures[_tex_id]
																			_this_matl.metal_rough_tex	= sprite_get_texture(_spr, 0)
																		} break
																	}
																}
																
																self.materials[$ _matl_name] = _this_matl
																
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
														var _arr_length	= 0;
														var _is_indexed	= false;
														
														if (is_undefined(_vtx_id)) {	// Unindexed geometry
															_arr_length = array_length(_prim_data[Attributes.Position]);
														} else {						// Indexed geometry
															_arr_length = array_length(_vtx_id);
															_is_indexed = true;
														}
														
														var _id = 0;
														for (var _vtx = 0; _vtx < _arr_length; _vtx++) {
															_id = _is_indexed ? _vtx_id[_vtx] : _vtx;
	
															var _pos	= _prim_data[Attributes.Position][_id]
															var _col	= _flag_col		? _prim_data[Attributes.Color][_id]		: __def_col;
															var _norm	= _flag_norm	? _prim_data[Attributes.Normal][_id]	: __def_norm;
															var _uv		= _flag_uv		? _prim_data[Attributes.TexCoord][_id]	: __def_uv;
							
															var _col_rgb = (_col[2] * 0xff << 16) | (_col[1] * 0xff << 8) | (_col[0] * 0xff)
															
															vertex_position_3d(_vbuffer, _pos[0], _pos[1], _pos[2])
															vertex_color(_vbuffer, _col_rgb, _col[3]*0xff)
															vertex_normal(_vbuffer, _norm[0], _norm[1], _norm[2])
															vertex_texcoord(_vbuffer, _uv[0], _uv[1])
														}

													vertex_end(_vbuffer)
													vtx_count += _vtx;
													
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
		
		//Loadtime tracing
		load_time = (get_timer() - load_time)/1_000
		show_debug_message($"Scene loaded! Load time: {load_time}ms ({load_time/1_000}sec)")
		
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