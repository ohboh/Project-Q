extends Node

enum Direction { LEFT, RIGHT, UP, DOWN }

var qte_active: bool = false
var success_condition_met: bool = false
var wait_until_satisfied: bool = true
var qte_duration: float = 3.0

var directions: Array = [Direction.LEFT, Direction.RIGHT, Direction.DOWN, Direction.UP]
var chosen_direction: Direction
var reset_to_idle: bool = false
var directions_count: int = 0
@export var directions_required_count: int = 50

@export var player: Camera3D

signal qte_started
signal qte_success
signal qte_failed
signal display_direction(direction: Direction)
signal idle

func start_qte() -> void:
	success_condition_met = false
	chosen_direction = directions.pick_random()
	display_direction.emit(chosen_direction)
	
	qte_active = true
	qte_started.emit()
	
	if not wait_until_satisfied:
		var timer: Timer = Timer.new()
		add_child(timer)
		timer.wait_time = qte_duration
		timer.one_shot = true
		timer.connect("timeout", Callable(self, "_on_qte_timeout"))
		timer.start()

func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventJoypadButton) and event.is_pressed() and not event.is_echo() and Global.game_started and not reset_to_idle:
		process_action_directions(event)

func process_action_directions(event: InputEvent) -> void:
	var input_direction: Direction
	if event.is_action_pressed("ui_left"):
		input_direction = Direction.LEFT
		player.anim_player.play("left")
	elif event.is_action_pressed("ui_right"):
		input_direction = Direction.RIGHT
		player.anim_player.play("right")
	elif event.is_action_pressed("ui_up"):
		input_direction = Direction.UP
		player.anim_player.play("up")
	elif event.is_action_pressed("ui_down"):
		input_direction = Direction.DOWN
		player.anim_player.play("down")
	check_direction(input_direction)

func check_direction(direction: Direction) -> void:
	if chosen_direction != direction:
		directions_count += 1
		print("hooray:", directions_count)
		if directions_count <= 10:
			reset_to_idle = true
			idle.emit()
			await get_tree().create_timer(randf_range(1,2)).timeout
			reset_to_idle = false
		elif directions_count <= 25:
			reset_to_idle = true
			idle.emit()
			await get_tree().create_timer(randf_range(0.5,1)).timeout
			reset_to_idle = false
		elif directions_count <=40:
			reset_to_idle = true
			idle.emit()
			await get_tree().create_timer(randf_range(0.5,1)).timeout
			reset_to_idle = false
			chosen_direction = directions.pick_random()
			display_direction.emit(chosen_direction)
			await get_tree().create_timer(randf_range(0.25,1)).timeout
		elif directions_count <=50:
			reset_to_idle = true
			idle.emit()
			await get_tree().create_timer(randf_range(0.5,1)).timeout
			reset_to_idle = false
			chosen_direction = directions.pick_random()
			display_direction.emit(chosen_direction)
			await get_tree().create_timer(randf_range(0,0.75)).timeout
			chosen_direction = directions.pick_random()
			display_direction.emit(chosen_direction)
			await get_tree().create_timer(randf_range(0,0.75)).timeout
		chosen_direction = directions.pick_random()
		display_direction.emit(chosen_direction)
	elif not success_condition_met:
		print("aw")
		end_qte(false)
	
	if directions_count >= directions_required_count:
		success_condition_met = true
		end_qte(true)

func end_qte(success: bool) -> void:
	if success:
		qte_success.emit()
	else:
		qte_failed.emit()

	await get_tree().create_timer(0.5).timeout
	qte_active = false

func _on_qte_timeout() -> void:
	if not success_condition_met:
		end_qte(false)

func chance(probability : int) -> bool:
	return true if (randi() % 100) < probability else false
