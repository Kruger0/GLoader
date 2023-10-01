
var _rot = current_time/30

gpu_set_cullmode(cull_noculling)
gpu_set_ztestenable(true)
gpu_set_zwriteenable(true)
gpu_set_texrepeat(true)


var _scl = 15
matrix_set(matrix_world, matrix_build(0, 0, 0, 90, _rot, 0, _scl, -_scl, _scl))
shader_set(shd_passthrough)


model.Submit()



shader_reset()

//draw_sprite(spr_a, 0, 10, 10)


matrix_set(matrix_world, matrix_build_identity())

