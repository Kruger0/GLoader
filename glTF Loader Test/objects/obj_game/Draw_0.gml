


var _rot = current_time/60
var _scl = 16
var _mat = matrix_build(0, 0, 0, 90, 0, _rot, _scl, _scl, _scl)
matrix_set(matrix_world, _mat)


shader_set(shd_passthrough)
texture_set_stage(shader_get_sampler_index(shd_passthrough, "u_tex_enviroment"), sprite_get_texture(spr_cubemap, 0))

model.Submit()
shader_reset()


matrix_set(matrix_world, matrix_build_identity())
