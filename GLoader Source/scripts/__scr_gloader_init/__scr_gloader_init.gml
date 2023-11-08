
// Gloader - glTF Model Loader for GameMaker

#macro __GLOADER_VERSION	"0.9.0"
#macro __GLOADER_DATE		"11-2023"


#macro GET_HASH struct_get_from_hash
#macro SET_HASH variable_get_hash
#macro GAMMA 1/2.2


vertex_format_begin() {						// Size
	vertex_format_add_position_3d()			// 12
	vertex_format_add_color()				// 4
	vertex_format_add_normal()				// 12
	vertex_format_add_texcoord()			// 8
	global.vformat = vertex_format_end()	// --> 36
}
				    
#macro KEY_GLTF	0x46546C67
#macro KEY_JSON 0x4E4F534A
#macro KEY_BIN	0x004E4942

	
#macro SIZE_U32	4

//0x0AA10A0D474E5089 - I don't remember what is that but keep it there till I discover


enum Attributes {
	NONE,
	Position,
	Normal,
	Tangent,
	TexCoord,
	Color,
	Joints,
	Weights,
	SIZE,
}

enum Texture {
	BaseColor,
	Normal,
	MetallicRoughness,
	Occlusion,
	Emissive,
}
	
enum ComponentType {
	BYTE					= 5120,	// s8
	UNSIGNED_BYTE			= 5121,	// u8
	SHORT					= 5122,	// s16
	UNSIGNED_SHORT			= 5123,	// u16
	UNSIGNED_INT			= 5125,	// u32
	FLOAT					= 5126,	// f32
}
		
enum BufferViewTarget {
	ARRAY_BUFFER			= 34962,
	ELEMENT_ARRAY_BUFFER	= 34963,
}
	
enum PrimitiveMode {
	POINTS,
	LINES,
	LINE_LOOP,
	LINE_STRIP,
	TRIANGLES,
	TRIANGLE_LIST,
	TRIANGLE_FAN,
}

enum MagFilter {
	NEAREST = 9728,
	LINEAR	= 9729,
}
	
enum MinFilter {
	NEAREST					= 9728,
	LINEAR					= 9729,
	NEAREST_MIPMAP_NEAREST	= 9984,
	LINEAR_MIPMAP_NEAREST	= 9985,
	NEAREST_MIPMAP_LINEAR	= 9986,
	LINEAR_MIPMAP_LINEAR	= 9987,
}
	
enum Wrap {
	CLAMP_TO_EDGE			= 33071,
	MIRRORED_REPEAT			= 33648,
	REPEAT					= 10497,
}