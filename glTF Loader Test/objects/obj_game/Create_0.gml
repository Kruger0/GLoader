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
]

var _index = 16

show_debug_overlay(true)

cam = camera_create()

model = new GModel().Load(_files[_index-2]+".gltf").Freeze()



gpu_set_cullmode(cull_noculling)
gpu_set_ztestenable(true)
gpu_set_zwriteenable(true)
gpu_set_texrepeat(true)













