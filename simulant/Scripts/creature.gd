extends TargetObject
class_name Creature

#TODO: Remove vision and instead only target food when needed

@export var health : int = 0
@export var max_health : int = 0
@export var food : int = 0
@export var max_food : int = 0
@export var min_food_for_heal : int = 0
@export var healing_rate : int = 0
@export var metabolism_speed : int = 0
@export var metabolism_amount : int = 0
@export var speed : float = 100
@export var color : Color = Color(1,0,1,1.0)
@export var vision_radius : float = 3.0

@onready var texture : Sprite2D = $Sprite2D
@onready var collision_area : Area2D = $CollisionArea
@onready var collision_shape : CollisionShape2D = $CollisionArea/CollisionShape2D
#@onready var vision_area : Area2D = $VisionArea
#@onready var vision_shape : CollisionShape2D = $VisionArea/CollisionShape2D

var forward : Vector2 = Vector2(1,0)
var direction = 0.0
var destination = Vector2.ZERO
var in_vision : Dictionary = {}
var dest_object : TargetObject = null
var random_dest : TargetObject = TargetObject.new()
var randomized : bool = false
var elapsed_time : float = 0.0
var vision_query := PhysicsShapeQueryParameters2D.new()
var vision_query_shape := CircleShape2D.new()

signal dead(target)

func init_creature_values(
	c_health,
	c_max_health,
	c_food,
	c_max_food,
	c_min_food_for_heal,
	c_healing_rate,
	c_metabolism_speed,
	c_metabolism_amount,
	c_speed,
	c_vision_radius,
	c_color = null
	) -> void:
	health = c_health
	max_health = c_max_health
	food = c_food
	max_food = c_max_food
	min_food_for_heal = c_min_food_for_heal
	healing_rate = c_healing_rate
	metabolism_speed = c_metabolism_speed
	metabolism_amount = c_metabolism_amount
	speed = c_speed
	vision_radius = c_vision_radius
	if c_color:
		color = c_color
	dest_object = random_dest

#func toggle_monitoring():
	#vision_area.monitoring = not vision_area.monitoring
	#collision_area.monitoring = not collision_area.monitoring
	#print(collision_area.monitoring)
	#print(vision_area.monitoring)

func decrement_food():
	#print(food)
	food -= metabolism_amount
	if food >= min_food_for_heal and health < max_health:
		food -= healing_rate
		health += healing_rate
	if food <= 0:
		dead.emit(self)
	if not dest_object is Food and is_hungry():
		update_dest()

func is_hungry() -> bool:
	return food <= (max_food * .8)

func dist_from_obj(obj : TargetObject) -> float:
	var obj_pos = obj.get_pos()
	var x_dist = (obj_pos.x - position.x) ** 2
	var y_dist = (obj_pos.y - position.y) ** 2
	return x_dist + y_dist

func is_closer(first : TargetObject, second : TargetObject):
	var first_dist = dist_from_obj(first)
	var second_dist = dist_from_obj(second)
	return first_dist < second_dist

func scan_for_food():
	vision_query.transform = Transform2D(0, global_position)
	
	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_shape(vision_query)
	
	for result in results:
		#print(result)
		var object = result['collider'].get_parent()
		if object is Food:
			in_vision['food'].append(object)
	#print("EXITED")

func choose_food():
	var closest_dest = null
	for food in in_vision['food']:
		if not closest_dest or is_closer(food, closest_dest):
			closest_dest = food
	dest_object = closest_dest
	destination = dest_object.get_pos()

func choose_random():
	print("Random")
	dest_object = rand_target()
	destination = dest_object.get_pos()

func update_dest():
	var updated = false
	if is_hungry():
		scan_for_food()
		if not in_vision['food'].is_empty():
			randomized = false
			updated = true
			choose_food()
	if not updated:
		choose_random()

#func calc_priority() -> TargetObject:
	#if dest_object in in_vision:
		#return dest_object
	#for item in in_vision:
		#if item is Food and hungry:
			#randomized = false
			#return item
	#return rand_target()

func calc_dist():
	var x_dist = (destination.x - position.x) ** 2
	var y_dist = (destination.y - position.y) ** 2
	return x_dist + y_dist

func rand_target() -> TargetObject:
	var dist_from_target = calc_dist()
	print(randomized)
	if not randomized or dist_from_target <= 1:
		randomized = true
		random_dest.randomize_dest()
		print("updated: ", random_dest.get_pos())
		return random_dest
	return dest_object

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture.modulate = color
	#vision_shape.scale = Vector2.ONE * vision_radius
	#vision_area.monitoring = false
	in_vision['food'] = []
	in_vision['mates'] = []
	
	collision_area.monitoring = true
	
	vision_query_shape.radius = vision_radius
	vision_query.shape = vision_query_shape
	vision_query.collide_with_areas = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	while elapsed_time >= metabolism_speed:
		#print(elapsed_time)
		elapsed_time -= metabolism_speed
		decrement_food()
	if calc_dist() <= 1.0:
		update_dest()
	forward = position.direction_to(destination)
	rotation = forward.angle()
	position += forward * speed * delta


func _on_area_2d_area_entered(area: Area2D) -> void:
	#print("Entered")
	var object = area.get_parent()
	if object is Creature:
		print("Mate")
		#try_mate()
	elif object is Food:
		#print("Eat")
		food += object.quantity
		food = max_food if food > max_food else food
		object.collect()


#func _on_vision_area_area_entered(area: Area2D) -> void:
	#var object = area.get_parent()
	#if object is Food and is_hungry():
		#in_vision['food'].append(object)
		#update_dest()
#
#func _on_vision_area_area_exited(area: Area2D) -> void:
	#var object = area.get_parent()
	#if object is Food and object in in_vision['food']:
		#in_vision['food'].erase(object)
		#update_dest()
