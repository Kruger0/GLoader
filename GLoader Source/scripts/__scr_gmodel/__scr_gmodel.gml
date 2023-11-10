
// Group of meshes
function GModel(_name = "gmodel") constructor {
	name		= _name
	filename	= ""
	is_loaded	= false;
	is_cached	= false
	meshes		= [];
	materials	= {};
	textures	= {};
	animations	= {};
	vtx_count	= 0;
	load_time	= 0;
	world_matrix	= matrix_build_identity()
	
	aabb = {
	    x1 : 0,
	    y1 : 0,
	    z1 : 0,
	    x2 : 0,
	    y2 : 0,
	    z2 : 0,
	};
	
	static Load = function(_file) {
		
		filename = _file
		
		//Loadtime tracing
		load_time = get_timer();
		__gl_trace("Scene load started!");
		
		static __matl_num	= 0;
		
		static __hash_index						= SET_HASH("index")
		static __hash_name						= SET_HASH("name")
		static __hash_baseColorTexture			= SET_HASH("baseColorTexture")
		static __hash_baseColorFactor			= SET_HASH("baseColorFactor")
		static __hash_metallicRoughnessTexture	= SET_HASH("metallicRoughnessTexture")
		static __hash_metallicFactor			= SET_HASH("metallicFactor")
		static __hash_roughnessFactor			= SET_HASH("roughnessFactor")
		static __hash_normalTexture				= SET_HASH("normalTexture")
		static __hash_occlusionTexture			= SET_HASH("occlusionTexture")
		static __hash_emissiveTexture			= SET_HASH("emissiveTexture")
		static __hash_pbrMetallicRoughness		= SET_HASH("pbrMetallicRoughness")
		
		// Loads data according to extension type
		json_root	= __gl_parse2json(_file);
		
		// Get root nodes
		if (json_root[$ "scenes"] != undefined) {
			for (var i = 0; i < array_length(json_root.scenes); i++) {
				var _scene = json_root.scenes[i]
				var _root_nodes = _scene.nodes
				
				// Recursivelly transform it childrens
				for (var j = 0; j < array_length(_root_nodes); j++) {
					var _node = json_root.nodes[_root_nodes[j]]
			
					if (_node[$ "children"] != undefined) {
						var _node_mat = __gl_get_node_matrix(_node)
						__gl_transform_childrens(json_root, _node, _node_mat)
					}
				}
			}
		}
			
		// JSON and pointers are ready, proceeds to assemble scene
		var _nodes = json_root.nodes;	
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
							//__gl_trace("TODO: Dupe this mesh!")
						}
									
						// Start new mesh group
						var _this_mesh				= new GMesh(self);
						_this_mesh.mesh_index		= j;
						_this_mesh.model_matrix		= __gl_get_node_matrix(_node);									
									
						for (var l = 0; l < array_length(_mesh_keys); l++) {
							var _mesh_key = _mesh_keys[l];
							_this_mesh.name = _mesh[$ "name"] ?? $"mesh_{l}";
							switch (_mesh_key) {
											
								case "primitives": {
									var _prims = _mesh.primitives;
												
									for (var m = 0; m < array_length(_prims); m++) {
										var _prim		= _prims[m];
										var _prim_keys	= struct_get_names(_prim);
													
										// Start new primitive assembling
										var _prim_data		= [];
										var _prim_flags		= 0x00;
										var _vbuffer		= vertex_create_buffer();
										var _this_prim		= new GPrimitive(_this_mesh);
										var _vtx_id			= undefined;
										var _cache_defaults	= __gl_cache().defaults;
										var _cache_textures	= __gl_cache().textures;
																																						
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
															_prim_data[_data_type] = __gl_load_accessor(json_root, _acess_index);
														}
													}
												} break;
															
												case "indices": {
													_vtx_id = __gl_load_accessor(json_root, _prim.indices);
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
																
													// PBR
													var _pbr = GET_HASH(_matl, __hash_pbrMetallicRoughness);
													if !(is_undefined(_pbr)) {
																	
														// Base Color
														var _tex_ref					= GET_HASH(_pbr, __hash_baseColorTexture);
														if (_tex_ref != undefined) {
															_tex_id						= GET_HASH(_tex_ref, __hash_index)
															_this_matl.base_color_tex	= sprite_get_texture(json_root.textures[_tex_id], 0);
														} else {
															_this_matl.base_color_tex	= _cache_textures.base_color;
														}
																			
														var _c_val	= GET_HASH(_pbr, __hash_baseColorFactor) ?? _cache_defaults.color;
														_this_matl.base_color_fac = [
															// Gamma space convertion - readjust on shader
															power(_c_val[0], GLOADER_GAMMA),
															power(_c_val[1], GLOADER_GAMMA),
															power(_c_val[2], GLOADER_GAMMA),
															power(_c_val[3], GLOADER_GAMMA),
														]
																	
														// Metallic Roughness																			
														var _tex_ref					= GET_HASH(_pbr, __hash_metallicRoughnessTexture);
														if (_tex_ref != undefined) {
															_tex_id						= GET_HASH(_tex_ref, __hash_index)
															_this_matl.metal_rough_tex	= sprite_get_texture(json_root.textures[_tex_id], 0);
														} else {
															_this_matl.metal_rough_tex	= _cache_textures.metal_rough;
														}
																			
														_this_matl.metal_fac = GET_HASH(_pbr, __hash_metallicFactor) ?? _cache_defaults.metal;
														_this_matl.rough_fac = GET_HASH(_pbr, __hash_roughnessFactor) ?? _cache_defaults.roughness;
													}
																
													// Normal
													var _tex_ref					= GET_HASH(_matl, __hash_normalTexture);
													if (_tex_ref != undefined) {	
														_tex_id						= GET_HASH(_tex_ref, __hash_index)
														_this_matl.normal_tex		= sprite_get_texture(json_root.textures[_tex_id], 0);
													} else {						
														_this_matl.normal_tex		= _cache_textures.normal;
													}
																													
													// Occlusion
													var _tex_ref					= GET_HASH(_matl, __hash_occlusionTexture);
													if (_tex_ref != undefined) {
														_tex_id						= GET_HASH(_tex_ref, __hash_index)
														_this_matl.occlusion_tex	= sprite_get_texture(json_root.textures[_tex_id], 0);
													} else {
														_this_matl.occlusion_tex	= _cache_textures.occlusion;
													}
																
																
													// Emissive
													var _tex_ref					= GET_HASH(_matl, __hash_emissiveTexture);
													if (_tex_ref != undefined) {
														_tex_id						= GET_HASH(_tex_ref, __hash_index)
														_this_matl.emissive_tex	= sprite_get_texture(json_root.textures[_tex_id], 0);
													} else {
														_this_matl.emissive_tex	= _cache_textures.emissive;
													}
													_this_matl.emissive_fac	= _matl[$ "emissiveFactor"] ?? _cache_defaults.emissive;
																
													// Alpha
													_this_matl.alpha_mode	= _matl[$ "alphaMode"] ?? "OPAQUE";
													_this_matl.alpha_cutoff = _matl[$ "alphaCutoff"] ?? _cache_defaults.alpha_cutoff;
																
																
													// Extensions
													if !(is_undefined(_matl[$ "extensions"])) && false {
																	
														// Dirty base color
														var _tex_id		= _matl.extensions.KHR_materials_pbrSpecularGlossiness.diffuseTexture.index
														var _spr		= json_root.textures[_tex_id]
														_this_matl.base_color_tex = sprite_get_texture(_spr, 0)
																			
														// Dirty metalRough
														var _tex_id					= _matl.extensions.KHR_materials_pbrSpecularGlossiness.specularGlossinessTexture.index
														var _spr					= json_root.textures[_tex_id]
														_this_matl.metal_rough_tex	= sprite_get_texture(_spr, 0)
													}
																
													self.materials[$ _matl_name] = _this_matl
																
												} break;													
															
												case "mode": {
													// Primitive mode stuff
												} break;
																
												case "targets": {
																	
												} break;
											}
										}
																										
										// Mesh data collected, now assemble it
										vertex_begin(_vbuffer, __gl_cache().vform_PCNT)											
													
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
														
											var _prim_pos		= _prim_data[Attributes.Position]
											var _prim_color		= _flag_col		? _prim_data[Attributes.Color]		: _cache_defaults.color;
											var _prim_normal	= _flag_norm	? _prim_data[Attributes.Normal]		: _cache_defaults.normal;
											var _prim_texcoord	= _flag_uv		? _prim_data[Attributes.TexCoord]	: _cache_defaults.texcoord;
														
											var _id = 0;
											for (var _vtx = 0; _vtx < _arr_length; _vtx++) {
												_id = _is_indexed ? _vtx_id[_vtx] : _vtx;
	
												var _pos	= _prim_pos[_id]
												var _col	= _flag_col		? _prim_color[_id]		: _cache_defaults.color;
												var _norm	= _flag_norm	? _prim_normal[_id]		: _cache_defaults.normal;
												var _uv		= _flag_uv		? _prim_texcoord[_id]	: _cache_defaults.texcoord;
							
												var _col_rgb = (_col[2] * 0xff << 16) | (_col[1] * 0xff << 8) | (_col[0] * 0xff)
															
												vertex_position_3d(_vbuffer, _pos[0], _pos[1], _pos[2])
												vertex_color(_vbuffer, _col_rgb, _col[3] * 0xff)
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
									// Skeletal animation stuff
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
		
		
		// Model fully loaded
		is_loaded = true;
		
		// Clear stuff
		for (var i = 0; i < array_length(json_root.buffers); i++) {
			buffer_delete(json_root.buffers[i]);
		}
		delete json_root;
		
		//Loadtime tracing
		load_time = (get_timer() - load_time)/1_000;
		__gl_trace($"Scene loaded! Load time: {load_time}ms ({load_time/1_000}sec)");
		
		return self;
	}
	
	static Update = function() {
		
	}
	
	static Animate = function() {
		
	}
	
	static Submit = function(_mesh_name = undefined) {
		if (!is_loaded) return self;
		
		// Specific model in scene
		if (!is_undefined(_mesh_name)) {
			var _model_exists = false
			for (var i = array_length(meshes) - 1; i >= 0; --i)	{
				var _mesh = meshes[i];
				if (_mesh.name == _mesh_name) { // TODO: cache this index somehow
					_model_exists = true
					_mesh.Submit()
					break;
				}
			}
			if !(_model_exists) {
				//show_debug_message($"Couldn't find mesh \"{_mesh_name}\" in model \"{name}\". Rendering full scene.")
			} else {
				return self;
			}
		}

		// All models in scene
		for (var i = array_length(meshes) - 1; i >= 0; --i)	{
			meshes[i].Submit();
		}
		return self;
	}
	
	static Render = function() {
		
	}
	
	static Freeze = function() {
		for (var i = array_length(meshes) - 1; i >= 0; --i)	{
			meshes[i].Freeze();
		}
		return self;
	}

	static GetAABB = function() {
		return aabb;
	}
}