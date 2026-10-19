extends Control

@export var camera: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Move the camera to a new screen
func move_camera(destination: Marker2D):
	camera.position = destination.global_position
