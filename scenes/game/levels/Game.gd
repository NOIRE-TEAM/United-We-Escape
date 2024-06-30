extends Control

const knights_names = [
	"Сэр Ланселот Храбрый",
	"Сэр Галахад Непорочный",
	"Сэр Бедевер Мудрый",
	"Сэр Робин НеНастолькоХрабрыйКакСэрЛанселот"
]
const ghost_name = "Чёрный Дух"

@onready var container = $HSplitContainer/ScrollContainer/VBoxContainer
@onready var one_player = preload("res://scenes/game/levels/game_players_list/PlayerElem.tscn")
@onready var timer = $Vote_timer
@onready var vote_kick = $HSplitContainer/VBoxContainer/MarginContainer

var level = [[0, 0, 0],
			 [0, 0, 0],
			 [0, 0, 0]]



var startPosX: int = 0
var startPosY: int = 0
var endPosX: int = 2
var endPosY: int = 2

var posX:int = 0
var posY:int = 0

var choiceX: int = -1
var choiceY: int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	vote_kick.hide()
	# Preconfigure game.
	Lobby.player_info.status = "✓"
	rpc_id(1,"update_info", multiplayer.get_unique_id(), Lobby.player_info)
	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	get_tree().paused = true

func add_label_player(player_id):
	var label = one_player.instantiate()
	label._set_name(str(player_id))
	label._set_status(Lobby.players[player_id].status)
	container.add_child(label)

@rpc("authority", "call_local", "reliable")
func update_data(player_id,data):
	#print(player_id, " ", data)
	Lobby.players[player_id] = data.duplicate(true)
	
@rpc("any_peer", "call_local", "reliable")
func update_info(player_id,data):
	#print(player_id, " ", data)
	#Lobby.players[player_id] = data
	for player in Lobby.players:
		rpc_id(player,"update_data", player_id, Lobby.player_info)

func update_labels():
	for child in container.get_children():
		child.queue_free()
	for player in Lobby.players:
		add_label_player(player)
		
@rpc("any_peer", "call_local", "reliable")
func update_level(y,x,delta):
	level[y][x] += delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HSplitContainer/VBoxContainer/Label.set_text("Время до конца голосвания: " + str(snapped(timer.time_left, 1)))
	update_labels()

	for y in range(0,3):
		for x in range(0,3):
			var button = $HSplitContainer/VBoxContainer/CenterContainer/GridContainer.get_child(x + y * 3)
			button.set_text(str(level[y][x]))
			if absi(x - posX) == 1 && absi(y - posY) == 0 && $HSplitContainer/VBoxContainer/Label.visible:
				button.disabled = false
			elif absi(x - posX) == 0 && absi(y - posY) == 1 && $HSplitContainer/VBoxContainer/Label.visible:
				button.disabled = false
			else:
				button.disabled = true
				button.set_text("")
			
			if x == posX && y == posY:
				button.self_modulate = Color(255, 0, 0)
			else:
				button.self_modulate = Color(255, 255, 255)
				
@rpc("any_peer", "call_local", "reliable")
func unpause_game():
	get_tree().paused = false

# Called only on the server.
func start_game():
	for player in Lobby.players:
		rpc_id(player, "unpause_game")

func _on_choice(y: int, x: int):
	if choiceX != -1:
		#level[choiceX][choiceY] -= 1
		for player in Lobby.players:
			rpc_id(player,"update_level", choiceY, choiceX, -1)
	choiceX = x
	choiceY = y
	#level[choiceX][choiceY] += 1
	for player in Lobby.players:
		rpc_id(player,"update_level", choiceY, choiceX, 1)
	print(y, "; ", x)

func _on_button_1_pressed():
	_on_choice(0, 0)

func _on_button_2_pressed():
	_on_choice(0, 1)

func _on_button_3_pressed():
	_on_choice(0, 2)

func _on_button_4_pressed():
	_on_choice(1, 0)

func _on_button_5_pressed():
	_on_choice(1, 1)

func _on_button_6_pressed():
	_on_choice(1, 2)

func _on_button_7_pressed():
	_on_choice(2, 0)

func _on_button_8_pressed():
	_on_choice(2, 1)

func _on_button_9_pressed():
	_on_choice(2, 2)

func _on_vote_timer_timeout():
	var max = 0
	var maxX = posX
	var maxY = posY
	if maxX < 2:
		maxX += 1
	else:
		maxX -= 1
	for y in range(0,3):
		for x in range(0,3):
			if level[y][x] > max:
				max = level[y][x]
				maxX = x
				maxY = y
	posX = maxX
	posY = maxY
	for y in range(0,3):
		for x in range(0,3):
			level[y][x] = 0
	choiceX = -1
	choiceY = -1
	$HSplitContainer/VBoxContainer/Label.hide()
	vote_kick.show()
	$HSplitContainer/VBoxContainer/MarginContainer/Node2D2.show()


func _on_node_2d_2_visibility_changed():
	print("changechan")
	if not $HSplitContainer/VBoxContainer/MarginContainer/Node2D2.visible:
		$HSplitContainer/VBoxContainer/Label.show()
		vote_kick.hide()
		timer.start(10)
	
