extends Node3D

class_name MengerSpongeViewer

@export var settings: VBoxContainer
@export var dist: float = 1.0
@export var iterations: int = 5

var instance_idx: int = 0

var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0
@export_range(0.0, 1.0) var sensitivity: float = 0.25

func menger(n: int, pos: Vector3, scale: float):
	if n == 1:
		var trans: Transform3D = Transform3D()
		trans = trans.scaled(Vector3(scale, scale, scale))
		trans = trans.translated(pos)
		$MultiMeshInstance3D.multimesh.set_instance_transform(instance_idx, trans)
		instance_idx += 1
		return
	
	var scl = scale / 3.0
	var dx = [scl, -scl, scl, -scl, scl, 0.0, -scl, 0.0]
	var dy = [scl, -scl, -scl, scl, 0.0, scl, 0.0, -scl]
	
	for i in range(8): # Front
		menger(n-1, Vector3(pos.x + dx[i], pos.y + dy[i], pos.z - scl), scl)
	for i in range(4): # Middle
		menger(n-1, Vector3(pos.x + dx[i], pos.y + dy[i], pos.z), scl)
	for i in range(8): # Back
		menger(n-1, Vector3(pos.x + dx[i], pos.y + dy[i], pos.z + scl), scl)

func load_menger():
	instance_idx = 0
	
	$MultiMeshInstance3D.multimesh.visible_instance_count = int(pow(20, iterations-1))
	menger(iterations, Vector3(0.0, 1.0, dist), 1.0)

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
			
func _on_iterations_slider_changed(value: float):
	iterations = int(value)
	settings.get_node("Iterations/Label").text = "Iterations: " + str(iterations)
	
	load_menger()

func _ready():
	settings.get_node("Iterations/HSlider").value_changed.connect(_on_iterations_slider_changed)
	settings.get_node("Iterations/Label").text = "Iterations: " + str(iterations)
	
	$MultiMeshInstance3D.multimesh.instance_count = int(pow(20,5))
	load_menger()

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
