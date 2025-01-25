extends Control

@onready var label: Label = $Label
var format_string: String

func _ready() -> void:
	format_string = label.text
	label.text = ""

func format_text(player_number) -> void:
	label.text = format_string.format([player_number])
