
scale += (keyboard_check(vk_up) - keyboard_check(vk_down))*0.5


var _rot = -60+180//current_time/60
var _scl = scale;
var _mat = matrix_build(0, 0, 0, 90, 0, _rot, _scl, _scl, _scl)
matrix_set(matrix_world, _mat)

shader_set(__shd_passthrough)
gpu_set_tex_repeat_ext(u_tex_environment, false)
texture_set_stage(u_tex_environment, tex_environment)

//gpu_set_cullmode(cull_noculling)
model.Submit(); // full scene

//matrix_set_world(0, 0, 40, 90, 0, _rot, _scl, _scl, _scl)

//model.Submit("Sphere")

//matrix_set_world(0, 0, -40, 90, 0, _rot, _scl, _scl, _scl)

//model.Submit("Cube")

//matrix_set_world(0, 40, -40, 90, 0, _rot, _scl, _scl, _scl)

//model.Submit("Ball")

matrix_reset()

