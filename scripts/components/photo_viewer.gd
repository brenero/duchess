# photo_viewer.gd - Versão com CanvasLayer para garantir que apareça acima
class_name PhotoViewer
extends CanvasLayer

## Sinais para comunicação com o Controller
signal photo_displayed
signal photo_hidden

var overlay: ColorRect
var is_displaying: bool = false

func _ready():
	create_overlay()
	hide()

func create_overlay():
	# CanvasLayer tem layer alto para ficar acima de tudo
	layer = 100
	
	# 1. Fundo escuro que cobre tudo (como backdrop)
	overlay = ColorRect.new()
	overlay.name = "DarkOverlay"
	overlay.color = Color(0, 0, 0, 0.8)  # Fundo escuro semi-transparente
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	
	# 2. Container retangular centralizado (usando anchors do Godot)
	var container = Panel.new()
	container.name = "PhotoContainer"
	container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# Tamanho do container
	var container_size = Vector2(120, 180)
	container.custom_minimum_size = container_size
	container.size = container_size
	
	# Pequeno ajuste para cima (usando offset em vez de position manual)
	container.position.y -= 100
	container.position.x -= 80
	
	# Estilo do container (borda, fundo, etc.)
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.ANTIQUE_WHITE
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.1, 0.1, 0.1, 1) # Borda escura
	container.add_theme_stylebox_override("panel", style_box)
	
	add_child(container)
	
	# 3. Container de Margem para criar o padding geral
	var margin_container = MarginContainer.new()
	margin_container.name = "MarginContainer"
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Define o padding de 8px em todos os lados
	margin_container.add_theme_constant_override("margin_left", 8)
	margin_container.add_theme_constant_override("margin_right", 8)
	margin_container.add_theme_constant_override("margin_top", 8)
	margin_container.add_theme_constant_override("margin_bottom", 8)
	container.add_child(margin_container)

	# 4. Layout flexbox vertical (dentro do MarginContainer)
	var flex_container = VBoxContainer.new()
	flex_container.name = "FlexContainer"
	# Adiciona separação entre a foto e o texto
	flex_container.add_theme_constant_override("separation", 8)
	margin_container.add_child(flex_container)
	
	# 5. Área da foto (ocupa o espaço restante)
	var photo_area = Control.new()
	photo_area.name = "PhotoArea"
	photo_area.size_flags_vertical = Control.SIZE_EXPAND_FILL  # flex-grow: 1
	flex_container.add_child(photo_area)
	
	# TextureRect para exibir a foto
	var photo_texture = TextureRect.new()
	photo_texture.name = "PhotoTexture"
	photo_texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	photo_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	photo_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	photo_area.add_child(photo_texture)
	
	# Armazena referência da foto
	self.set_meta("photo_texture", photo_texture)
	
	# 6. Área do texto (altura fixa)
	var text_area = Control.new()
	text_area.name = "TextArea"
	text_area.custom_minimum_size.y = 36
	text_area.size_flags_vertical = Control.SIZE_SHRINK_END
	flex_container.add_child(text_area)
	
	# Armazena referência da área de texto
	self.set_meta("text_area", text_area)
	
	print("PhotoViewer: Layout com MarginContainer criado")

func display_photo(photo: Texture2D, _fade_in: bool = true):
	print("PhotoViewer: Mostrando overlay com foto")
	
	# Pega a referência do TextureRect criado
	var photo_texture = self.get_meta("photo_texture", null)
	
	if photo and photo_texture:
		photo_texture.texture = photo
		print("Foto definida no TextureRect: ", photo.get_size())
	else:
		print("Sem foto ou TextureRect não encontrado")
	
	show()
	is_displaying = true
	photo_displayed.emit()

func add_text_to_area(description: String):
	print("PhotoViewer: Adicionando texto à área")
	
	var text_area = self.get_meta("text_area", null)
	if not text_area:
		print("PhotoViewer: Área de texto não encontrada")
		return
	
	# Remove texto anterior se existir
	for child in text_area.get_children():
		if child.name == "TextLabel":
			child.queue_free()
	
	# Cria label para o texto
	var text_label = RichTextLabel.new()
	text_label.name = "TextLabel"
	text_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Aumenta o padding do texto
	text_label.add_theme_constant_override("margin_left", 8)
	text_label.add_theme_constant_override("margin_right", 8)
	text_label.add_theme_constant_override("margin_top", 4)
	text_label.add_theme_constant_override("margin_bottom", 4)
	text_label.bbcode_enabled = true
	text_label.fit_content = true
	text_label.add_theme_font_size_override("normal_font_size", 9)
	text_label.add_theme_color_override("default_color", Color.BLACK)
	
	# Define o texto
	var full_text = description
	text_label.text = full_text
	
	text_area.add_child(text_label)

func hide_with_fade():
	if not is_displaying:
		return
	
	print("PhotoViewer: Escondendo overlay")
	hide()
	is_displaying = false
	photo_hidden.emit()

func get_display_info() -> Dictionary:
	return {
		"is_displaying": is_displaying,
		"has_photo": false,
		"photo_size": Vector2.ZERO
	}
