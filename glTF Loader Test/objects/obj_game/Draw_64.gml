
var _vcount = vertex_get_number(global.vbuff)


draw_text(16, 16+48, "glTF Loader v0.5")
draw_text(16, 32+48, $"Model containing {_vcount} vertices.")

var _string = self[$ "json_string"] ?? json_stringify(model, true)

draw_text(16, 64+48, _string)