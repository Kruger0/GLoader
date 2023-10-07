

cam.UpdateFree()
cam.Apply()
draw_clear_alpha(#40B0FF, 1)

gpu_set_ztestenable(false)
gpu_set_zwriteenable(false)

// Skybox pass - disable texrepeat to avoid seams
shader_set(shd_skybox)
	gpu_set_tex_repeat_ext(0, false)
	vertex_submit(vb_skybox, pr_trianglelist, sprite_get_texture(spr_cubemap, 0))
	gpu_set_tex_repeat_ext(0, true)
shader_reset()

gpu_set_ztestenable(true)
gpu_set_zwriteenable(true)
