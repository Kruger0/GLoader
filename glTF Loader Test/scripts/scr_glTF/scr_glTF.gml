
// Gloader - glTF Loader for GameMaker
// Version 0.5

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


// Group of vertes buffers
function GMesh(_model = undefined) constructor {
	model		= _model;
	vbuffer		= undefined;
	material	= undefined
	
	static Freeze = function() {
		if (vbuffer != undefined) {
			vertex_freeze(vbuffer)
		}
	}
	
	static Submit = function() {
		static _tex_white			= sprite_get_texture(spr_white, 0);
		
		static _tex_metal_rough		= sprite_get_texture(spr_metal_rough, 0)
		static _tex_normal			= sprite_get_texture(spr_normal, 0)
		static _tex_emissive		= sprite_get_texture(spr_emissive, 0)
		static _tex_occlusion		= sprite_get_texture(spr_occlusion, 0)
		
		static _u_tex_metal_rough	= shader_get_sampler_index(shd_passthrough, "u_tex_metal_rough")
		static _u_tex_normal		= shader_get_sampler_index(shd_passthrough, "u_tex_normal")
		static _u_tex_emissive		= shader_get_sampler_index(shd_passthrough, "u_tex_emissive")
		static _u_tex_occlusion		= shader_get_sampler_index(shd_passthrough, "u_tex_occlusion")
		
		static _u_base_color_fac	= shader_get_uniform(shd_passthrough, "u_matl_color")
		
		if (vbuffer != undefined) {
			var _shader			= shader_current();
			
			var _base_color_tex		= pointer_null;
			var _metal_rough_tex	= pointer_null;
			var _normal_tex			= pointer_null;
			var _emissive_tex		= pointer_null;
			var _occlusion_tex		= pointer_null;
			
			var _base_color_fac		= [1, 1, 1, 1]

			// Search for material data
			if (material != undefined) {
				with (model.materials[$ material]) {
					_base_color_tex		= base_color_tex;
					_metal_rough_tex	= metal_rough_tex;
					_normal_tex			= normal_tex;
					_emissive_tex		= emissive_tex
					_occlusion_tex		= occlusion_tex
					
					_base_color_fac		= base_color_fac
				}
			}
			
			// If data does not exists, use default values
			if (_base_color_tex		== pointer_null) {
				_base_color_tex		= _tex_white;
			}

			if (_metal_rough_tex	== pointer_null) {
				_metal_rough_tex	= _tex_metal_rough;
			}

			if (_normal_tex			== pointer_null) {
				_normal_tex			= _tex_normal;
			}

			if (_emissive_tex		== pointer_null) {
				_emissive_tex		= _tex_emissive;
			}

			if (_occlusion_tex		== pointer_null) {
				_occlusion_tex		= _tex_occlusion;
			}

			texture_set_stage(_u_tex_metal_rough, _metal_rough_tex);
			texture_set_stage(_u_tex_normal, _normal_tex);
			texture_set_stage(_u_tex_emissive, _emissive_tex);
			texture_set_stage(_u_tex_occlusion, _occlusion_tex);
			
			shader_set_uniform_f_array(_u_base_color_fac, _base_color_fac)
			
			vertex_submit(vbuffer, pr_trianglelist, _base_color_tex);
		}
		return self;
	}
	
	//static Delete = function() {
	//	if (vbuffer != undefined) {
	//		vertex_delete_buffer(vbuffer)
	//	}
	//}
}

// Group of texture pointers
function GMaterial(_name = "gmatl") constructor {
	
	name			= _name
	base_color_tex	= pointer_null;
	metal_rough_tex	= pointer_null;
	normal_tex		= pointer_null;
	occlusion_tex	= pointer_null;
	emissive_tex	= pointer_null;
	occlusion_tex	= pointer_null;
	
	base_color_fac	= [1, 1, 1, 1]
	metal_fac		= 1;
	rough_fac		= 1;
	emissive_fac	= [0, 0, 0]
	
	alpha_mode		= "OPAQUE"
	alpha_cutoff	= 0.5;
	double_sided	= false;
	
	static Delete = function() {
		return undefined;
	}
}

