extends Node2D

@onready var container = $ColorRect/ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	update_labels()

func add_label_player(player_id):
	var label = Label.new()
	label.text = str(player_id)
	container.add_child(label)

func update_labels():
	for child in container.get_children():
		child.queue_free()
	for player in Lobby.players:
		add_label_player(player)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_labels()

@rpc("any_peer", "call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)

func _on_button_pressed():
	for player in Lobby.players:
		rpc_id(player,"load_game","res://scenes/test_choice.tscn")
