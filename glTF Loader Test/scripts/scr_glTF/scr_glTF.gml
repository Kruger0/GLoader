
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

	enum MeshData {
		Name,
		Position,
		Normal,
		Color,
		TexCoord,
		Size
	}
	
	enum Attributes {
		POSITION,
		NORMAL,
		TANGENT,
		TEXCOORD,
		COLOR,
		JOINTS,
		WEIGHTS,
		SIZE,
	}

	enum Texture {
		BaseColor,
		Normal,
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
	
/*
"SCALAR"	1
"VEC2"		2
"VEC3"		3
"VEC4"		4
"MAT2"		4
"MAT3"		9
"MAT4"		16
*/
	
#endregion


// Group of vertes buffers and their pointers
function Mesh(_model = undefined) constructor {
	model		= _model;
	vbuffer		= undefined;
	material	= undefined
	
	static Freeze = function() {
		if (vbuffer != undefined) {
			vertex_freeze(vbuffer)
		}
	}
	
	//static Submit = function() {
	//	static _tex_white			= sprite_get_texture(spr_white, 0);
	//	static _tex_metal_rough		= sprite_get_texture(spr_metal_rough, 0)
	//	static _tex_normal			= sprite_get_texture(spr_normal, 0)
		
	//	static _u_tex_metal_rough	= shader_get_sampler_index(shd_gbuff_main, "u_tex_metal_rough")
	//	static _u_tex_normal		= shader_get_sampler_index(shd_gbuff_main, "u_tex_normal")
		
	//	if (vbuffer != undefined) {
	//		var _shader			= shader_current();
	//		var _base_color		= pointer_null;
	//		var _metal_rough	= pointer_null;
	//		var _normal			= pointer_null;

	//		// Search for material data
	//		if (material != undefined) {
	//			with (model.materials[$ material]) {
	//				_base_color		= base_color;
	//				_metal_rough	= metal_rough;
	//				_normal			= normal;
	//			}
	//		}
			
	//		// If data does not exists, use default values
	//		if (_base_color		== pointer_null) {
	//			_base_color		= _tex_white;
	//		}

	//		if (_metal_rough	== pointer_null) {
	//			_metal_rough	= _tex_metal_rough;
	//		}

	//		if (_normal			== pointer_null) {
	//			_normal			= _tex_normal;
	//		}

	//		texture_set_stage(_u_tex_metal_rough, _metal_rough);
	//		texture_set_stage(_u_tex_normal, _normal);
			
	//		vertex_submit(vbuffer, pr_trianglelist, _base_color);
	//	}
	//	return self;
	//}
	
	//static Delete = function() {
	//	if (vbuffer != undefined) {
	//		vertex_delete_buffer(vbuffer)
	//	}
	//}
}

function Material() constructor {
	base_color	= pointer_null;
	metal_rough	= pointer_null;
	normal		= pointer_null;
	
	static Delete = function() {
		return undefined;
	}
}

function Scene(_name) constructor {
	name		= _name
	is_loaded	= false;
	is_cached	= false
	meshes		= [];
	materials	= {};
	textures	= {};
	
	static Submit = function() {
		
	}
	
	
}


function load_glTF(_path) {
		
	static __load_accessor = function(_root, _acess_index) {
		var _acess			= _root.accessors[_acess_index];
		var _buff_view		= _root.bufferViews[_acess.bufferView];
		var _buff_id		= _root.buffers[_buff_view.buffer];
		
		var _buff_offset	= _buff_view.byteOffset;
		var _buff_length	= _buff_view.byteLength;
		buffer_seek(_buff_id, buffer_seek_start, _buff_view.byteOffset);

		var _type = undefined
		switch (_acess.componentType) {
			case ComponentType.FLOAT: {			_type = buffer_f32} break;
			case ComponentType.UNSIGNED_SHORT: {_type = buffer_u16} break;
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
					array_push(_group_arr, buffer_read(_buff_id, _type) / (_size == 4 && _type == buffer_u16 ? 65535 : 1));
				}
				array_push(_arr, _group_arr);
			} else {
				array_push(_arr, buffer_read(_buff_id, _type));
			}
		}																				
		return _arr;
	}

	switch (filename_ext(_path)) {
		case ".glb": {
			//var _glb
			//if (file_exists(_path)) {
			//	_glb = buffer_load(_path)
			//} else break;
			
			//buffer_seek(_glb, buffer_seek_start, 0);
			//var _sizeof = buffer_sizeof(buffer_u32)
			
			//var _content_type = Content.Header
			//var _buffer_json = buffer_create(4, buffer_grow, 4)
			
			//var _buffer_png = buffer_create(1, buffer_grow, 1)
			////var _was_png = false
			
			//var _buffer_size = buffer_get_size(_glb)
			//var _buffer_length = _buffer_size / _sizeof
			//while (buffer_tell(_glb) != _buffer_length) {
				
			//	// header
			//	var _key		= buffer_read(_glb, buffer_u32)
			//	if (_key != KEY_GLTF) throw "Opsie"
				
			//	var _ver		= buffer_read(_glb, buffer_u32)
			//	var _total_len	= buffer_read(_glb, buffer_u32)
			//	show_message($"{dec_to_hex(_key)} - {dec_to_hex(_ver)} - {dec_to_hex(_total_len)}")
				
			//	var _chunk_len	= buffer_read(_glb, buffer_u32)
			//	var _chunk_type	= buffer_read(_glb, buffer_u32)
			//	var _chunk_data	= buffer_read(_glb, buffer_string)
			//	show_message($"{_chunk_len} - {_chunk_type} - {_chunk_data}")		
			//	show_message(json_parse(_chunk_data))
				
				
			//	var _chunk_len	= buffer_read(_glb, buffer_u32)
			//	var _chunk_type	= buffer_read(_glb, buffer_u32)
			//	var _chunk_data	= buffer_read(_glb, buffer_string)
			//	show_message($"{_chunk_len} - {_chunk_type} - {_chunk_data}")		
			//}
			
			//show_message($"size: {_buffer_size}, length: {_buffer_length}")
			
			//for (var i = 0; i < buffer_get_size(_glb); i += _sizeof) {
				
			//	var _read = buffer_read(_glb, buffer_u32)
			
			//	switch (_read) {
			//		case KEY_JSON:		_content_type = Content.JSON	break;										
			//		case KEY_BIN:		_content_type = Content.BIN		break;										
			//		case 0x00000068:	_content_type = Content.Header	break;				
			//		case KEY_PNG:		_content_type = Content.PNG		break;
			//		case KEY_JPG:		_content_type = Content.JPG		break;
			//	}
				
			//	//if (_was_png && _content_type != Content.PNG) {
			//	//	show_debug_message("wtf")
			//	//}
				
			//	if (_content_type == Content.JPG) {
			//		buffer_write(_buffer_png, buffer_u32, _read)
			//	}
				
			//	if (_content_type == Content.PNG) {
			//		//_was_png = true
			//		buffer_write(_buffer_png, buffer_u32, _read)
			//	}
				
			//	if (_content_type == Content.JSON) {
			//		//show_message($"writing {_read} to bufer")
			//		if (_read == KEY_JSON) continue // skip header
			//		buffer_write(_buffer_json, buffer_u32, _read)
			//	}
			//}	
			
			//var _file_path = filename_path(GM_project_filename) + "datafiles/"
			
			////var _png = buffer_save(_buffer_png, _file_path + "test_image.png")
			//var _jpg = buffer_save(_buffer_png, _file_path + "test_image.jpg")
			//var _spr = sprite_add(_file_path + "test_image.jpg", 1, false, false, 0, 0)
			////show_message(buffer_read(_buffer_json, buffer_u32))
			//buffer_seek(_buffer_json, buffer_seek_start, 0)
			//var _json = json_parse(buffer_read(_buffer_json, buffer_string))
			////show_message(json_stringify(_json, true));
		} break;
		
		case ".gltf": {
			
			// Load base file
			var _file		= buffer_load(_path);
			var _string		= buffer_read(_file, buffer_string);
			var _root		= json_parse(_string);
			buffer_delete(_file)
			
			// Load all buffers and external files
			var _buffs = _root[$ "buffers"]
			for (var i = 0; i < array_length(_buffs); i++) {
				var _buff		= undefined;
				var _buff_id	= _buffs[i];
				var _buff_uri	= _buff_id.uri;
				var _path_bin	= filename_path(_path) + _buff_uri;
				
				if (string_copy(_buff_uri, 0, 4) == "data") {
					_buff = buffer_base64_decode(string_split(_buff_uri, ",")[1]);
				} else if (file_exists(_path_bin)) {
					_buff = buffer_load(_path_bin);
				} else {
					show_error($"glTF error: can't load buffer {i} from {_path}", true);
				}

				_root[$ "buffers"][i] = _buff;
			}

			// Load images
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
					var _img_path	= filename_path(_path) + _img_uri;
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
				_root[$ "textures"][i] = _spr // TODO rescur sampler info on future
			}
			
			
			var _spr = undefined
			var _mesh_data = array_create(Attributes.SIZE)

			var _keys = struct_get_names(_root)
			for (var i = 0; i < array_length(_keys); i++) {
				var _key = _root[$ _keys[i]]
				switch (_keys[i]) {
					case "asset": {
						//show_message(_key)
					} break;
					
					case "scenes": {
						
					} break;
					
					case "nodes": {
						var _nodes_arr = _root.nodes											// array contendo os nodes
						for (var j = 0; j < array_length(_nodes_arr); j++) {					// ireta pelo array de nodes
							var _nodes = _nodes_arr[j]											// salva a struct do indice atual
							var _keys_nodes	= struct_get_names(_nodes)							// pega as keys da struct
							for (var k = 0; k < array_length(_keys_nodes); k++) {				// itera pelo array de keys da struct
								var _key_node = _nodes[$ _keys_nodes[k]]						// 
								switch (_keys_nodes[k]) {										// 
									
									case "mesh": {												// se for um node de mesh
										var _mesh = _root.meshes[_key_node]			// busca o index dele no array de meshes
										var _mesh_keys = struct_get_names(_mesh)								// 
										for (var l = 0; l < array_length(_mesh_keys); l++) {
											var _mesh_key = _mesh_keys[l];
											
											switch (_mesh_key) {
												
												case "name": {
													var _mesh_name = _mesh[$ _mesh_key]
												} break;
												
												case "primitives": {
													var _prims = _mesh[$ _mesh_key]
													for (var m = 0; m < array_length(_prims); m++) {
														var _prim = _prims[m]												
														var _prim_keys = struct_get_names(_prim)
														for (var n = 0; n < array_length(_prim_keys); n++) {
															var _prim_key = _prim[$ _prim_keys[n]]

															switch (_prim_keys[n]) {
																case "attributes": {
																	var _atrib_keys = struct_get_names(_prim_key)
																	for (var o = 0; o < array_length(_atrib_keys); o++) {
																		var _atrib_key = _atrib_keys[o]
																		var _data_type = undefined;
																		switch (string_letters(_atrib_key)) {
																			case "POSITION":	{ _data_type = Attributes.POSITION	} break;
																			case "NORMAL":		{ _data_type = Attributes.NORMAL	} break
																			case "COLOR":		{ _data_type = Attributes.COLOR		} break;
																			case "TEXCOORD":	{ _data_type = Attributes.TEXCOORD	} break;
																			case "TANGENT":		{ _data_type = Attributes.TANGENT	} break;
																			case "JOINTS":		{ _data_type = Attributes.JOINTS	} break;
																			case "WEIGHTS":		{ _data_type = Attributes.WEIGHTS	} break;
																		}
																		
																		if (_data_type != undefined) {
																			var _acess_index = _prim_key[$ _atrib_key]
																			_mesh_data[_data_type] = __load_accessor(_root, _acess_index)
																		}
																	}
																} break;
														
																case "indices": {
																	var _indexes = __load_accessor(_root, _prim_key)
																} break;
																
																case "material": {
																	var _material = _root.materials[_prim_key]
																	var _mat_keys = struct_get_names(_material)
	
																	for (var o = 0; o < array_length(_mat_keys); o++) {
																		var _mat_key = _mat_keys[o]
																		switch (_mat_key) {
																			case "name": {
																				
																			} break;
																			
																			case "pbrMetallicRoughness": {
																				var _pbr = _material[$ _mat_key]
																				var _pbr_keys = struct_get_names(_pbr)
																				for (var p = 0; p < array_length(_pbr_keys); p++) {
																					var _pbr_key = _pbr_keys[p]
																					switch (_pbr_key) {
																						case "baseColorTexture": {
																							var _tex_id		= _pbr[$ _pbr_key].index
																							var _spr		= _root.textures[_tex_id]		
																				
																						} break;
																			
																						case "baseColorFactor": {
																							var _c_val	= _pbr[$ _pbr_key]
																							var _base_color = [
																								_c_val[0],	// A
																								_c_val[1],	// B
																								_c_val[2],	// G
																								_c_val[3],	// R
																							]
																						} break;
																						
																						case "metallicRoughnessTexture": {
																				
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
																				
																			} break;
																			
																			case "occlusionTexture": {
																				
																			} break;
																			
																			case "emissiveTexture": {
																				
																			} break;
																			
																			case "emissiveFactor": {
																				// [0, 0, 0]
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
																} break;
																
																case "mode": {
																	
																} break;
																
																case "targets": {
																	
																} break;
															}
														}
													}
												} break;
														
												case "weights": {
													
												} break;
											}
											
											// add mesh to scene
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
									
									case "name": {
										
									} break;
								}
							}
						}
					} break;
				}	
			}
			
			
			
			global.tex = sprite_get_texture(_spr ?? spr_white, 0)
			vertex_begin(global.vbuff, global.vformat)
			//show_message(_mesh_data)
			for (var i = 0; i < array_length(_indexes); i++) {
				var _ind	= _indexes[i]
				var _pos	= _mesh_data[Attributes.POSITION][_ind]
				//var _col	= _mesh_data[Attributes.COLOR][_ind]
				var _col	= [1, 1, 1, 1]
				_col = _base_color
				var _normal	= _mesh_data[Attributes.NORMAL][_ind]
				var _uv		= _mesh_data[Attributes.TEXCOORD][_ind]
				
				vertex_position_3d(global.vbuff, _pos[0], _pos[1], _pos[2])
				//show_message(_col)
				vertex_color(global.vbuff, make_color_rgb(_col[0]*255, _col[1]*255, _col[2]*255), _col[3]*256)
				vertex_normal(global.vbuff, _normal[0], _normal[1], _normal[2])
				vertex_texcoord(global.vbuff, _uv[0], _uv[1])
			}
			
			
			vertex_end(global.vbuff)
			
		} break;
	}
}


