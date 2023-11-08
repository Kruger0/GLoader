
function __gl_trace(_string) {
	if (__gcache().trace) {
		show_debug_message($"Gloader: {_string}")
	}
}


function __gl_error(_string) {
	show_error($"Gloader error: {_string}", true)
}
	

function __gl_parse2json(_file) {
			
	var _json = undefined
	switch (filename_ext(_file)) {
		case ".glb": {
			// Load base file
			var _buffer		= buffer_load(_file);
			if (_buffer == -1) __gl_error($"Coulnd't load file \"{_file}\"")
					
			buffer_seek(_buffer, buffer_seek_start, 0)
					
			// Read buffer header
			var _key_gltf = buffer_read(_buffer, buffer_u32)
			if (_key_gltf == KEY_GLTF) {
				var _version	= buffer_read(_buffer, buffer_u32)
				var _total_len	= buffer_read(_buffer, buffer_u32)
				__gl_trace($"Valid .glb format detected! Version {_version}")
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
						__gl_trace($"Error: Unidentified key 0x{dec_to_hex(_chunk_content)} founded in file {_file}")
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
				_json.textures[i] = _spr // TODO: rescue sampler info on future
			}
					
		} break;
			
		case ".gltf": {
			// Load base file
			var _buffer		= buffer_load(_file);
			if (_buffer == -1) __gl_error($"Coulnd't load file \"{_file}\"", true)
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
					__gl_error($"Can't load buffer \"{i}\" from file \"{_file}\"", true);
				}

				_json.buffers[i] = _buff;
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
				_json.textures[i] = _spr // TODO: rescue sampler info on future
			}
		} break;
	}
	return _json
}


function __gl_load_accessor(_json, _acess_index) {
			
	static __hash_byteOffset = SET_HASH("byteOffset");
	static __hash_byteStride = SET_HASH("byteStride");
			
	var _acess			= _json.accessors[_acess_index];
	var _buff_view		= _json.bufferViews[_acess.bufferView];
	var _buff_id		= _json.buffers[_buff_view.buffer];
			
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
	var _view_offset	= struct_get_from_hash(_acess, __hash_byteOffset) ?? 0
	var _buff_offset	= struct_get_from_hash(_buff_view, __hash_byteOffset) ?? 0
	var _buff_stride	= struct_get_from_hash(_buff_view, __hash_byteStride) ?? _group_size
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


function __gl_get_node_matrix(_node) {
	static __def_scl	= [1, 1, 1];
	static __def_rot	= [0, 0, 0, 1];
	static __def_trl	= [0, 0, 0];
	
	var _model_matrix	= _node[$ "matrix"]
	if !(is_undefined(_model_matrix)) {
		//_model_matrix = (_model_matrix) // TODO: check if its necessary
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


function __gl_transform_childrens(_json, _node, _parent_mat) {
	for (var i = 0; i < array_length(_node.children); i++) {
		var _child_node = _json.nodes[_node.children[i]]
		var _child_mat = __gl_get_node_matrix(_child_node)
		struct_remove(_child_node, "translation")
		struct_remove(_child_node, "rotation")
		struct_remove(_child_node, "scale")
		_child_node.matrix = matrix_multiply(_child_mat, _parent_mat)
		
		if (_child_node[$ "children"] != undefined) {
			__gl_transform_childrens(_json, _child_node, _child_node.matrix)
		}
	}
}


function __gl_mesh_duplicate(_mesh) {
	
}




















