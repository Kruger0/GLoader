


function camera_get_fov(proj_mat) {
	return radtodeg(arctan(1.0/proj_mat[5]) * 2.0);
}

function camera_get_aspect(proj_mat) {
	return proj_mat[5] / proj_mat[0];
}

function camera_get_far_plane(proj_mat) {
	return -proj_mat[14] / (proj_mat[10]-1);
}

function camera_get_near_plane(proj_mat) {
	return -2 * proj_mat[14] / (proj_mat[10]+1);
}

function display_get_aspect_ratio() {
	return display_get_width() / display_get_height();
}



function Camera3D(_x, _y, _z, _xto, _yto, _zto, _xup, _yup, _zup, _fov, _aspect, _znear, _zfar) constructor {
	pos		= new Vector3(_x, _y, _z)
	pos_to	= new Vector3(_x, _y, _z)
	to		= new Vector3(_xto, _yto, _zto)
	up		= new Vector3(_xup, _yup, _zup)
	vel		= new Vector3()
	
	fov = _fov
	aspect = _aspect
	znear = _znear 
	zfar = _zfar
	
	pitch = 0
	yaw = 0
	roll = 0
	
	targ_pitch = 0
	targ_yaw = 0
	targ_roll = 0
	
	freelook = false
	speed = 0.4
	speed_max = speed * 4
	acel = 0.07
	look_spd = 0.4
	sense = 12
	
	id = camera_create();		
	
	static UpdateFree = function() {
		var _d = new Vector3()		
		
		var _xmov = keyboard_check(ord("W")) - keyboard_check(ord("S"))
		var _ymov = keyboard_check(ord("D")) - keyboard_check(ord("A"))
		var _zmov = keyboard_check(vk_space) - keyboard_check(vk_shift)
		
		_d.x += dsin(yaw) * _ymov + dcos(yaw) * _xmov
		_d.y += dcos(yaw) * _ymov - dsin(yaw) * _xmov
		_d.z -= _zmov
		
		if (mouse_check_button_released(mb_middle)) {
			freelook ^= 1
		}
		
		
		if (freelook) {
			var _mx = window_get_width() / 2  - window_mouse_get_x() 
			var _my = window_get_height() / 2 - window_mouse_get_y() 
			targ_yaw += _mx / sense
			targ_pitch = clamp(targ_pitch + _my / sense, -89, 89)
			
			yaw += angle_difference(targ_yaw, yaw) * look_spd
			pitch += angle_difference(targ_pitch, pitch) * look_spd
			
			window_mouse_set(window_get_width() / 2, window_get_height() / 2)
		}
		
		_d.Multiply(keyboard_check(vk_lcontrol) ? speed_max : speed)
		vel.Lerp(_d, acel)		
		pos.Add(vel)
		
		to.x = pos.x + dcos(yaw) * dcos(pitch)
		to.y = pos.y - dsin(yaw) * dcos(pitch)
		to.z = pos.z - dsin(pitch)
	}
	
	static Apply = function() {
		var _view_mat = matrix_build_lookat(pos.x, pos.y, pos.z, to.x, to.y, to.z, up.x, up.y, up.z)
		var _proj_mat = matrix_build_projection_perspective_fov(fov, aspect, znear, zfar)
		
		camera_set_view_mat(id, _view_mat)
		camera_set_proj_mat(id, _proj_mat)
		camera_apply(id)
	}
	
	static GetViewMat = function() {
		return camera_get_view_mat(id)
	}
	
	static GetProjMat = function() {
		return camera_get_proj_mat(id)
	}
}

function Camera2D(_x, _y, _wid, _hei) constructor {
	pos = new Vector2(_x, _y)
	to = new Vector2(_x, _y)
	wid = _wid
	hei = _hei
	id = camera_create()
	
	static Update = function() {
		var _d = new Vector2(
			keyboard_check(ord("D")) - keyboard_check(ord("A")),
			keyboard_check(ord("S")) - keyboard_check(ord("W"))
		)
		var _spd = 2		
		pos.Add(_d.Multiply(_spd))
	}
	
	static Apply = function() {
		var _view_mat = matrix_build_lookat(pos.x, pos.y, -10, pos.x, pos.y, 0, 0, 1, 0)
		var _proj_mat = matrix_build_projection_ortho(wid, hei, 1, 32000)
		
		camera_set_view_mat(id, _view_mat)
		camera_set_proj_mat(id, _proj_mat)
		camera_apply(id)
	}
}