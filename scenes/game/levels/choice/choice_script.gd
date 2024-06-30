extends Control

@onready var timer = $Timer
@onready var container = $VBoxContainer/HBoxContainer

var votes = {}
var buttons = []
var choice_id = "-1"

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Player_to_kick.set_text("")
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
	print(votes)
	#rpc_id(1,"update_info", multiplayer.get_unique_id(), Lobby.player_info.test)
	#Lobby.player_loaded.rpc_id(1)
	
@rpc("any_peer", "call_local", "reliable")
func update_votes(player_name, delta):
	votes[player_name] += delta

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
	
	
	#print(multiplayer.get_remote_sender_id(), multiplayer.get_unique_id())
	#var local_player_id = get_tree().get_network_unique_id()

func start_game():
	print("hui")

func _on_timer_timeout():
	var max = -1
	var kicked_player = ""
	for button in buttons:
		if votes[button.text] > max:
			max = votes[button.text]
			kicked_player = button.text
	if max == 0:
		$VBoxContainer/Player_to_kick.set_text("Выбранный игрок: никто")
	else:
		$VBoxContainer/Player_to_kick.set_text("Выбранный игрок: " + kicked_player)
		#print(int(kicked_player))
		Lobby.players[int(kicked_player)].status = "✖"
	$Show_kick_timer.start(3)
	#rpc_id(1,"update_info", multiplayer.get_unique_id(), Lobby.players)


func _on_visibility_changed():
	if visible:
		timer.start(10)
		$VBoxContainer/Player_to_kick.set_text("")


func _on_show_kick_timer_timeout():
	visible = not visible
