
// Skybox pass - disable texrepeat to avoid seams

shader_set(shd_skybox)
gpu_set_tex_repeat_ext(0, false)
vertex_submit(vb_skybox, pr_trianglelist, sprite_get_texture(spr_environment, 0))
gpu_set_tex_repeat_ext(0, true)


shader_reset()
matrix_reset()
gpu_set_cullmode(cull_noculling)


