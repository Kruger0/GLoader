/// @description mat_create(x, y, z, toX, toY, toZ, upX, upY, upZ, xScale, yScale, zScale)
/// @param x
/// @param y
/// @param z
/// @param toX
/// @param toY
/// @param toZ
/// @param upX
/// @param upY
/// @param upZ
/// @param xScale
/// @param yScale
/// @param zScale
function mat_create(argument0, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8, argument9, argument10, argument11) {
	//Creates a 4x4 matrix with the to-direction as master
	/*
	Script made by TheSnidr

	www.thesnidr.com
	*/
	var px, py, pz;
	px = argument0;
	py = argument1;
	pz = argument2;

	var toX, toY, toZ;
	toX = argument3;
	toY = argument4;
	toZ = argument5;

	var upX, upY, upZ;
	upX = argument6;
	upY = argument7;
	upZ = argument8;

	var scX, scY, scZ;
	scX = argument9;
	scY = argument10;
	scZ = argument11;

	var l, dot;

	//Normalize to-vector
	l = sqrt(sqr(toX) + sqr(toY) + sqr(toZ));
	if (l > 0)
	{
		l = 1 / l;
	}
	else
	{
		show_debug_message("ERROR in script mat_create: Supplied zero-length vector for to-vector.");
	}
	toX *= l;
	toY *= l;
	toZ *= l;

	//Orthogonalize up-vector to to-vector
	dot = upX * toX + upY * toY + upZ * toZ;
	upX -= toX * dot;
	upY -= toY * dot;
	upZ -= toZ * dot;

	//Normalize up-vector
	l = sqrt(sqr(upX) + sqr(upY) + sqr(upZ));
	if (l > 0)
	{
		l = 1 / l;
	}
	else
	{
		show_debug_message("ERROR in script mat_create: Supplied zero-length vector for up-vector, or the up- and to-vectors are parallel.");
	}
	upX *= l;
	upY *= l;
	upZ *= l;

	//Create side vector
	var siX, siY, siZ;
	siX = upY * toZ - upZ * toY;
	siY = upZ * toX - upX * toZ;
	siZ = upX * toY - upY * toX;

	//Return a 4x4 matrix
	return [toX * scX, toY * scX, toZ * scX, 0,
			siX * scY, siY * scY, siZ * scY, 0,
			upX * scZ, upY * scZ, upZ * scZ, 0,
			px,  py,  pz,  1];


}
