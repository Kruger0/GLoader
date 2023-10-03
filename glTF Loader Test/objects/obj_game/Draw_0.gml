


var _rot = current_time/30
var _scl = 10
var _mat = matrix_build(0, 0, 0, 90, 0, _rot, (dsin(_rot)*0.5+0.8)*_scl, _scl, (dcos(_rot)*0.5+0.8)*_scl)
matrix_set(matrix_world, _mat)



shader_set(shd_passthrough)
model.Submit()
shader_reset()



matrix_set(matrix_world, matrix_build_identity())

