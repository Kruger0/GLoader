/// Quaternion scripts
/// 08/01/2023
/// @callmeEthan

function quaternion_identity()
{
	// Create a simple 1d array quaternion angle, with no rotation.
	return [0.00001,0,0,1]
}

function angle_to_quaternion(xangle, yangle, zangle)
{	
    // Convert Euler rotation angle to quaternion angle
    var cr = dcos(xangle * 0.5);
    var sr = dsin(xangle * 0.5);
    var cp = dcos(yangle * 0.5);
    var sp = dsin(yangle * 0.5);
    var cy = dcos(zangle * 0.5);
    var sy = dsin(zangle * 0.5);
	
	var q = array_create(4)
    q[0] = sr * cp * cy - cr * sp * sy;
    q[1] = cr * sp * cy + sr * cp * sy;
    q[2] = cr * cp * sy - sr * sp * cy;
    q[3] = cr * cp * cy + sr * sp * sy;

    return q;
}

function quaternion_multiply(R, S)
{ 
	// Multiply two quaternion and combine two rotation together.
	var Qx = R[3] * S[0] + R[0] * S[3] + R[1] * S[2] - R[2] * S[1];
	var Qy = R[3] * S[1] + R[1] * S[3] + R[2] * S[0] - R[0] * S[2];
	var Qz = R[3] * S[2] + R[2] * S[3] + R[0] * S[1] - R[1] * S[0];
	var Qw = R[3] * S[3] - R[0] * S[0] - R[1] * S[1] - R[2] * S[2];
	return [Qx, Qy, Qz, Qw]  
}

function quaternion_transform_vector(quat, x, y, z, array)
{
	// Rotate a vector by a quaternion angle
	// If an array is not supplied, return a new array.
	// https://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/transforms/index.htm
	var qx = quat[0]
	var qy = quat[1]
	var qz = quat[2]
	var qw = quat[3]
	if !is_undefined(array)
	{
		array[@0] = qw*qw*x + 2*qy*qw*z - 2*qz*qw*y + qx*qx*x + 2*qy*qx*y + 2*qz*qx*z - qz*qz*x - qy*qy*x;
		array[@1] = 2*qx*qy*x + qy*qy*y + 2*qz*qy*z + 2*qw*qz*x - qz*qz*y + qw*qw*y - 2*qx*qw*z - qx*qx*y;
		array[@2] = 2*qx*qz*x + 2*qy*qz*y + qz*qz*z - 2*qw*qy*x - qy*qy*z + 2*qw*qx*y - qx*qx*z + qw*qw*z;
		exit;
	}
	return [
		qw*qw*x + 2*qy*qw*z - 2*qz*qw*y + qx*qx*x + 2*qy*qx*y + 2*qz*qx*z - qz*qz*x - qy*qy*x,
		2*qx*qy*x + qy*qy*y + 2*qz*qy*z + 2*qw*qz*x - qz*qz*y + qw*qw*y - 2*qx*qw*z - qx*qx*y,
		2*qx*qz*x + 2*qy*qz*y + qz*qz*z - 2*qw*qy*x - qy*qy*z + 2*qw*qx*y - qx*qx*z + qw*qw*z
		]
}

function quaternion_rotate_local(q, xrot, yrot, zrot)
{
	// Rotate a quaternion around it's local axis.
	var rot = angle_to_quaternion(xrot, yrot, zrot)
	return quaternion_multiply(q, rot);
}


function quaternion_conjugate(q) 
{
	//	Return the conjugate of a quaternion 
	return [-q[0], -q[1], -q[2], q[3]];
}

function quaternion_inverse(q) 
{
	//	Same thing as quaternion conjugate, in case you don't know...
	return quaternion_conjugate(q);
}

function matrix_build_quaternion(x, y, z, quaternion, xscale, yscale, zscale)
{
	// Build transform matrix based on quaternion rotation instead of Euler angle
	// https://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToMatrix/index.htm
	var mat = array_create(16,0)
   var sqw = quaternion[3]*quaternion[3];
   var sqx = quaternion[0]*quaternion[0];
   var sqy = quaternion[1]*quaternion[1];
   var sqz = quaternion[2]*quaternion[2];
   mat[@0] = (sqx - sqy - sqz + sqw) * xscale; // since sqw + sqx + sqy + sqz =1
   mat[@5] = (-sqx + sqy - sqz + sqw) * yscale;
   mat[@10] = (-sqx - sqy + sqz + sqw) * zscale;
   
   var tmp1 = quaternion[0]*quaternion[1];
   var tmp2 = quaternion[2]*quaternion[3];
   mat[@1] = 2.0 * (tmp1 + tmp2) * xscale;
   mat[@4] = 2.0 * (tmp1 - tmp2) * yscale;
   
   tmp1 = quaternion[0]*quaternion[2];
   tmp2 = quaternion[1]*quaternion[3];
   mat[@2] = 2.0 * (tmp1 - tmp2) * xscale;
   mat[@8] = 2.0 * (tmp1 + tmp2) * zscale;
   
   tmp1 = quaternion[1]*quaternion[2];
   tmp2 = quaternion[0]*quaternion[3];
   mat[@6] = 2.0 * (tmp1 + tmp2) * yscale;
   mat[@9] = 2.0 * (tmp1 - tmp2) * zscale;
	
	mat[@12] = x;
	mat[@13] = y;
	mat[@14] = z;
	mat[@15] = 1.0;
	return mat
}