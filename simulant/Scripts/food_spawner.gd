extends Node2D

@export var spawn_radius : float = 1.0
@export var spawn_time : float = 1.0
@export var max_food : int = 1000

@onready var world = get_parent()

var elapsed_time = 0
var food_pool : Array = []
const FOOD_SCENE = preload("res://Objects/food.tscn")
const offscreen = Vector2(-1000,1000)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(max_food):
		var food = FOOD_SCENE.instantiate()
		food_pool.append(food)
		food.freeing.connect(return_to_pool)
		food.global_position = offscreen
		world.add_child.call_deferred(food)

func return_to_pool(target):
	target.global_position = offscreen
	food_pool.append(target)
	#print(creature_pool)

func spawn_food():
	#print("Spawning Creature")
	var spawn_pos = Vector2(randi_range(position.x-spawn_radius, position.x+spawn_radius),randi_range(position.y-spawn_radius, position.y+spawn_radius))
	#print(spawn_pos)
	#var new_food = FOOD_SCENE.instantiate()
	var new_food = food_pool.pop_back()
	if not new_food:
		return
	new_food.global_position = spawn_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	while elapsed_time >= spawn_time:
		elapsed_time -= spawn_time
		spawn_food()
