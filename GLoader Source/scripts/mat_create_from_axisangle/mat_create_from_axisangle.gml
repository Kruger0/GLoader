/// @description mat_create_from_axisangle(v[3], angle)
/// @param v[3]
/// @param angle
function mat_create_from_axisangle(argument0, argument1) {
	//Creates a rotation matrix

	// get the sin and cos of the angle passed in
	var c = dcos(-argument1);
	var s = dsin(-argument1);
	var omc = 1 - c;

	// normalise the input vector
	var v = argument0;
	var length = sqrt(sqr(v[0]) + sqr(v[1]) + sqr(v[2]));
	v[0] /= length;
	v[1] /= length;
	v[2] /= length;

	// build the rotation matrix
	var mT = array_create(16);
	mT[15] = 1;
	mT[0] = omc * v[0] * v[0] + c;
	mT[1] = omc * v[0] * v[1] + s * v[2];
	mT[2] = omc * v[0] * v[2] - s * v[1];

	mT[4] = omc * v[0] * v[1] - s * v[2];
	mT[5] = omc * v[1] * v[1] + c;
	mT[6] = omc * v[1] * v[2] + s * v[0];

	mT[8] = omc * v[0] * v[2] + s * v[1];
	mT[9] = omc * v[1] * v[2] - s * v[0];
	mT[10] = omc * v[2] * v[2] + c;

	return mT;


}
