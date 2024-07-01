extends Control

@onready var timer = $Timer
@onready var container = $VBoxContainer/HBoxContainer
@onready var skip_button = $VBoxContainer/Button

var votes = {}
var buttons = []
var choice_id = "-1"
var kicked_player = ""

signal can_continue_signal(new_result)

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect("my_signal", self, "my_method")
	$VBoxContainer/Player_to_kick.set_text("Вы попали в ловушку. Хотите кого-то выгнать?")
	Lobby.player_info.test = 2
	for child in container.get_children():
		child.queue_free()
	
	for player in Lobby.players:
		var button = Button.new()
		button.pressed.connect(is_button_pressed.bind(str(player)))
		buttons.append(button)
		button.set_text(str(player))
		votes[str(player)] = 0
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL 
		container.add_child(button)
	votes[skip_button.text] = 0
	buttons.append(skip_button)
	print(votes)
	#rpc_id(1,"update_info", multiplayer.get_unique_id(), Lobby.player_info.test)
	#Lobby.player_loaded.rpc_id(1)
	
@rpc("any_peer", "call_local", "reliable")
func update_votes(player_name, delta):
	votes[player_name] += delta

@rpc("any_peer", "call_remote", "reliable")
func sync_result(result):
	#kicked_player = result
	print("QQEQNQNDON1 ", kicked_player, ", id ", multiplayer.get_unique_id())
	can_continue_signal.emit(result)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$VBoxContainer/Time_to_choice.set_text(str(snapped(timer.time_left, 0.1)))
	#print(Lobby.players)
	
func is_button_pressed(id):
	if choice_id != "-1":
		for player in Lobby.players:
			rpc_id(player,"update_votes", id, -1)
	choice_id = id
	for player in Lobby.players:
		rpc_id(player,"update_votes", id, 1)
	print("Vote for: " + id)

func _on_timer_timeout():
	var max = -1
	for button in buttons:
		if votes[button.text] > max:
			max = votes[button.text]
			kicked_player = button.text
	$VBoxContainer/Player_to_kick.set_text("Подсчёт голосов...")
	for player in Lobby.players:
		if (player != 1 && multiplayer.get_unique_id() == 1):
			print("QQEQNQNDON2 ", kicked_player)
			rpc_id(player, "sync_result", kicked_player)
	if multiplayer.get_unique_id() != 1:
		kicked_player = await can_continue_signal
	print("QQEQNQNDON ", kicked_player)
	if max == 0:
		$VBoxContainer/Player_to_kick.set_text("Выбор не был сделан")
	elif kicked_player == skip_button.text:
		$VBoxContainer/Player_to_kick.set_text("Игроки выбрали пропустить голосование")
	else:
		$VBoxContainer/Player_to_kick.set_text("Выбранный игрок: " + Lobby.players[int(kicked_player)].name)
		#print(int(kicked_player))
		Lobby.players[int(kicked_player)].status = "✖"
	print(votes)
	$Show_kick_timer.start(3)
	#rpc_id(1,"update_info", multiplayer.get_unique_id(), Lobby.players)


func _on_visibility_changed():
	if visible:
		timer.start(10)
		$VBoxContainer/Player_to_kick.set_text("Вы попали в ловушку. Хотите кого-то выгнать?")


func _on_show_kick_timer_timeout():
	visible = not visible


func _on_button_pressed():
	is_button_pressed(skip_button.text)
