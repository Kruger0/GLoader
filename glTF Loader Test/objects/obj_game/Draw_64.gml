
var _vcount = model.vtx_count

gpu_set_ztestenable(false)
gpu_set_zwriteenable(false)

matrix_set(matrix_world, matrix_build_identity())
shader_reset()

draw_text(16, 16+48, "glTF Loader v"+__GLTF_VERSION)
draw_text(16, 32+48, $"Scene containing {_vcount} vertices.")

