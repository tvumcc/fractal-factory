extends Node3D

class_name SierpinskiPyramidViewer

@export var settings: VBoxContainer
@export var dist: float = 1.0
@export var iterations: int = 7

var instance_idx: int = 0

var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0
@export_range(0.0, 1.0) var sensitivity: float = 0.25
		
func pyramid(n: int, pos: Vector3, scale: float):
	if n == 1:
		var trans: Transform3D = Transform3D()
		trans = trans.scaled(Vector3(scale, scale, scale))
		trans = trans.translated(pos)
		$MultiMeshInstance3D.multimesh.set_instance_color(instance_idx, Color(1.0, 0.5, 0.7))
		$MultiMeshInstance3D.multimesh.set_instance_transform(instance_idx, trans)
		
		instance_idx += 1
		return
		
	var scl = scale / 2.0
	pyramid(n-1, Vector3(pos.x + scl / 2.0, pos.y - scl / 2.0, pos.z - scl / 2.0), scl)
	pyramid(n-1, Vector3(pos.x + scl / 2.0, pos.y - scl / 2.0, pos.z + scl / 2.0), scl)
	pyramid(n-1, Vector3(pos.x - scl / 2.0, pos.y - scl / 2.0, pos.z - scl / 2.0), scl)
	pyramid(n-1, Vector3(pos.x - scl / 2.0, pos.y - scl / 2.0, pos.z + scl / 2.0), scl)
	pyramid(n-1, Vector3(pos.x, pos.y + scl / 2.0, pos.z), scl)

func _input(event):
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$MultiMeshInstance3D.position.z += 0.05
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$MultiMeshInstance3D.position.z -= 0.05

func load_pyramid():
	instance_idx = 0
	
	$MultiMeshInstance3D.multimesh.visible_instance_count = int(pow(5, iterations-1))
	pyramid(iterations, Vector3(0.0, 1.2, dist), 1.0)

func _on_iterations_slider_changed(value: float):
	iterations = int(value)
	settings.get_node("Iterations/Label").text = "Iterations: " + str(iterations)
	
	load_pyramid()

func _ready():
	settings.get_node("Iterations/HSlider").value_changed.connect(_on_iterations_slider_changed)
	settings.get_node("Iterations/Label").text = "Iterations: " + str(iterations)
	
	$MultiMeshInstance3D.multimesh.use_colors = true
	$MultiMeshInstance3D.multimesh.instance_count = int(pow(5, 8))
	load_pyramid()

func _process(delta):
	_update_mouselook()
	
func _update_mouselook():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		$Camera3D.rotate_y(deg_to_rad(-yaw))
		$Camera3D.rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))
