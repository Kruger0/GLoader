
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
]

var _index = 8

show_debug_overlay(true)

cam = camera_create()

model = new GModel().Load(_files[_index]+".gltf").Freeze()













