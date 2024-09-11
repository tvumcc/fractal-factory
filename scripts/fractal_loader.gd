extends Control

# Stores the scenes of the fractal viewers
var fractals = [
	# Escape Time
	preload("res://fractals/mandelbrot.tscn").instantiate(),
	preload("res://fractals/julia.tscn").instantiate(),
	preload("res://fractals/sin_julia.tscn").instantiate(),
	preload("res://fractals/spiral_septagon.tscn").instantiate(),
	
	# 3D Fractals
	preload("res://fractals/menger_sponge.tscn").instantiate(),
	preload("res://fractals/sierpinski_pyramid.tscn").instantiate(),
	
	# L-system Fractals
	preload("res://fractals/sierpinski_arrowhead.tscn").instantiate(),
	preload("res://fractals/dragon_curve.tscn").instantiate(),
]

# Stores the scenes of the fractal settings menus
var fractal_settings = [
	# Escape Time
	preload("res://fractal_settings/mandelbrot_settings.tscn").instantiate(),
	preload("res://fractal_settings/julia_settings.tscn").instantiate(),
	preload("res://fractal_settings/sin_julia_settings.tscn").instantiate(),
	preload("res://fractal_settings/spiral_septagon_settings.tscn").instantiate(),
	
	# 3D Fractals
	preload("res://fractal_settings/menger_sponge_settings.tscn").instantiate(),
	preload("res://fractal_settings/sierpinski_pyramid_settings.tscn").instantiate(),
	
	# L-system Fractals
	preload("res://fractal_settings/sierpinski_arrowhead_settings.tscn").instantiate(),
	preload("res://fractal_settings/dragon_curve_settings.tscn").instantiate(),
]

func map_settings_to_fractal():
	for i in range(len(fractals)):
		fractals[i].settings = fractal_settings[i]

func _ready():
	map_settings_to_fractal()
	%FractalSelector.select(3)
	_on_option_button_item_selected(3)
	
func _process(delta):
	pass

func _on_option_button_item_selected(index):
	var id = %FractalSelector.get_selected_id()
	
	if id < len(fractals) and id < len(fractal_settings):
		for child in %CanvasViewport.get_children():
			%CanvasViewport.remove_child(child)
		for child in %FractalSettings.get_children():
			if child.name != "FractalSettingsLabel":
				%FractalSettings.remove_child(child)
			
		%CanvasViewport.add_child(fractals[id])
		%FractalSettings.add_child(fractal_settings[id])
