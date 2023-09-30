



var _rot = current_time/30

gpu_set_cullmode(cull_noculling)
gpu_set_ztestenable(true)
gpu_set_zwriteenable(true)
gpu_set_texrepeat(true)


var _scl = 15
matrix_set(matrix_world, matrix_build(0, 0, 00, 90, _rot, 0, _scl, -_scl, _scl))
shader_set(shd_passthrough)

vertex_submit(global.vbuff, pr_trianglelist, global.tex);
//vertex_submit(model, pr_trianglelist, -1)



shader_reset()

//draw_sprite(spr_a, 0, 10, 10)


matrix_set(matrix_world, matrix_build_identity())

