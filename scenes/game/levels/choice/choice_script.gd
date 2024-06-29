extends Node2D
class_name Choice

var level = [[0, 0, 0],
			 [0, 0, 0],
			 [0, 0, 0]]

var startPosX = 0
var startPosY = 0
var endPosX = 2
var endPosY = 2

@onready var button1 = $Button
@onready var button2 = $Button2
@onready var button3 = $Button3
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	Lobby.player_info.test = 2
	#rpc_id(1,"update_info", multiplayer.get_unique_id(), Lobby.player_info.test)
	#Lobby.player_loaded.rpc_id(1)

##Сделать ловушки на случайные комнаты
##Функцию голосования, но как получить вариант выбора?

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Time_to_choice.set_text(str(snapped(timer.time_left, 0.1)))
	
	print(Lobby.players)
	#print(multiplayer.get_remote_sender_id(), multiplayer.get_unique_id())
	#var local_player_id = get_tree().get_network_unique_id()
	
@rpc("authority", "call_local", "reliable")
func update_data(player_id,data):
	#print(player_id, " ", data)
	Lobby.players[player_id] = data
	
@rpc("any_peer", "call_local", "reliable")
func update_info(player_id,data):
	#print(player_id, " ", data)
	#Lobby.players[player_id] = data
	for player in Lobby.players:
		#print(player)
		rpc_id(player,"update_data", player_id, Lobby.player_info)


func start_game():
	print("hui")

func _on_timer_timeout():
	Lobby.player_info.suka = [1, 2 ,3]
	rpc_id(1,"update_info", multiplayer.get_unique_id(), Lobby.player_info)
