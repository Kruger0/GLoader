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
	"Parent2",
	"SimpleMeshes",
	"motore",
	"materials",
	"MetalRoughSpheres",
	"MetalRoughSpheresNoTextures",
	"materials3",
	"link",
]

var _index = 16
model = new GModel().Load(_files[_index-2]+".gltf").Freeze()
//model = new GModel().Load("Parent2.gltf").Freeze()

show_debug_overlay(true)
window_set_cursor(cr_none)


cam = new Camera3D(-50, 0, 0, 0, 0, 1, 0, 0, 1, 70, 16/9, 0.5, 16000)


u_tex_environment = shader_get_sampler_index(shd_passthrough, "u_tex_environment")
tex_environment = sprite_get_texture(spr_environment, 0)


gpu_set_ztestenable(true)
gpu_set_zwriteenable(true)
gpu_set_texrepeat(true)
gpu_set_tex_filter(true)



// Skybox - more like skyoctahedron
vertex_format_begin()
vertex_format_add_position_3d()
vformat_skybox = vertex_format_end()

vb_skybox = vertex_create_buffer()
vertex_begin(vb_skybox, vformat_skybox)

vertex_position_3d(vb_skybox, 00, 00, 05)
vertex_position_3d(vb_skybox, 05, 05, 00)
vertex_position_3d(vb_skybox, 05, -5, 00)

vertex_position_3d(vb_skybox, 00, 00, 05)
vertex_position_3d(vb_skybox, -5, 05, 00)
vertex_position_3d(vb_skybox, 05, 05, 00)

vertex_position_3d(vb_skybox, 00, 00, 05)
vertex_position_3d(vb_skybox, -5, -5, 00)
vertex_position_3d(vb_skybox, -5, 05, 00)

vertex_position_3d(vb_skybox, 00, 00, 05)
vertex_position_3d(vb_skybox, 05, -5, 00)
vertex_position_3d(vb_skybox, -5, -5, 00)

vertex_position_3d(vb_skybox, 00, 00, -5)
vertex_position_3d(vb_skybox, 05, -5, 00)
vertex_position_3d(vb_skybox, 05, 05, 00)

vertex_position_3d(vb_skybox, 00, 00, -5)
vertex_position_3d(vb_skybox, 05, 05, 00)
vertex_position_3d(vb_skybox, -5, 05, 00)

vertex_position_3d(vb_skybox, 00, 00, -5)
vertex_position_3d(vb_skybox, -5, 05, 00)
vertex_position_3d(vb_skybox, -5, -5, 00)

vertex_position_3d(vb_skybox, 00, 00, -5)
vertex_position_3d(vb_skybox, -5, -5, 00)
vertex_position_3d(vb_skybox, 05, -5, 00)

vertex_end(vb_skybox)
vertex_freeze(vb_skybox)




