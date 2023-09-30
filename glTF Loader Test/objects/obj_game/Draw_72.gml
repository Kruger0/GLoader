

var _view_mat = matrix_build_lookat(0, -40, 0, 0, 0, 0, 0, 0, 1);
var _proj_mat = matrix_build_projection_perspective_fov(60, 16/9, 0.1, 16000)
camera_set_view_mat(cam, _view_mat)
camera_set_proj_mat(cam, _proj_mat)
camera_apply(cam)
draw_clear_alpha(0, 0)
