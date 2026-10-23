extends Control

var startup_sound = "res://Assets/Audio/startup.wav"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundSystem.play_sound_effect(startup_sound)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Intermission1.tscn")
	pass # Replace with function body.


func _on_close_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
