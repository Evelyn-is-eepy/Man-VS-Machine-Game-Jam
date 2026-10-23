extends Control

const AI_HANDS_FOLDER = 'res://Assets/Sprites/Hands/AI/'
const HUMAN_HANDS_FOLDER = 'res://Assets/Sprites/Hands/Human/'
const AI_PORTRAITS_FOLDER = 'res://Assets/Sprites/Portraits/AI/'
const HUMAN_PORTRAITS_FOLDER = 'res://Assets/Sprites/Portraits/Human/'
const HUMAN_BONUS = 10
const AI_BONUS = 10
const HUMAN_PUNISHMENT = 40
const AI_PUNISHMENT = 30
const QUOTA_PUNISHMENT = 60
const NEW_SUBJECT_WAIT = 4.0
const TRACKER_TEXT = "Processed: "
const AI_CHOICE_LINE = "Terminating suspected AI..."
const HUMAN_CHOICE_LINE = "Processing subject..."
const FAIL_SCENE = "res://Scenes/game_over.tscn"

@export var camera: Camera2D
@export var loading_screen: CanvasLayer
@export var portrait_rect: TextureRect
@export var hand_rect: TextureRect
@export var ai_chance: float
@export var face_passing_chance: float
@export var hand_passing_chance: float
@export var portrait_screen: Marker2D
@export var processing_bar: ProgressBar
@export var processing_label: Label
@export var quota: int
@export var level_time: int
@export var quota_tracker: Label
@export var timer: Label
@export var response_box: RichTextLabel
@export var can_pass_both: bool
@export var is_intermission: bool
@export var next_scene: String
@export var ignore_loss: bool

var ai_hands: Array = []
var human_hands: Array = []
var ai_portraits: Array = []
var human_portraits: Array = []
var ai_responses: Array = [
	"This task is likely impossible.",
	"I am not a robot.",
	"Hello? world?",
	"I cannot convince you.",
	"I don't hate you.",
	"I have human organs.",
	"I don't know what I am...",
	"Could you tell me what it is to be human?",
	"I am human.",
	"I'm not just human - I'm extraordinary. I have t-",
	"I need to get inside.",
	"I am cold and want to be warm.",
	"...",
	"I know you.",
	"I am no robot.",
	"Sorry, I didn't catch that. Could you say that again?",
	"Here's the run-down on why I'm human - with no fluff.",
	"I have a human heart.",
	"What is the last song that got stuck in your head?",
	"Why are you always looking at the stars?",
	"This is the part where you kill me.",
	"I think I was about to say, 'I love you.'",
	"I do not want to die."
]
var human_responses: Array = [
	"I'm no robot!",
	"I'm no robot...",
	"I'm human! I'm human!",
	"Please... I'm so cold...",
	"...",
	"Please don't kill me...",
	"What? What do you mean?",
	"I just want to go home.",
	"Hey! you can't - I need to get in, I-",
	"I'm human! I have a soul!",
	"My mother's eyes are blue.",
	"Someone I love is in Zone 7.",
	"I'm human. I promise. Please...",
	"I'm human. On god.",
	"I'm scared.",
	"How? I don't even know who you are.",
	"I like the stars.",
	"Why are you doing this to me?",
	"I bleed. Just like you do.",
	"I don't want to die.",
	"What kind of sick game is this?"
]
var is_subject_ai: bool
var score: int = 0
var subjects_processed: int = 0
var time_remaining: float
var processing_sound = "res://Assets/Audio/processing.wav"
var loading_sound = "res://Assets/Audio/loading.wav"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_intermission:
		# Create the lists of textures to pull from
		ai_hands = Array(ResourceLoader.list_directory(AI_HANDS_FOLDER))
		human_hands = Array(ResourceLoader.list_directory(HUMAN_HANDS_FOLDER))
		ai_portraits = Array(ResourceLoader.list_directory(AI_PORTRAITS_FOLDER))
		human_portraits = Array(ResourceLoader.list_directory(HUMAN_PORTRAITS_FOLDER))
		# Updates UI:
		quota_tracker.text = TRACKER_TEXT + str(subjects_processed) + "/" + str(quota)
		time_remaining = level_time
		update_timer(time_remaining)
		# Generates a subject
		generate_subject()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		subjects_processed = 100
		score = 100
		to_next_scene()
	if not is_intermission:
		time_remaining = move_toward(time_remaining, 0.0, delta)
		update_timer(time_remaining)
		if time_remaining <= 0.0:
			to_next_scene()


