extends TargetObject
class_name Food
@export var quantity : int = 10

signal freeing(target)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func collect():
	#print("Collecting")
	freeing.emit(self)
