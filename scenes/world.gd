extends Node3D

@export var box: Node3D
@export var player_animator: AnimationPlayer
@export var arms: Node3D

func _ready() -> void:
	Dialogic.start("timeline")
	Dialogic.signal_event.connect(_on_dialogic_signal)
	player_animator.play("focused")

func _on_dialogic_signal(argument: String):
	match argument:
		"box_open":
			box.open_box()
			arms.anim_state.travel("Welcome")
			player_animator.play("pan_out")
		"ask_question":
			arms.anim_state.travel("Welcome-to-Talk")
		"refused_play", "start_game":
			arms.anim_state.travel("Talk-to-Idle")
		"refused_jumpscare":
			arms.anim_state.travel("Idle-to-Jump")
