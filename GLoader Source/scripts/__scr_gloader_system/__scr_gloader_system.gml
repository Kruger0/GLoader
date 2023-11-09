


// Caching information for glTF loader
function __gl_cache() constructor {
	static data = {
		
		trace				: true,
		vform_PCNT			: undefined,
		vform_PCNTBB		: undefined,
		
		materials : {
			
		},
		
		defaults : {
			alpha_cutoff	: GLOADER_DEFAULT_ALPHA_CUTOFF,
			color			: GLOADER_DEFAULT_COLOR,
			normal			: GLOADER_DEFAULT_NORMAL,
			texcoord		: GLOADER_DEFAULT_TEXCOORD,
			
			scale			: GLOADER_DEFAULT_SCALE,
			rotation		: GLOADER_DEFAULT_ROTATION,
			translation		: GLOADER_DEFAULT_TRANSLATION,
			
			metal			: GLOADER_DEFAULT_METAL,
			roughness		: GLOADER_DEFAULT_ROUGHNESS,
			emissive		: GLOADER_DEFAULT_EMISSIVE,
		},
		
		textures : {
			base_color	: sprite_get_texture(__spr_white, 0),
			metal_rough	: sprite_get_texture(__spr_metal_rough, 0),
			normal		: sprite_get_texture(__spr_normal, 0),
			emissive	: sprite_get_texture(__spr_emissive, 0),
			occlusion	: sprite_get_texture(__spr_occlusion, 0),
		},
		
		uniforms : {
			
		},
	}
	
	return data;
}



