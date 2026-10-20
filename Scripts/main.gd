extends Control

const AI_HANDS_FOLDER = 'res://Assets/Sprites/Hands/AI/'
const HUMAN_HANDS_FOLDER = 'res://Assets/Sprites/Hands/Human/'
const AI_PORTRAITS_FOLDER = 'res://Assets/Sprites/Portraits/AI/'
const HUMAN_PORTRAITS_FOLDER = 'res://Assets/Sprites/Portraits/Human/'
const HUMAN_BONUS = 10
const AI_BONUS = 10
const HUMAN_PUNISHMENT = 40
const AI_PUNISHMENT = 30
const NEW_SUBJECT_WAIT = 7.0
const TRACKER_TEXT = "Subjects Processed: "

@export var camera: Camera2D
@export var loading_screen: CanvasLayer
@export var portrait_rect: TextureRect
@export var hand_rect: TextureRect
@export var ai_chance: float
@export var face_passing_chance: float
@export var hand_passing_chance: float
@export var portrait_screen: Marker2D
@export var processing_bar: ProgressBar
@export var quota: int
@export var quota_tracker: Label

var ai_hands: Array = []
var human_hands: Array = []
var ai_portraits: Array = []
var human_portraits: Array = []
var is_subject_ai: bool
var score: int = 0
var subjects_processed: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create the lists of textures to pull from
	ai_hands = Array(ResourceLoader.list_directory(AI_HANDS_FOLDER))
	human_hands = Array(ResourceLoader.list_directory(HUMAN_HANDS_FOLDER))
	ai_portraits = Array(ResourceLoader.list_directory(AI_PORTRAITS_FOLDER))
	human_portraits = Array(ResourceLoader.list_directory(HUMAN_PORTRAITS_FOLDER))
	# Updates UI:
	quota_tracker.text = TRACKER_TEXT + str(subjects_processed) + "/" + str(quota)
	# Generates a subject
	generate_subject()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Move the camera to a new screen
func move_camera(destination: Marker2D, wait_time: float):
	camera.position = destination.global_position
	if wait_time:
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
		if randf_range(0,1) <= face_passing_chance:
			new_portrait = HUMAN_PORTRAITS_FOLDER + human_portraits.pick_random()
			print("face passes as human") # Debug
		else:
			new_portrait = AI_PORTRAITS_FOLDER + ai_portraits.pick_random()
		if randf_range(0,1) <= hand_passing_chance:
			new_hand = HUMAN_HANDS_FOLDER + human_hands.pick_random()
			print("hands pass as human") # Debug
		else:
			new_hand = AI_HANDS_FOLDER + ai_hands.pick_random()
	else:
		new_portrait = HUMAN_PORTRAITS_FOLDER + human_portraits.pick_random()
		new_hand = HUMAN_HANDS_FOLDER + human_hands.pick_random()
	portrait_rect.texture = load(new_portrait)
	hand_rect.texture = load(new_hand)
	
	
# Acts on the player's decision (AI or human) and awards/takes away score
func process_subject(chose_ai: bool):
	processing_bar.value = 0
	# If they decided AI:
	if chose_ai:
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
	generate_subject()
	move_camera(portrait_screen, 0.0)
