extends Control

@export var destination: Marker2D
@export var control: Control
@export var button: Button
@export var button_text: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Apply the button's title
	button.text = button_text
	pass # Replace with function body.

func _on_button_pressed() -> void:
	# Move the camera to the specified location
	control.move_camera(destination)
	pass # Replace with function body.
