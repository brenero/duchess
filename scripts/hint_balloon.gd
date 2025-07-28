class_name HintBalloon
extends Node2D

# Referências aos sprites
@onready var balloon_bg: Sprite2D = $BalloonBG
@onready var hint_icon: Sprite2D = $HintIcon

# Configurações do spritesheet (editáveis no Inspector)
@export_group("Icon Spritesheet Settings")
@export var icon_spritesheet: Texture2D = preload("res://assets/icons/sheet_white2x.png")
@export var icon_size: Vector2i = Vector2i(32, 32)  ## Tamanho de cada ícone no spritesheet
@export var arrow_right_position: Vector2i = Vector2i(4, 0)  ## Posição do ícone seta direita (em grid)
@export var arrow_left_position: Vector2i = Vector2i(3, 0)   ## Posição do ícone seta esquerda (em grid)
@export var exclamation_position: Vector2i = Vector2i(0, 0)  ## Posição do ícone exclamação (em grid)

# Texturas das dicas
var arrow_right_texture: Texture2D
var arrow_left_texture: Texture2D  
var exclamation_texture: Texture2D

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
	
	# Carrega as texturas do spritesheet
	load_spritesheet_textures()

func load_spritesheet_textures():
	# Carrega ícones do spritesheet usando AtlasTexture
	arrow_right_texture = create_atlas_texture(arrow_right_position)
	arrow_left_texture = create_atlas_texture(arrow_left_position)
	exclamation_texture = create_atlas_texture(exclamation_position)

func create_atlas_texture(grid_position: Vector2i) -> AtlasTexture:
	# Cria uma AtlasTexture que referencia uma região específica do spritesheet
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = icon_spritesheet
	
	# Calcula a região baseada na posição no grid
	var region_x = grid_position.x * icon_size.x
	var region_y = grid_position.y * icon_size.y
	
	atlas_texture.region = Rect2(region_x, region_y, icon_size.x, icon_size.y)
	
	return atlas_texture

func show_hint(hint_type: HintType):
	if not hint_icon:
		return
		
	match hint_type:
		HintType.ARROW_LEFT:
			hint_icon.texture = arrow_left_texture
			visible = true
		HintType.ARROW_RIGHT:
			hint_icon.texture = arrow_right_texture
			visible = true
		HintType.EXCLAMATION:
			hint_icon.texture = exclamation_texture
			visible = true
		HintType.NONE:
			visible = false

func hide_hint():
	visible = false