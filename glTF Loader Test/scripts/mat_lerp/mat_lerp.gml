/// @description mat_lerp(M1, M2, amount)
/// @param M1
/// @param M2
/// @param amount
function mat_lerp(argument0, argument1, argument2) {
	var M, M1, M2, t, i;
	M = array_create(16);
	M1 = argument0
	M2 = argument1
	t = argument2
	for (i = 0; i < 16; i ++)
	{
		M[i] = lerp(M1[i], M2[i], t);
	}
	mat_orthogonalize(M);
	return M;


}
