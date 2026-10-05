extends Node2D

@export var spawn_radius : float = 1.0
@export var spawn_time : float = 1.0
@export var max_creatures : int = 10

@onready var world = get_parent()

var elapsed_time = 0
var creature_pool : Array = []
const CREATURE_SCENE = preload("res://Objects/creature.tscn")
const offscreen = Vector2(-1000,1000)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(max_creatures):
		var creature = CREATURE_SCENE.instantiate()
		creature.set_process(false)
		creature.set_physics_process(false)
		creature.visible = false
		var health : int = randi_range(10,100)
		var max_health : int = health
		var food : int = randi_range(10, 100)
		var max_food : int = randi_range(food, food+200)
		var min_food_for_heal : int = randi_range(0, max_food)
		var healing_rate : int = randi_range(0, 100)
		var metabolism_speed : int = randi_range(1,10)
		var metabolism_amount : int = randi_range(1,50)
		var speed : float = randi_range(100, 200)
		var color : Color = Color(1,0,1,1.0)
		var vision_radius : float = randf_range(0, 10)
		creature.init_creature_values(
			health,
			max_health,
			food,
			max_food,
			min_food_for_heal,
			healing_rate,
			metabolism_speed,
			metabolism_amount,
			speed,
			vision_radius
		)
		creature_pool.append(creature)
		creature.dead.connect(return_to_pool)
		creature.global_position = offscreen
		world.add_child.call_deferred(creature)

func return_to_pool(target):
	target.global_position = offscreen
	#target.toggle_monitoring()
	target.set_process(false)
	target.set_physics_process(false)
	target.visible = false
	creature_pool.append(target)
	#print(food_pool)

func spawn_creature():
	#print("Spawning Food")
	var spawn_pos = Vector2(randi_range(position.x-spawn_radius, position.x+spawn_radius),randi_range(position.y-spawn_radius, position.y+spawn_radius))
	#print(spawn_pos)
	#var new_food = FOOD_SCENE.instantiate()
	var new_creature = creature_pool.pop_back()
	if not new_creature:
		return
	new_creature.global_position = spawn_pos
	new_creature.update_dest()
	#new_creature.toggle_monitoring()
	new_creature.set_process(true)
	new_creature.set_physics_process(true)
	new_creature.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	while elapsed_time >= spawn_time:
		elapsed_time -= spawn_time
		spawn_creature()
