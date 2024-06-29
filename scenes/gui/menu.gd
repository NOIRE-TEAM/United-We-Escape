extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_connect_pressed():
	Lobby.join_game()
	#Lobby.load_game("res://scenes/test_choice.tscn")
	get_tree().change_scene_to_file("res://scenes/gui/supra_lobby.tscn")
	


func _on_create_lobby_pressed():
	Lobby.create_game()
	#Lobby.load_game("res://scenes/test_choice.tscn")
	get_tree().change_scene_to_file("res://scenes/gui/supra_lobby.tscn")
	
func _add_player(id = 1):
	pass
	
