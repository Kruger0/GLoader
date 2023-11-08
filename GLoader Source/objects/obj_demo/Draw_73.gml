
// Skybox pass - disable texrepeat to avoid seams

shader_set(__shd_skybox)
gpu_set_tex_repeat_ext(0, false)
//gpu_set_tex_filter_ext(0, false)
vertex_submit(vb_skybox, pr_trianglelist, sprite_get_texture(array_last(env_lod), 0));
gpu_set_tex_repeat_ext(0, true)
//gpu_set_tex_filter_ext(0, true)

shader_reset()
matrix_reset()
gpu_set_cullmode(cull_noculling)


