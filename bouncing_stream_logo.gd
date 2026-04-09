extends Window

@onready var options: Window = $Options
var image: Node2D

@export var speed: float = 400.0
@export var change_color_on_bounce: bool = true
var velocity: Vector2 = Vector2(1, 1)

func _ready() -> void:
	size.x = 2560
	size.y = 1440
	
	var image_path = "res://image.png"
	if FileAccess.file_exists(image_path):
		image = Sprite2D.new()
		image.texture = load(image_path)
		add_child(image)
	else:
		push_error("File 'icon.png' not found in root directory.")
	
	var half_size = (image.texture.get_size() * image.scale) / 2.0
	image.position.x = randi_range(0, int(size.x - half_size.x))
	image.position.y = randi_range(0, int(size.y - half_size.y))
	
	options.grab_focus()

func _process(delta: float) -> void:
	image.position += velocity * speed * delta
	
	var half_size = (image.texture.get_size() * image.scale) / 2.0
	
	# horizontal bounce
	if image.position.x + half_size.x >= size.x:
		image.position.x = size.x - half_size.x
		velocity.x *= -1
		change_color()
	elif image.position.x - half_size.x <= 0:
		image.position.x = half_size.x
		velocity.x *= -1
		change_color()
	
	# vertical bounce
	if image.position.y + half_size.y >= size.y:
		image.position.y = size.y - half_size.y
		velocity.y *= -1
		change_color()
	elif image.position.y - half_size.y <= 0:
		image.position.y = half_size.y
		velocity.y *= -1
		change_color()

func change_color() -> void:
	if(change_color_on_bounce):
		image.modulate = Color(randf(), randf(), randf(), 1.0)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode == KEY_P and event.shift_pressed and event.pressed:
		_on_open_options_hotkey()
	elif event.keycode == KEY_M and event.shift_pressed and event.pressed:
		_on_minimize_hotkey()

func _on_color_change_check_button_toggled(toggled_on: bool) -> void:
	change_color_on_bounce = toggled_on
	if not change_color_on_bounce:
		image.modulate = Color(1, 1, 1, 1)

func _on_speed_spin_box_value_changed(value: float) -> void:
	speed = int(value)

func _on_width_spin_box_value_changed(value: float) -> void:
	size.x = int(value)

func _on_height_spin_box_value_changed(value: float) -> void:
	size.y = int(value)

func _on_open_options_hotkey() -> void:
	options.show()
	options.grab_focus()

func _on_minimize_hotkey() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

func _on_options_close_requested() -> void:
	options.hide()
	grab_focus()
