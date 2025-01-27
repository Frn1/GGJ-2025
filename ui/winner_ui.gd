extends Control

var format_string: String
@onready var label: Label = $Control/Label
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	format_string = label.text
	label.text = ""

func show_result(winner: int) -> void:
	if winner == 0:
		anim_player.play("p0_win")
	elif winner == 1:
		anim_player.play("p1_win")
	else:
		anim_player.play("tie")
