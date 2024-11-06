extends Node3D

enum Direction { LEFT, RIGHT, UP, DOWN }

@export var anim_tree: AnimationTree
var anim_state: AnimationNodeStateMachinePlayback

func _ready() -> void:
	anim_state = anim_tree.get("parameters/playback")

func quit() -> void:
	get_tree().quit()

func _on_game_logic_display_direction(direction: Direction) -> void:
	print ("yeah")
	match direction:
		Direction.LEFT:
			anim_state.travel("Left")
		Direction.RIGHT:
			anim_state.travel("Right")
		Direction.UP:
			anim_state.travel("Up")
		Direction.DOWN:
			anim_state.travel("Down")

func _on_game_logic_qte_failed() -> void:
	await get_tree().create_timer(0.5).timeout
	anim_state.travel("Idle-to-Jump")

func _on_game_logic_idle() -> void:
	anim_state.travel("Idle")
