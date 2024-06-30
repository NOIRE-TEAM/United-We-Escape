extends Control

const knights_names = [
	"Сэр Ланселот Храбрый",
	"Сэр Галахад Непорочный",
	"Сэр Бедевер Мудрый",
	"Сэр Робин НеНастолькоХрабрыйКакСэрЛанселот"
]
const ghost_name = "Чёрный Дух"

var level = [[0, 0, 0],
			 [0, 0, 0],
			 [0, 0, 0]]

var startPosX: int = 0
var startPosY: int = 0
var endPosX: int = 2
var endPosY: int = 2

var choiceX: int = -1
var choiceY: int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	# Preconfigure game.

	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CenterContainer/GridContainer/Button1.set_text(str(level[0][0]))
	$CenterContainer/GridContainer/Button2.set_text(str(level[0][1]))
	$CenterContainer/GridContainer/Button3.set_text(str(level[0][2]))
	$CenterContainer/GridContainer/Button4.set_text(str(level[1][0]))
	$CenterContainer/GridContainer/Button5.set_text(str(level[1][1]))
	$CenterContainer/GridContainer/Button6.set_text(str(level[1][2]))
	$CenterContainer/GridContainer/Button7.set_text(str(level[2][0]))
	$CenterContainer/GridContainer/Button8.set_text(str(level[2][1]))
	$CenterContainer/GridContainer/Button9.set_text(str(level[2][2]))

# Called only on the server.
func start_game():
	pass # All peers are ready to receive RPCs in this scene.

func _on_choice(x: int, y: int):
	if choiceX != -1:
		level[choiceX][choiceY] -= 1
	choiceX = x
	choiceY = y
	level[choiceX][choiceY] += 1
	print(x, "; ", y)

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
