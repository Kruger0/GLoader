var _files = [
	"Box",
	"BoxInterleaved",
	"BoxTextured",
	"BoxTexturedNonPowerOfTwo",
	"BoxWithSpaces/Box With Spaces",
	"BoxVertexColors",
	"Cube/Cube",
	"AnimatedCube/AnimatedCube",
	"CubeWithTransform",
	"scene",
	"2CylinderEngine",
	"BoxAnimated",
	"AnimatedTriangle",
	"CubeRotated",
	"Shapes",
	"DamagedHelmet",
	"poco",
	"Suzane",
	"Sphere",
	"Sponza/Sponza",
	"Sponza2",
	"Parent",
]

var _index = 23
model = new GModel().Load(_files[_index-2]+".gltf").Freeze()

show_debug_overlay(true)
window_set_cursor(cr_none)


cam = new Camera3D(-50, 0, 0, 0, 0, 1, 0, 0, 1, 70, 16/9, 1, 16000)


gpu_set_cullmode(cull_clockwise)
gpu_set_texrepeat(true)


// Skybox
vertex_format_begin()
vertex_format_add_position_3d()
vformat_skybox = vertex_format_end()

vb_skybox = vertex_create_buffer()
vertex_begin(vb_skybox, vformat_skybox)
var _0 = -10
var _1 = 10
//							   x | y | z
// B
vertex_position_3d(vb_skybox, _0, _0, _0)
vertex_position_3d(vb_skybox, _1, _0, _0)
vertex_position_3d(vb_skybox, _0, _1, _0)
vertex_position_3d(vb_skybox, _0, _1, _0)
vertex_position_3d(vb_skybox, _1, _0, _0)
vertex_position_3d(vb_skybox, _1, _1, _0)
// T
vertex_position_3d(vb_skybox, _0, _0, _1)
vertex_position_3d(vb_skybox, _0, _1, _1)
vertex_position_3d(vb_skybox, _1, _0, _1)
vertex_position_3d(vb_skybox, _1, _0, _1)
vertex_position_3d(vb_skybox, _0, _1, _1)
vertex_position_3d(vb_skybox, _1, _1, _1)
// N
vertex_position_3d(vb_skybox, _0, _0, _1)
vertex_position_3d(vb_skybox, _1, _0, _1)
vertex_position_3d(vb_skybox, _0, _0, _0)
vertex_position_3d(vb_skybox, _0, _0, _0)
vertex_position_3d(vb_skybox, _1, _0, _1)
vertex_position_3d(vb_skybox, _1, _0, _0)
// S
vertex_position_3d(vb_skybox, _1, _1, _1)
vertex_position_3d(vb_skybox, _0, _1, _1)
vertex_position_3d(vb_skybox, _1, _1, _0)
vertex_position_3d(vb_skybox, _1, _1, _0)
vertex_position_3d(vb_skybox, _0, _1, _1)
vertex_position_3d(vb_skybox, _0, _1, _0)
// E
vertex_position_3d(vb_skybox, _0, _1, _1)
vertex_position_3d(vb_skybox, _0, _0, _1)
vertex_position_3d(vb_skybox, _0, _1, _0)
vertex_position_3d(vb_skybox, _0, _1, _0)
vertex_position_3d(vb_skybox, _0, _0, _1)
vertex_position_3d(vb_skybox, _0, _0, _0)
// W
vertex_position_3d(vb_skybox, _1, _0, _1)
vertex_position_3d(vb_skybox, _1, _1, _1)
vertex_position_3d(vb_skybox, _1, _0, _0)
vertex_position_3d(vb_skybox, _1, _0, _0)
vertex_position_3d(vb_skybox, _1, _1, _1)
vertex_position_3d(vb_skybox, _1, _1, _0)

vertex_end(vb_skybox)
vertex_freeze(vb_skybox)




