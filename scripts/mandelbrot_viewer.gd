extends Node2D

class_name MandelbrotViewer

@export var settings: VBoxContainer

@export var pos = Vector2(0.0, 0.0);
@export var zoom = 1.0;
@export var aspect_ratio = 1.0;
@export var iterations = 40
@export var order = 2
@export var brightness: float = 1.0
@export var starting_color: Vector3
@export var ending_color: Vector3

var hue = 0

var drag: bool = false
var last_mouse_pos: Vector2
var mouse_inside = false
var drag_inhibit = false

func load_uniforms():
	$TextureRect.material.set_shader_parameter("aspect_ratio", aspect_ratio)
	$TextureRect.material.set_shader_parameter("zoom", zoom)
	$TextureRect.material.set_shader_parameter("pos", pos)
	$TextureRect.material.set_shader_parameter("iterations", iterations)
	$TextureRect.material.set_shader_parameter("order", order)
	$TextureRect.material.set_shader_parameter("brightness", brightness)
	
	$TextureRect.material.set_shader_parameter("starting_color", starting_color)
	$TextureRect.material.set_shader_parameter("ending_color", ending_color)

func _on_iterations_slider_changed(value: float):
	iterations = int(value)
	settings.get_node("Iterations/Label").text = "Iterations: " + str(iterations)
	
func _on_order_slider_changed(value: float):
	order = int(value)
	settings.get_node("Order/Label").text = "Order: " + str(order)
	
func _on_brightness_slider_changed(value: float):
	brightness = value
	settings.get_node("Brightness/Label").text = "Brightness: " + str(brightness)
func _on_starting_color_changed(color: Color):
	starting_color = Vector3(color.r, color.g, color.b)
func _on_ending_color_changed(color: Color):
	ending_color = Vector3(color.r, color.g, color.b)

func _ready():
	iterations = settings.get_node("Iterations/HSlider").value
	order = settings.get_node("Order/HSlider").value
	brightness = settings.get_node("Brightness/HSlider").value
	var scolor: Color = settings.get_node("StartingColor/ColorPickerButton").color
	starting_color = Vector3(scolor.r, scolor.g, scolor.b)
	var ecolor: Color = settings.get_node("EndingColor/ColorPickerButton").color
	ending_color = Vector3(ecolor.r, ecolor.g, ecolor.b)
	
	settings.get_node("Iterations/Label").text = "Iterations: " + str(iterations)
	settings.get_node("Order/Label").text = "Order: " + str(order)
	settings.get_node("Brightness/Label").text = "Brightness: " + str(brightness)
	settings.get_node("Iterations/HSlider").value_changed.connect(_on_iterations_slider_changed)
	settings.get_node("Order/HSlider").value_changed.connect(_on_order_slider_changed)
	settings.get_node("Brightness/HSlider").value_changed.connect(_on_brightness_slider_changed)
	settings.get_node("StartingColor/ColorPickerButton").color_changed.connect(_on_starting_color_changed)
	settings.get_node("EndingColor/ColorPickerButton").color_changed.connect(_on_ending_color_changed)

func _input(event):
	if mouse_inside:
		if event is InputEventMouseButton and event.is_pressed():
			last_mouse_pos = event.position
			drag = true
		if event is InputEventMouseMotion and drag and not drag_inhibit:
			var cur_pos = event.position
			var diff: Vector2  = last_mouse_pos - cur_pos
			diff.x /= -$TextureRect.size.x
			diff.y /= $TextureRect.size.y
			pos += diff * zoom
			last_mouse_pos = cur_pos
		if event is InputEventMouseButton and event.is_released():
			drag = false
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom *= 0.95
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom /= 0.95

func _process(delta):
	$TextureRect.size = get_viewport_rect().size
	load_uniforms()
	aspect_ratio = float($TextureRect.size.x) / float($TextureRect.size.y)
	if not settings.get_node("CheckBox").button_pressed:
		var ecolor: Color = settings.get_node("EndingColor/ColorPickerButton").color
		ending_color = Vector3(ecolor.r, ecolor.g, ecolor.b)

func _on_mouse_entered():
	mouse_inside = true

func _on_mouse_exited():
	drag = false
	mouse_inside = false

func _on_timer_timeout():
	if settings.get_node("CheckBox").button_pressed:
		hue = (hue + 1) % 256
		var col = Color.from_hsv(hue / 255.0, 1.0, 1.0)
		ending_color = Vector3(col.r, col.g, col.b)
