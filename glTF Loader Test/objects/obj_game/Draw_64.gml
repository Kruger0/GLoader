

var _vcount = model.vtx_count


var _text = 
$"glTF Loader v{__GLTF_VERSION}\n"+
$"Scene containing {_vcount} vertices."

draw_text_color(16+1, 96+1, _text, 0, 0, 0, 0, 1)
draw_text_color(16, 96, _text, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 1)
