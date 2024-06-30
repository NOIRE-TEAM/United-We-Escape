extends Control

@onready var container = $HSplitContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _set_name(name):
	$HSplitContainer/uid.set_text(name)

func _set_status(status):
	$HSplitContainer/status.set_text(status)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