function __gl_trace(_string) {
	if (__gl_cache().trace) {
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
			if (_buffer == -1) __gl_error($"Coulnd't load file \"{_file}\"")
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
					__gl_error($"Can't load buffer \"{i}\" from file \"{_file}\"");
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


function __gl_get_component_type(_component_type) {
	var _type = undefined;
	switch (_component_type) {		
		case ComponentType.BYTE:			{ _type = buffer_s8		} break;
		case ComponentType.UNSIGNED_BYTE:	{ _type = buffer_u8		} break;
		case ComponentType.SHORT:			{ _type = buffer_s16	} break;
		case ComponentType.UNSIGNED_SHORT:	{ _type = buffer_u16	} break;
		case ComponentType.UNSIGNED_INT:	{ _type = buffer_u32	} break;
		case ComponentType.FLOAT:			{ _type = buffer_f32	} break;
	}
	return _type;
}


function __gl_load_accessor(_json, _acess_index) {
			
	static __hash_byteOffset = SET_HASH("byteOffset");
	static __hash_byteStride = SET_HASH("byteStride");
			
	var _acess			= _json.accessors[_acess_index];
	var _buff_view		= _json.bufferViews[_acess.bufferView];
	var _buff_id		= _json.buffers[_buff_view.buffer];
	var _type			= __gl_get_component_type(_acess.componentType)

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
	var _view_offset	= GET_HASH(_acess, __hash_byteOffset) ?? 0
	var _buff_offset	= GET_HASH(_buff_view, __hash_byteOffset) ?? 0
	var _buff_stride	= GET_HASH(_buff_view, __hash_byteStride) ?? _group_size
	var _buff_length	= _buff_view.byteLength;
	var _total_offset	= _view_offset + _buff_offset;
	var _byte_stride	= _buff_stride - _group_size;
				
	
	// In case of sparse acessor
	var _has_sparse = false;
	var _sps_arr = [[], []];
	if (_acess[$ "sparse"] != undefined) {
		_has_sparse		= true;
		var _sps		= _acess.sparse
		var _sps_count	= _sps.count;
		var _sps_indices= _sps.indices;
		var _sps_values	= _sps.values;
		
		// Indices
		var _sps_ind_buff_view	= _json.bufferViews[_sps.indices.bufferView]
		var _sps_ind_buff_off	= _sps_ind_buff_view.byteOffset
		var _sps_ind_buff_id	= _json.buffers[_sps_ind_buff_view.buffer]
		var _sps_ind_byte_off	= _sps.indices.byteOffset
		var _sps_ind_type		= __gl_get_component_type(_sps_indices.componentType); // Prolly this is unnecessary as indices should be only u16
		var _sps_ind_size		= buffer_sizeof(_sps_ind_type);
		
		// Values
		var _sps_val_buff_view	= _json.bufferViews[_sps.values.bufferView]
		var _sps_val_buff_off	= _sps_val_buff_view.byteOffset
		var _sps_val_buff_id	= _json.buffers[_sps_val_buff_view.buffer]
		var _sps_val_byte_off	= _sps.values.byteOffset
		
		// Save sparse data in an array
		buffer_seek(_sps_ind_buff_id, buffer_seek_start, _sps_ind_byte_off + _sps_ind_buff_off);
		
		var _indice = 0;
		repeat(_sps.count) {
			// Store indices
			var _ind_offset = _indice * _sps_ind_size;
			buffer_seek(_sps_ind_buff_id, buffer_seek_start, _sps_ind_byte_off + _sps_ind_buff_off + _ind_offset);
			array_push(_sps_arr[0], buffer_read(_sps_ind_buff_id, _sps_ind_type))
			
			// Store values
			var _val_offset = (_indice * _size) * _type_size
			buffer_seek(_sps_val_buff_id, buffer_seek_start, _sps_val_byte_off + _sps_val_buff_off + _val_offset);
			if (_size > 1) {
				var _group_arr = []
				repeat(_size) {
					var _reading = buffer_read(_sps_val_buff_id, _type)
					array_push(_group_arr, _reading)
				}
				array_push(_sps_arr[1], _group_arr)
				buffer_seek(_sps_val_buff_id, buffer_seek_relative, _byte_stride);	// Prolly it wouldn't have any byte stride but anyway...
			} else {
				var _reading = buffer_read(_sps_val_buff_id, _type);
				array_push(_sps_arr[1], _reading);
				buffer_seek(_sps_val_buff_id, buffer_seek_relative, _byte_stride);
			}
			_indice++;
		}
	}
	var _sps_indice = 0;
	var _sps_size	= array_length(_sps_arr[0]);
	
	
	// Start readings
	buffer_seek(_buff_id, buffer_seek_start, _total_offset);
	var _arr = [];
	var _indice = 0
	

	repeat(_view_count) {
		
		// Check indices in sparse acessor fist so wouldn't need a second loop
		if (_has_sparse) {
			if !(_sps_indice >= _sps_size) {	// It's short of a failsafe required by first looking onto the sparse and THEN the "original" data
				if (_indice == _sps_arr[0][_sps_indice]) {
					array_push(_arr, _sps_arr[1][_sps_indice]);
					buffer_seek(_buff_id, buffer_seek_relative, _group_size)
					_indice++;
					_sps_indice++;
					continue;
				}
			}
		}
		
		// If not in sparse, read the orignal data
		if (_size > 1) {
			var _group_arr = [];
			repeat(_size) {
				// For some reason the color value goes way higher so this division fix it
				// Edit: this fix is dumb cuz there may be colors in VEC3 :(
				var _color_fix = (_size == 4 && _type == buffer_u16 ? 65535 : 1)
				
				var _reading = buffer_read(_buff_id, _type) / _color_fix
				array_push(_group_arr, _reading);
			}
			array_push(_arr, _group_arr);
			buffer_seek(_buff_id, buffer_seek_relative, _byte_stride);	
		} else {
			var _reading = buffer_read(_buff_id, _type)	
			array_push(_arr, _reading);
			buffer_seek(_buff_id, buffer_seek_relative, _byte_stride);
		}
		_indice++;
	}	

	return _arr;
}


function __gl_get_node_matrix(_node) {
	
	var _model_matrix	= _node[$ "matrix"]
	if !(is_undefined(_model_matrix)) {
		//_model_matrix = (_model_matrix) // TODO: check if its necessary
	} else {
		var _trl	= _node[$ "translation"]	?? __gl_cache().defaults.translation;
		var _rot	= _node[$ "rotation"]		?? __gl_cache().defaults.rotation;
		var _scl	= _node[$ "scale"]			?? __gl_cache().defaults.scale;									
												
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




















