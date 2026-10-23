extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_sound_effect(sound_path: String, limit_time = null):
	var player = AudioStreamPlayer.new()
	player.stream = AudioStreamWAV.load_from_file(sound_path)
	player.autoplay = true
	add_child(player)
	if limit_time:
		await get_tree().create_timer(limit_time).timeout
		player.queue_free()
	else:
		await player.finished
		player.queue_free()
