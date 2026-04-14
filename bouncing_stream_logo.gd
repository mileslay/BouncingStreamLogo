extends Window

@onready var options: Window = $Options
var image: Node2D
var half_size: Vector2

@export var speed: float = 400.0
@export var change_color_on_bounce: bool = true
var velocity: Vector2 = Vector2(1, 1)

func _ready() -> void:
	size.x = 2560
	size.y = 1440
	
	var gif_path = "res://image.gif"
	var png_path = "res://image.png"
	if FileAccess.file_exists(gif_path):
		image = AnimatedSprite2D.new()
		image.sprite_frames = GifManager.sprite_frames_from_file(gif_path)
		image.play(image.sprite_frames.get_animation_names()[0])
		update_half_size()
		$Options/MarginContainer/GridContainer/GridContainer/AnimationSpeedSpinBox.value \
			= image.sprite_frames.get_animation_speed(image.sprite_frames.get_animation_names()[0])
		add_child(image)
	elif FileAccess.file_exists(png_path):
		$Options/MarginContainer/GridContainer/GridContainer/AnimationSpeedSpinBox \
			.value = 0
		$Options/MarginContainer/GridContainer/GridContainer/AnimationSpeedSpinBox \
			.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Options/MarginContainer/GridContainer/GridContainer/AnimationSpeedSpinBox \
			.editable = false
		image = Sprite2D.new()
		image.texture = load(png_path)
		update_half_size()
		add_child(image)
	else:
		push_error("Files 'image.gif' and 'image.png' not found in root directory.")
	
	image.position.x = randi_range(0, int(size.x - half_size.x))
	image.position.y = randi_range(0, int(size.y - half_size.y))
	
	options.grab_focus()

func _process(delta: float) -> void:
	image.position += velocity * speed * delta
	
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

func update_half_size() -> void:
	if image is AnimatedSprite2D:
		half_size = image.sprite_frames.get_frame_texture(
				image.sprite_frames.get_animation_names()[0], 0).get_size() * image.scale / 2.0
	elif image is Sprite2D:
		half_size = (image.texture.get_size() * image.scale) / 2.0

func change_color() -> void:
	if(change_color_on_bounce):
		image.modulate = Color(randf(), randf(), randf(), 1.0)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode == KEY_O and event.pressed:
		_on_open_options_hotkey()
	elif event.keycode == KEY_M and event.pressed:
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

func _on_animation_speed_spin_box_value_changed(value: float) -> void:
	if image is AnimatedSprite2D:
		image.sprite_frames.set_animation_speed(
			image.sprite_frames.get_animation_names()[0], value)

func _on_scale_spin_box_value_changed(value: float) -> void:
	image.scale = Vector2(value, value)
	update_half_size()

func _on_open_options_hotkey() -> void:
	options.show()
	options.grab_focus()

func _on_minimize_hotkey() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

func _on_options_close_requested() -> void:
	options.hide()
	grab_focus()
