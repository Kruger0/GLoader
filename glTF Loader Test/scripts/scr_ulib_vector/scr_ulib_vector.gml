
///@func Vector2([x], [y])
function Vector2(_x = 0, _y = _x) constructor {
	x = _x;
	y = _y;
	xstart  = _x
	ystart  = _y
	
	static Set = function() {
		x = argument[0][$ "x"] ?? argument[0];
		y = argument[0][$ "y"] ?? (argument[1] ?? argument[0]);
		return self;
	}	
	static Reset = function() {
		if (instanceof(self) == "Vector2") {
			x = xstart;
			y = ystart;
			return self;
		} else {
			return new Vector2(xstart, ystart);
		}
	}
	static Zero = function() {
		x = 0;
		y = 0;
		return self;		
	}
	static Negate = function() {
		if (instanceof(self) == "Vector2") {
			x = -x;
			y = -y;
			return self;
		} else {
			return new Vector2(-x, -y);
		}
	}
		
	static Add = function() {
		if (instanceof(self) == "Vector2") {
			x += argument[0][$ "x"] ?? argument[0];
			y += argument[0][$ "y"] ?? (argument[1] ?? argument[0]);
			return self
		} else {
			return new Vector2(
				argument[0].x + argument[1][$ "x"] ?? argument[1], 
				argument[0].y + argument[1][$ "y"] ?? (argument[2] ?? argument[1])
			);
		}
	}
	static Subtract = function() {
		if (instanceof(self) == "Vector2") {
			x -= argument[0][$ "x"] ?? argument[0];
			y -= argument[0][$ "y"] ?? (argument[1] ?? argument[0]);
			return self
		} else {
			return new Vector2(
				argument[0].x - argument[1][$ "x"] ?? argument[1], 
				argument[0].y - argument[1][$ "y"] ?? (argument[2] ?? argument[1])
			);
		}
	}	
	static Multiply = function() {
		if (instanceof(self) == "Vector2") {
			x *= argument[0][$ "x"] ?? argument[0];
			y *= argument[0][$ "y"] ?? (argument[1] ?? argument[0]);
			return self
		} else {
			return new Vector2(
				argument[0].x * argument[1][$ "x"] ?? argument[1], 
				argument[0].y * argument[1][$ "y"] ?? (argument[2] ?? argument[1])
			);
		}
	}	
	static Divide = function() {
		if (instanceof(self) == "Vector2") {
			x /= argument[0][$ "x"] ?? argument[0];
			y /= argument[0][$ "y"] ?? (argument[1] ?? argument[0]);
			return self
		} else {
			return new Vector2(
				argument[0].x / argument[1][$ "x"] ?? argument[1], 
				argument[0].y / argument[1][$ "y"] ?? (argument[2] ?? argument[1])
			);
		}
	}
	
	static GetMagnitude = function() {
		if (instanceof(self) == "Vector2") {
			return sqrt((x * x) + (y * y));
		} else {
			return argument[0].GetMagnitude()
		}
	}	
	static GetDirection = function() {
		return point_direction(0, 0, x, y)
	}
	static DistanceTo = function(_vector) {
		return sqrt(sqr(x - _vector.x) + sqrt(y - _vector.y));
	}
	static Normalize = function() {
		if ((x != 0) || (y != 0)) {
			var _factor = 1/sqrt((x * x) + (y * y));
			x = _factor * x;
			y = _factor * y;
		}
		return self;
	}
	static SetMagnitude = function() {
		if (instanceof(self) == "Vector2") {
			Normalize();
			Multiply(argument[0]);
			return self;
		} else {
			return new Vector3(argument[0]).SetMagnitude(argument[1]);
		}		
	}	
	static SetDirection = function(_dir) {
		var _mag = GetMagnitude()
		x = dcos(_dir) * _mag
		y = -dsin(_dir) * _mag
	}
	static LimitMagnitude = function(_limit) {
		if (GetMagnitude() > _limit) {
			SetMagnitude(_limit);
		}
		return self;
	}
	static Dot = function(_vector) {
		return (x * _vector.x + y * _vector.y);
	}
	static Cross = function(_vector) {
		return (x * _vector.y - y * _vector.x);
	}
		
	static Lerp = function(_vector, _amount) {
		x = lerp(x, _vector.x, _amount);
		y = lerp(y, _vector.y, _amount);
		return self;
	}	
	static LerpReset = function(_amount) {
		x = lerp(x, xstart, _amount);
		y = lerp(y, ystart, _amount);
		return self;
	}
	static LerpDirection = function(_dest, _amt) {
		var _vec_dir = GetDirection()
		var _max, _da, _result;
		_max = 360;
		_da = (_dest - _vec_dir) % _max;
		_result = 2 * _da % _max - _da;

		var _dir = _vec_dir + _result * _amt;		
		
		SetDirection(_dir)
		return self;
	}
	static LerpLength = function(_dest, _amt) {
		SetMagnitude(lerp(GetMagnitude(), _dest, _amt))
		return self;
	}
	static Lengthdir = function() {
		if (instanceof(self) == "Vector2") {
			return new Vector2(GetMagnitude(), GetDirection())
		} else {
			var _x = lengthdir_x(argument[0], argument[1]);
			var _y = lengthdir_y(argument[0], argument[1]);
			return new Vector2(_x, _y)
		}
	}
	static Copy = function() {
		if (instanceof(self) == "Vector2") {
			return new Vector2(x, y)
		} else {
			return new Vector2(argument[0].x, argument[0].y)
		}
	}
	static ToString = function() {
		if (instanceof(self) == "Vector2") {
			return {
				x : x, 
				y : y, 
			}
		} else {
			return argument[0].ToString()
		}
		
	}
}

