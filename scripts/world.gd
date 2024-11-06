extends Node3D

@export var box: Node3D
@export var player: Camera3D
@export var player_animator: AnimationPlayer
@export var arms: Node3D
@export var game_logic: Node

func _ready() -> void:
	Dialogic.start("timeline")
	Dialogic.signal_event.connect(_on_dialogic_signal)
	player_animator.play("focused")

func _on_dialogic_signal(argument: String):
	match argument:
		# pre game
		"box_open":
			box.open_box()
			player_animator.play("pan_out")
			await get_tree().create_timer(0.5).timeout
			arms.anim_state.travel("Welcome")
		"ask_question":
			arms.anim_state.travel("Welcome-to-Talk")
		"refused_play":
			arms.anim_state.travel("Talk-to-Idle")
		"refused_jumpscare":
			arms.anim_state.travel("Idle-to-Jump")
		"start_game":
			arms.anim_state.travel("Talk-to-Idle")
			await get_tree().create_timer(1).timeout
			game_logic.start_qte()
			Global.game_started = true
		# post game
		"game_end":
			Global.game_started = false
			arms.anim_state.travel("Idle-to-Win")
		"get_reward":
			arms.anim_state.travel("Win-to-Below")
		"show_hand":
			arms.anim_state.travel("Below-to-Gift")
		"open_hand":
			arms.anim_state.travel("Gift-to-Open")
			

func _on_game_logic_qte_success() -> void:
	Dialogic.start("timeline_win")
