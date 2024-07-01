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
			
var traps = level.duplicate(true)

var route = level.duplicate(true)

var startPosX: int = 0
var startPosY: int = 0
var endPosX: int = 2
var endPosY: int = 2

var posX:int = 0
var posY:int = 0

var choiceX: int = -1
var choiceY: int = -1

var HP = 100
var trapDamage = 50
var trapsNumber = 3
var HPLabelConst = "HP: "
@onready var HPLabel = $VBoxContainer2/HPLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	vote_kick.hide()
	# Preconfigure game.
	Lobby.player_info.status = "✓"
	rpc_id(1,"update_info", multiplayer.get_unique_id(), Lobby.player_info)
	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	
	if multiplayer.is_server():
		add_traps(trapsNumber)
		
	print(level)
	print(traps)
	
	HPLabel.text = HPLabelConst + str(HP)
	
	get_tree().paused = true
	
func add_traps(traps_number: int):
	var placed_ones = 0
	
	while placed_ones < traps_number:
		var i = randi() % traps.size()
		var j = randi() % traps[0].size()
		
		if traps[i][j] == 0 && (i > 0 || j > 0) && (i < 2 || j < 2):
			traps[i][j] = 1
			placed_ones += 1
			
	for player in Lobby.players:
		if player == 1:
			continue
		rpc_id(player, 'update_traps', traps)
			
@rpc("any_peer", "call_local", "reliable")
func update_traps(traps_array):
	traps = traps_array.duplicate()

func add_label_player(player_id):
	var label = one_player.instantiate()
	var name = Lobby.players[player_id].name
	if player_id == multiplayer.get_unique_id():
		name += " (Вы)"
	label._set_name(name)
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
				button.set_text("x")
			
			if x == posX && y == posY:
				button.self_modulate = Color.ORANGE
				
			elif route[y][x] == 1:
				button.self_modulate = Color8(144, 238, 144)
			elif route[y][x] == 2:
				button.self_modulate = Color.RED
			elif x == 2 && y == 2:
				button.self_modulate = Color.CYAN
			else:
				button.self_modulate = Color8(255, 255, 255)
				
@rpc("any_peer", "call_local", "reliable")
func unpause_game():
	get_tree().paused = false

@rpc("any_peer", "call_local", "reliable")
func player_set_name(name):
	Lobby.players[multiplayer.get_unique_id()].name = name
	for player in Lobby.players:
		rpc_id(player, "id_set_name", multiplayer.get_unique_id(), name)

@rpc("any_peer", "call_local", "reliable")
func id_set_name(id, name):
	Lobby.players[id].name = name

# Called only on the server.
func start_game():
	var counter: int = 0
	for player in Lobby.players:
		rpc_id(player, "unpause_game")
		rpc_id(player, "player_set_name", knights_names[counter])
		counter += 1

func _on_choice(y: int, x: int):
	print(Lobby.players)
	if Lobby.players[multiplayer.get_unique_id()].status == "✖":
		return
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
	print('Traps: ', traps)

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
	
	if route[posY][posX] == 0:
		route[posY][posX] = 1
	
	posX = maxX
	posY = maxY
	for y in range(0,3):
		for x in range(0,3):
			level[y][x] = 0
	choiceX = -1
	choiceY = -1
	
	$HSplitContainer/VBoxContainer/Label.hide()
	
	if posX == 2 && posY == 2:
		for player in Lobby.players:
			if player == 1:
				continue
			rpc_id(player,"load_ending","res://scenes/game/levels/endings/winner.tscn")
		rpc("load_ending","res://scenes/game/levels/endings/winner.tscn")
	
	if traps[posY][posX] == 1:
		route[posY][posX] = 2
		HP -= trapDamage
		HPLabel.text = HPLabelConst + str(HP)
		
		if HP <= 0:
			for player in Lobby.players:
				if player == 1:
					continue
				rpc_id(player,"load_ending","res://scenes/game/levels/endings/looser.tscn")
			rpc("load_ending","res://scenes/game/levels/endings/looser.tscn")
		
		vote_kick.show()
		$HSplitContainer/VBoxContainer/MarginContainer/Node2D2.show()
	else: 
		_on_node_2d_2_visibility_changed()

@rpc("any_peer", "call_local", "reliable")
func load_ending(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)

func _on_node_2d_2_visibility_changed():
	print("changechan")
	if not $HSplitContainer/VBoxContainer/MarginContainer/Node2D2.visible:
		$HSplitContainer/VBoxContainer/Label.show()
		vote_kick.hide()
		timer.start(10)
	