///@func Vector3([x], [y], [z])
function Vector3(_x = 0, _y = 0, _z = 0) constructor {
	x = _x;
	y = _y;
	z = _z;
	
	xstart = _x;
	ystart = _y;
	zstart = _z;
	
	static Set = function(_x, _y, _z) {
		x = _x;
		y = _y;
		z = _z;
		return self;
	}	
	static Reset = function() {
		x = xstart;
		y = ystart;
		z = zstart;
		return self;
	}
	static GetStart = function() {
		return new Vector3(xstart, ystart, zstart);
	}
	static Zero = function() {
		x = 0;
		y = 0;
		z = 0;
	}
	static Negate = function() {
		if (instanceof(self) == "Vector3") {
			x = -x;
			y = -y;
			z = -z;
			return self;
		} else {
			return new Vector3(-argument[0].x, -argument[0].y, -argument[0].z)
		}		
	}
	static Add = function(_vector) {
		if (instanceof(self) == "Vector3") {
			x += _vector.x
			y += _vector.y
			z += _vector.z
			return self
		} else {
			return new Vector3(_vector.x + argument[1].x, _vector.y + argument[1].y, _vector.z + argument[1].z)
		}
	}
	static Subtract = function(_vector) {
		if (instanceof(self) == "Vector3") {
			x -= _vector.x
			y -= _vector.y
			z -= _vector.z
			return self
		} else {
			return new Vector3(_vector.x - argument[1].x, _vector.y - argument[1].y, _vector.z - argument[1].z)
		}
	}	
	static Multiply = function(_scalar) {
		if (instanceof(self) == "Vector3") {
			x *= _scalar
			y *= _scalar
			z *= _scalar
			return self
		} else {
			return new Vector3(argument[0].x * argument[1], argument[0].y * argument[1], argument[0].z * argument[1])
		}
	}	
	static Divide = function(_scalar) {
		if (instanceof(self) == "Vector3") {
			x /= _scalar
			y /= _scalar
			z /= _scalar
			return self
		} else {
			return new Vector3(argument[0].x / argument[1], argument[0].y / argument[1], argument[0].z / argument[1])
		}
	}
	
	static DistanceTo = function(_vector) {
		return point_distance_3d(_vector.x, _vector.y, _vector.z, x, y, z)
	}
	static GetMagnitude = function() {
		if (instanceof(self) == "Vector3") {
			return sqrt((x * x) + (y * y) + (z * z));
		} else {
			return 
		}
	}
	static GetYaw = function() {
		return point_direction(0, 0, x, y);
	}
	static GetPitch = function() {
		return point_direction(0, 0, y, z);
	}
	static GetRoll = function() {
		return point_direction(0, 0, x, z);
	}
	static Normalize = function() {
		if (instanceof(self) == "Vector3") {
			if ((x != 0) || (y != 0)) {
				var _factor = GetMagnitude();
				x /= _factor;
				y /= _factor;
				z /= _factor;
			}
			return self;
		} else {
			return new Vector3(argument[0].x, argument[0].y, argument[0].z).Normalize()
		}
	}
	static Transform = function() {
		var _v = matrix_transform_vertex(argument[0], x, y, z)
		x = _v[0]
		y = _v[1]
		z = _v[2]
		return self;
	}
	static Rotate = function() {
		var _m = matrix_build(0, 0, 0, argument[0], argument[1], argument[2], 1, 1, 1)
		var _v = matrix_transform_vertex(_m, x, y, z)
		x = _v[0]
		y = _v[1]
		z = _v[2]
		return self;
	}
	static SetMagnitude = function() {
		if (instanceof(self) == "Vector3") {
			Normalize();
			Multiply(argument[0]);
			return self;
		} else {
			return new Vector3(argument[0]).SetMagnitude(argument[1]);
		}		
	}
	static LimitMagnitude = function(_limit) {
		if (GetMagnitude() > _limit) {
			SetMagnitude(_limit);
		}
		return self;
	}
	static Dot = function(_vector) {
		return (x * _vector.x + y * _vector.y + z * _vector.z)
	}
	static Cross = function(_vector) {
		return new Vector3(
            (y*_vector.z)-(z*_vector.y),
            (z*_vector.x)-(x*_vector.z),
            (x*_vector.y)-(y*_vector.x)
        ); 
	}
	static Lerp = function(_vector, _amount) {
		x = lerp(x, _vector.x, _amount);
		y = lerp(y, _vector.y, _amount);
		z = lerp(z, _vector.z, _amount);
		return self;
	}	
	static LerpReset = function(_amount) {
		x = lerp(x, xstart, _amount);
		y = lerp(y, ystart, _amount);
		z = lerp(z, zstart, _amount);
		return self;
	}
	static LerpYaw = function(_dest, _amt) {
		var _vec_dir = GetYaw()
		var _max, _da, _result;
		_max = 360;
		_da = (_dest - _vec_dir) % _max;
		_result = 2 * _da % _max - _da;

		var _dir = _vec_dir + _result * _amt;		
		
		SetDirection(_dir)
		return self;
	}
	static LerpLength = function(_dest, _amt) {
		SetMagnitude(lerp(GetMagnitude(), _dest, _amt))
		return self;
	}
	//static lengthdir = function() {
	//	if (instanceof(self) == "Vector3") {
	//		return new Vector3(get_magnitude(), get_direction())
	//	} else {
	//		var _x = lengthdir_x(argument[0], argument[1]);
	//		var _y = lengthdir_y(argument[0], argument[1]);
	//		return new Vector3(_x, _y)
	//	}
	//}
	static Copy = function() {
		if (instanceof(self) == "Vector3") {
			return new Vector3(x, y, z)
		} else {
			return new Vector3(argument[0].x, argument[0].y, argument[0].z)
		}
	}
	static ToString = function() {
		return string("x: {0}, y: {1}, z: {2}", x, y, z)
	}
	static ToArray = function() {
		if (instanceof(self) == "Vector3") {
			return [x, y, z]
		} else {
			return [argument[0].x, argument[0].y, argument[0].z]
		}
	}
}