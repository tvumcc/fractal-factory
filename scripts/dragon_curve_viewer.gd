extends Node2D

class_name DragonCurveViewer

@export var settings: VBoxContainer

var variables = ["F", "G"]
var constants = ["+", "-"]
var rules = ["F+G", "F-G"]
var angle = 90.0
var levels = []

@export var pos: Vector2 = Vector2(500.0, 600.0)
@export var theta: float = 0.0
@export var line_length = 40.0
@export var iterations: int = 6

func _draw():
	var cur_theta = theta
	var cur_pos = pos
	
	for i in range(len(levels[iterations])):
		if levels[iterations][i] == variables[0] or levels[iterations][i] == variables[1]:
			var new_pos = Vector2(cur_pos.x + (line_length * cos(deg_to_rad(cur_theta))), cur_pos.y + (line_length * sin(deg_to_rad(cur_theta))))
			draw_line(cur_pos, new_pos, Color(0.4, 0.8, 0.6), 2.0)
			cur_pos = new_pos
		elif levels[iterations][i] == constants[0]:
			cur_theta += angle
		elif levels[iterations][i] == constants[1]:
			cur_theta -= angle

func dragon_curve(n: int, start: String) -> String:
	if n == 0: return variables[0]
	if n == 1:
		if start == variables[0]: return rules[0]
		else: return rules[1]
	
	var total: String = dragon_curve(n-1, start)
	var out: String = ""
	for i in range(len(total)):
		if total[i] == variables[0]:
			out = out + rules[0]
		elif total[i] == variables[1]:
			out = out + rules[1]
		else:
			out = out + total[i]
	
	return out

func _on_iterations_slider_changed(value: float):
	iterations = int(value)
	settings.get_node("Iterations/Label").text = "Iterations: " + str(iterations)
func _on_line_length_slider_changed(value: float): 
	line_length = value
	settings.get_node("LineLength/Label").text = "Line Length: " + str("%.2f" % line_length)

# Called when the node enters the scene tree for the first time.
func _ready():
	pos = Vector2(get_viewport_rect().size.x / 2.0, get_viewport_rect().size.y / 2.0)
	
	iterations = settings.get_node("Iterations/HSlider").value
	line_length = settings.get_node("LineLength/HSlider").value
	
	settings.get_node("Iterations/HSlider").value_changed.connect(_on_iterations_slider_changed)
	settings.get_node("LineLength/HSlider").value_changed.connect(_on_line_length_slider_changed)
	settings.get_node("Iterations/Label").text = "Iterations: " + str(iterations)
	settings.get_node("LineLength/Label").text = "Line Length: " + str("%.2f" % line_length)
	
	for i in range(13):
		var str = dragon_curve(i, variables[0])
		levels.append(str)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$TextureRect.size = get_viewport_rect().size
	queue_redraw()