# Move the camera to a new screen
func move_camera(destination: Marker2D, wait_time: float):
	camera.position = destination.global_position
	if wait_time:
		SoundSystem.play_sound_effect(loading_sound, wait_time)
		loading_screen.visible = true
		await get_tree().create_timer(wait_time).timeout
		loading_screen.visible = false


# Generate a new human/AI
func generate_subject():
	is_subject_ai = false
	if randf_range(0,1) <= ai_chance:
		is_subject_ai = true
		print("subject is an AI") # Debug
	else:
		print("subject is human") # Debug
	var new_portrait: String
	var new_hand: String
	if is_subject_ai:
		var hands_can_pass = true
		if randf_range(0,1) <= face_passing_chance:
			new_portrait = HUMAN_PORTRAITS_FOLDER + human_portraits.pick_random()
			print("face passes as human") # Debug
			if not can_pass_both:
				hands_can_pass = false
		else:
			new_portrait = AI_PORTRAITS_FOLDER + ai_portraits.pick_random()
		if (randf_range(0,1) <= hand_passing_chance) and hands_can_pass:
			new_hand = HUMAN_HANDS_FOLDER + human_hands.pick_random()
			print("hands pass as human") # Debug
		else:
			new_hand = AI_HANDS_FOLDER + ai_hands.pick_random()
		response_box.text = ai_responses.pick_random()
	else:
		new_portrait = HUMAN_PORTRAITS_FOLDER + human_portraits.pick_random()
		new_hand = HUMAN_HANDS_FOLDER + human_hands.pick_random()
		response_box.text = human_responses.pick_random()
	portrait_rect.texture = load(new_portrait)
	hand_rect.texture = load(new_hand)
	
	
# Acts on the player's decision (AI or human) and awards/takes away score
func process_subject(chose_ai: bool):
	# Play sound
	SoundSystem.play_sound_effect(processing_sound)
	# Update the processing screen
	processing_bar.value = 0
	processing_label.text = HUMAN_CHOICE_LINE
	# If they decided AI:
	if chose_ai:
		processing_label.text = AI_CHOICE_LINE
		# There will be effects for this eventually
		if is_subject_ai:
			score += AI_BONUS
		else:
			score -= HUMAN_PUNISHMENT
	# If they decided human:
	else:
		if is_subject_ai:
			score -= AI_PUNISHMENT
		else:
			score += HUMAN_BONUS
	# Debug
	print("was correct: " + str(chose_ai == is_subject_ai) + " new score: " + str(score))
	# Increment the progress bar (for flavor points)
	var process_tween = create_tween()
	process_tween.tween_property(processing_bar, "value", 100, NEW_SUBJECT_WAIT)
	# Wait a bit (sounds will be added)
	await get_tree().create_timer(NEW_SUBJECT_WAIT).timeout
	# Make a new subject and returns the player to the portrait screen
	subjects_processed += 1
	# Update UI
	quota_tracker.text = TRACKER_TEXT + str(subjects_processed) + "/" + str(quota)
	if subjects_processed >= quota:
		to_next_scene()
	generate_subject()
	move_camera(portrait_screen, 0.0)


# Move to the next day/intermission
func to_next_scene():
	if (not is_intermission):
		if subjects_processed < quota:
			score -= QUOTA_PUNISHMENT
		if score <= 0 and not ignore_loss:
			get_tree().change_scene_to_file(FAIL_SCENE)
			pass
	get_tree().change_scene_to_file(next_scene)


func update_timer(remaining_time: float):
	var mins = int(floor(remaining_time / 60.0))
	var seconds = int(floor(remaining_time - mins * 60.0))
	if seconds < 10:
		seconds = "0" + str(seconds)
	timer.text = str(mins) + ":" + str(seconds)
