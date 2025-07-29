# narrative_text.gd - Versão que usa a área de texto do PhotoViewer
class_name NarrativeText
extends Control

## Sinais para comunicação com o Controller
signal text_displayed_complete
signal continue_pressed

var current_text: String = ""
var current_title: String = ""

func _ready():
	hide()
	print("NarrativeText: Componente simplificado")

func display_narrative(title: String, description: String, use_typewriter: bool = true):
	print("NarrativeText: Chamando PhotoViewer para exibir texto")
	current_title = title
	current_text = description
	
	# Encontra o PhotoViewer e chama sua função de adicionar texto  
	var photo_viewer = get_parent().get_node_or_null("PhotoViewer")
	if not photo_viewer:
		# Procura na cena inteira
		photo_viewer = find_photo_viewer_in_scene()
	
	if photo_viewer and photo_viewer.has_method("add_text_to_area"):
		photo_viewer.add_text_to_area(description)
		print("NarrativeText: Texto enviado para PhotoViewer")
	else:
		print("NarrativeText: PhotoViewer não encontrado")
	
	# Emite sinal de que terminou
	text_displayed_complete.emit()

func find_photo_viewer_in_scene():
	# Procura PhotoViewer em toda a cena
	var all_nodes = get_tree().get_nodes_in_group("memory_display_controller")
	for node in all_nodes:
		if node.name == "PhotoViewer":
			return node
	
	# Procura de forma mais ampla
	return get_tree().current_scene.find_child("PhotoViewer", true, false)

func hide_narrative():
	hide()

func get_text_info() -> Dictionary:
	return {
		"is_displaying": false,
		"current_title": current_title,
		"current_text": current_text,
		"text_length": current_text.length()
	}