// Group of meshes, materials and animations
function GModel(_name = "gmodel") constructor {
	name		= _name
	is_loaded	= false;
	is_cached	= false
	meshes		= [];
	materials	= {};
	textures	= {};
	
	static Load = function(_file) {
		static __load_accessor = function(_root, _acess_index) {
			var _acess			= _root.accessors[_acess_index];
			var _buff_view		= _root.bufferViews[_acess.bufferView];
			var _buff_id		= _root.buffers[_buff_view.buffer];
		
			var _buff_offset	= _buff_view[$ "byteOffset"] ?? 0;
			var _buff_stride	= _buff_view[$ "byteStride"] ?? 0; // TODO consider byteStride a thing
			var _buff_length	= _buff_view.byteLength;
			
			buffer_seek(_buff_id, buffer_seek_start, _buff_offset);

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
		
			var _arr = [];
			while (buffer_tell(_buff_id) != _buff_offset + _buff_length) {
				if (_size > 1) {
					var _group_arr = [];
					repeat(_size) {
						// For some reason the color value goes way higher so this division fix it
						var _color_fix = (_size == 4 && _type == buffer_u16 ? 65535 : 1)
						array_push(_group_arr, buffer_read(_buff_id, _type) / _color_fix);
					}
					array_push(_arr, _group_arr);
				} else {
					array_push(_arr, buffer_read(_buff_id, _type));
				}
			}																				
			return _arr;
		}
		
		// Loads data according to extension type
		
		switch (filename_ext(_file)) {
			case ".glb": {
				
			} break;
			
			case ".gltf": {
				// Load base file
				var _buffer		= buffer_load(_file);
				var _string		= buffer_read(_buffer, buffer_string);
				var _root		= json_parse(_string);
				buffer_delete(_buffer)
				
				
				// Load all buffers
				var _buffs = _root[$ "buffers"]
				for (var i = 0; i < array_length(_buffs); i++) {
					var _buff		= undefined;
					var _buff_id	= _buffs[i];
					var _buff_uri	= _buff_id.uri;
					var _path_bin	= filename_path(_file) + _buff_uri;
				
					if (string_copy(_buff_uri, 0, 4) == "data") {
						_buff = buffer_base64_decode(string_split(_buff_uri, ",")[1]);
					} else if (file_exists(_path_bin)) {
						_buff = buffer_load(_path_bin);
					} else {
						show_error($"glTF error: can't load buffer {i} from {_file}", true);
					}

					_root[$ "buffers"][i] = _buff;
				}
				
				// Load all images
				var _imgs = _root[$ "images"]
				for (var i = 0; i < array_length(_imgs); i++) {
					var _img		= _imgs[i]
					var _img_uri	= _img[$ "uri"];
					var _spr		= undefined;
					var _path_temp	= $"img_{i}.temp"
				
					if (_img_uri == undefined) {
						var _buff_view			= _root[$ "bufferViews"][_img[$ "bufferView"]]
						var _buff_id			= _root[$ "buffers"][_buff_view[$ "buffer"]]
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
							_spr = sprite_add(_img_path, 1, false, false, 0, 0);
						
						}
					}
					_root[$ "textures"][i] = _spr // TODO rescue sampler info on future
				}
			} break;
		}
		
		// JSON and pointers are ready, proceeds to assemble scene
		
		var _keys = struct_get_names(_root)
		for (var i = 0; i < array_length(_keys); i++) {
			var _key = _keys[i]
			switch (_key) {
				case "asset": {
					var _asset = _root.asset;
				} break;
					
				case "scenes": {
						
				} break;
				
				case "nodes": {
					var _nodes = _root.nodes;
					
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
									var _mesh		= _root.meshes[_node.mesh];
									var _mesh_keys	= struct_get_names(_mesh);
									
									for (var l = 0; l < array_length(_mesh_keys); l++) {
										var _mesh_key = _mesh_keys[l];
							
										switch (_mesh_key) {
											case "name": {
												var _mesh_name = _mesh.name;
											} break;	
											
											case "primitives": {
												var _prims = _mesh.primitives;
												
												for (var m = 0; m < array_length(_prims); m++) {
													var _prim		= _prims[m];
													var _prim_keys	= struct_get_names(_prim);
													
													// Start new mesh assembling
													var _mesh_data		= array_create(Attributes.SIZE);
													var _mesh_flags		= 0x00;
													var _vbuffer		= vertex_create_buffer();
													var _this_mesh		= new GMesh(self);
													var _matl_num		= 0;
													_this_mesh.vbuffer	= _vbuffer;
													
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
																		_mesh_flags = _mesh_flags | 0x01 << _data_type
																		var _acess_index = _attrib[$ _attrib_key]
																		_mesh_data[_data_type] = __load_accessor(_root, _acess_index)
																	}
																}
															} break;
															
															case "indices": {
																var _vtx_id = __load_accessor(_root, _prim.indices)
															} break;
															
															case "material": {
																
																var _matl = _root.materials[_prim.material];
																
																// Check if material doesnt already exists
																// If yes, reference it and continue
																
																var _matl_name	= _matl[$ "name"] ?? $"matl_{_matl_num}";
																if (!is_undefined(self.materials[$ _matl_name])) {
																	_this_mesh.material = self.materials[$ _matl_name];
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
																						var _spr		= _root.textures[_tex_id]
																						_this_matl.base_color_tex = sprite_get_texture(_spr, 0)
																					} break;
																					
																					case "baseColorFactor": {
																						var _c_val	= _pbr.baseColorFactor;
																						_this_matl.base_color_fac = [
																							_c_val[0],
																							_c_val[1],
																							_c_val[2],
																							_c_val[3],
																						]
																					} break;
																					
																					case "metallicRoughnessTexture": {
																						var _tex_id					= _pbr.metallicRoughnessTexture.index
																						var _spr					= _root.textures[_tex_id]
																						_this_matl.metal_rough_tex	= sprite_get_texture(_spr, 0)
																					} break;
																			
																					case "metallicFactor": {
																						// 1
																					} break;
																			
																					case "roughnessFactor": {
																						// 1
																					} break;
																				}
																			}
																		} break;
																		
																		case "normalTexture": {
																			var _tex_id				= _matl.normalTexture.index
																			var _spr				= _root.textures[_tex_id]
																			_this_matl.normal_tex	= sprite_get_texture(_spr, 0)
																		} break;
																			
																		case "occlusionTexture": {
																			var _tex_id				= _matl.occlusionTexture.index
																			var _spr				= _root.textures[_tex_id]
																			_this_matl.occlusion_tex = sprite_get_texture(_spr, 0)
																		} break;
																			
																		case "emissiveTexture": {
																			var _tex_id				= _matl.emissiveTexture.index
																			var _spr				= _root.textures[_tex_id]
																			_this_matl.emissive_tex = sprite_get_texture(_spr, 0)
																		} break;
																			
																		case "emissiveFactor": {
																			_this_matl.emissive_fac	= _matl.emissiveFactor;
																		} break;
																			
																		case "alphaMode": {
																			// OPAQUE - default
																			// MASK
																			// BLEND
																		} break;
																			
																		case "alphaCutoff": {
																			// 0.5
																		} break;
																			
																		case "doubleSided": {
																			// false
																		} break;
																	}
																}
																
																self.materials[$ _matl_name] = _this_matl
																_this_mesh.material = _matl_name;
																_matl_num++
															} break;													
															
															case "mode": {
																	
															} break;
																
															case "targets": {
																	
															} break;
														}
													}
													
													// Mesh data collected, now assemble it
													vertex_begin(_this_mesh.vbuffer, global.vformat)
													
														var _flag_col		= _mesh_flags >> Attributes.Color & 0x01
														var _col_default	= [1, 1, 1, 1];
														
														var _flag_uv		= _mesh_flags >> Attributes.TexCoord & 0x01
														var _uv_default		= [0, 1]
														
														for (var _vtx = 0; _vtx < array_length(_vtx_id); _vtx++) {
															var _id = _vtx_id[_vtx]
															
															var _pos	= _mesh_data[Attributes.Position][_id]
															var _col	= _flag_col ? _mesh_data[Attributes.Color][_id] : _col_default
															var _norm	= _mesh_data[Attributes.Normal][_id]
															var _uv		= _flag_uv ? _mesh_data[Attributes.TexCoord][_id] : _uv_default
															
															vertex_position_3d(_this_mesh.vbuffer, _pos[0], _pos[1], _pos[2])
															vertex_color(_this_mesh.vbuffer, make_color_rgb(_col[0]*255, _col[1]*255, _col[2]*255), 1)
															vertex_normal(_this_mesh.vbuffer, _norm[0], _norm[1], _norm[2])
															vertex_texcoord(_this_mesh.vbuffer, _uv[0], _uv[1])
														}
														
													vertex_end(_this_mesh.vbuffer)
													//vertex_freeze(_this_mesh.vbuffer)
													
													// Current mesh fully assembled, now save it in the model
													array_push(meshes, _this_mesh)
												}
												
											} break;
											
											case "weights": {
													
											} break;
										}
									}
								} break;
								
								case "camera": {
									
								} break;
								
								case "children": {
									
								} break;
								
								case "skin": {
									
								} break;
								
								case "matrix": {
									
								} break;
								
								case "rotation": {
									// quaternion
								} break;
								
								case "scale": {
									
								} break;
								
								case "translation": {
									
								} break;
								
								case "weights": {
									
								} break;
							}
						}
					}
				}
			}
		}
		
		// Model fully loaded
		
		is_loaded = true
		return self;
	}
	
	static Submit = function() {
		if (!is_loaded) return self;

		//if (_matrix != undefined) {
		//	matrix_set(matrix_world, _matrix)
		//}
		
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


