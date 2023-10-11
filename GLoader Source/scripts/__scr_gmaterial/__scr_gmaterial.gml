
// Group of texture pointers
function GMaterial(_name = "gmatl") constructor {
	
	name			= _name;
	base_color_tex	= pointer_null;
	metal_rough_tex	= pointer_null;
	normal_tex		= pointer_null;
	occlusion_tex	= pointer_null;
	emissive_tex	= pointer_null;
	occlusion_tex	= pointer_null;
	
	base_color_fac	= [1, 1, 1, 1];
	metal_fac		= 1;
	rough_fac		= 1;
	emissive_fac	= [0, 0, 0];
	
	alpha_mode		= "OPAQUE";
	alpha_cutoff	= 0.5;
	double_sided	= false;
	
	static Delete = function() {
		return undefined;
	}
}