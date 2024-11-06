extends Node3D

@export var anim_tree: AnimationTree
var anim_state: AnimationNodeStateMachinePlayback

func _ready() -> void:
	anim_state = anim_tree.get("parameters/playback")

func quit() -> void:
	get_tree().quit()
