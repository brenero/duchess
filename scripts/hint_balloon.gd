extends Node2D

# Referências aos sprites
@onready var balloon_bg: Sprite2D = $BalloonBG
@onready var hint_icon: Sprite2D = $HintIcon

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
	
	# Carrega as texturas (por enquanto usando texturas básicas do Godot)
	# No futuro você pode substituir por suas próprias imagens
	load_default_textures()

func load_default_textures():
	# Por enquanto vamos criar texturas simples usando código
	# Mais tarde você pode substituir por imagens reais
	arrow_right_texture = create_simple_arrow_texture(true)
	arrow_left_texture = create_simple_arrow_texture(false)
	exclamation_texture = create_simple_exclamation_texture()

func create_simple_arrow_texture(pointing_right: bool) -> ImageTexture:
	# Cria uma texture simples para as setas
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Desenha uma seta simples (apenas uma representação básica)
	for y in range(8, 24):
		for x in range(8, 24):
			if pointing_right:
				if x >= 12 and x <= 20 and y >= 14 and y <= 18:
					image.set_pixel(x, y, Color.WHITE)
				elif x >= 18 and x <= 22 and abs(y - 16) <= (x - 18):
					image.set_pixel(x, y, Color.WHITE)
			else:
				if x >= 12 and x <= 20 and y >= 14 and y <= 18:
					image.set_pixel(x, y, Color.WHITE)
				elif x >= 10 and x <= 14 and abs(y - 16) <= (14 - x):
					image.set_pixel(x, y, Color.WHITE)
	
	var texture = ImageTexture.create_from_image(image)
	return texture

func create_simple_exclamation_texture() -> ImageTexture:
	# Cria uma texture simples para a exclamação
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Desenha uma exclamação simples
	for y in range(6, 22):
		for x in range(14, 18):
			if y < 18:
				image.set_pixel(x, y, Color.YELLOW)
	
	# Ponto da exclamação
	for y in range(22, 26):
		for x in range(14, 18):
			image.set_pixel(x, y, Color.YELLOW)
	
	var texture = ImageTexture.create_from_image(image)
	return texture

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