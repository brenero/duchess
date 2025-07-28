class_name HintBalloon
extends Node2D

# Referências aos sprites
@onready var balloon_bg: Sprite2D = $BalloonBG
@onready var right_arrow: Sprite2D = $RightArrow
@onready var left_arrow: Sprite2D = $LeftArrow
@onready var exclamation: Sprite2D = $Exclamation

# Estados da dica
enum HintType {
	NONE,
	ARROW_LEFT,
	ARROW_RIGHT,
	EXCLAMATION
}

func _ready():
	# Esconde o balão inicialmente
	visible = false
	
	# Esconde todos os ícones inicialmente
	hide_all_icons()

func show_hint(hint_type: HintType):
	# Primeiro esconde todos os ícones
	hide_all_icons()
	
	match hint_type:
		HintType.ARROW_LEFT:
			if left_arrow:
				left_arrow.visible = true
			visible = true
		HintType.ARROW_RIGHT:
			if right_arrow:
				right_arrow.visible = true
			visible = true
		HintType.EXCLAMATION:
			if exclamation:
				exclamation.visible = true
			visible = true
		HintType.NONE:
			visible = false

func hide_hint():
	hide_all_icons()
	visible = false

func hide_all_icons():
	# Esconde todos os sprites de ícones
	if right_arrow:
		right_arrow.visible = false
	if left_arrow:
		left_arrow.visible = false
	if exclamation:
		exclamation.visible = false