extends Node

enum Direction { LEFT, RIGHT, UP, DOWN }

var qte_active: bool = false
var success_condition_met: bool = false
var wait_until_satisfied: bool = true
var qte_duration: float = 3.0

var directions: Array = [Direction.LEFT, Direction.RIGHT, Direction.DOWN, Direction.UP]
var chosen_direction: Direction
var swipe_vector: Vector2
var swipe_threshold: float = 100
var touch_start_position: Vector2 = Vector2.ZERO
var swiped: bool = false
var directions_count: int = 0
@export var directions_required_count: int = 5

signal qte_started
signal qte_success
signal qte_failed
signal display_direction(direction: Direction)

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
	handle_directions(event)

func handle_directions(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			touch_start_position = get_viewport().get_final_transform() * event.position
		else:
			swiped = false

	if event is InputEventScreenDrag and not swiped:
		var adjusted_position: Vector2 = get_viewport().get_final_transform() * event.position
		swipe_vector = adjusted_position - touch_start_position
		if swipe_vector.length() > swipe_threshold:
			swiped = true
			process_swipe_directions(swipe_vector)

	if (event is InputEventKey or event is InputEventJoypadButton) and event.is_pressed() and not event.is_echo():
		process_action_directions(event)


func process_swipe_directions(_swipe_vector: Vector2) -> void:
	var input_direction: Direction
	if abs(swipe_vector.x) > abs(swipe_vector.y):
		input_direction = Direction.RIGHT if swipe_vector.x > 0 else Direction.LEFT
	else:
		input_direction = Direction.UP if swipe_vector.y < 0 else Direction.DOWN
	check_direction(input_direction)

func process_action_directions(event: InputEvent) -> void:
	var input_direction: Direction
	if event.is_action_pressed("ui_left"):
		input_direction = Direction.LEFT
	elif event.is_action_pressed("ui_right"):
		input_direction = Direction.RIGHT
	elif event.is_action_pressed("ui_up"):
		input_direction = Direction.UP
	elif event.is_action_pressed("ui_down"):
		input_direction = Direction.DOWN
	check_direction(input_direction)

func check_direction(direction: Direction) -> void:
	if chosen_direction != direction:
		directions_count += 1
		print("hooray:", directions_count)
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
