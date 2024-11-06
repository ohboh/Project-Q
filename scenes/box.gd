extends Node3D

@export var anim_player: AnimationPlayer

func open_box() -> void:
	anim_player.play("Open")
