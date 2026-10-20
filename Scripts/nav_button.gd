extends Control

@export var destination: Marker2D
@export var control: Control
@export var button: Button
@export var button_text: String
@export var additional_functions: Array[String]
@export var additional_arguments: Array
@export var load_time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Apply the button's title
	button.text = button_text


func _on_button_pressed() -> void:
	# Move the camera to the specified location
	control.move_camera(destination, load_time)
	# Execute additional functions, if any
	if additional_functions:
		var function_index = 0
		for function in additional_functions:
			control.call(function, additional_arguments[function_index])
			function_index += 1
