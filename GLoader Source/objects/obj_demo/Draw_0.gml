


var _rot = -60+180//current_time/60
var _scl = 10;
var _mat = matrix_build(0, 0, 0, 90, 0, _rot, _scl, _scl, _scl)
matrix_set(matrix_world, _mat)

shader_set(shd_passthrough)
gpu_set_tex_repeat_ext(u_tex_environment, false)
texture_set_stage(u_tex_environment, tex_environment)

model.Submit()

