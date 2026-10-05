extends Node2D
class_name TargetObject

func _init() -> void:
	randomize_dest()

func randomize_dest():
	var monitor_size = DisplayServer.window_get_size()
	position = Vector2(randi_range(0,monitor_size.x),randi_range(0,monitor_size.y))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_pos() -> Vector2:
	return position
