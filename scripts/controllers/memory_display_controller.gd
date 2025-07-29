# memory_display_controller.gd - Controller MVC para sistema de exibição de memórias
class_name MemoryDisplayController
extends Node

## Configurações do controller (editáveis no Inspector)
@export_group("Display Settings")
@export var pause_game_during_display: bool = true
@export var display_duration: float = 0.0  # 0 = aguarda input do usuário

## Sinais para comunicação com outros sistemas
signal memory_display_started(memory: Memoria)
signal memory_display_finished(memory: Memoria)
signal display_skipped(memory: Memoria)

## Referências dos componentes (View)
var photo_viewer: PhotoViewer
var narrative_text: NarrativeText
var memory_display_ui: Control

## Estado do controller
var current_memory: Memoria
var is_displaying: bool = false
var display_queue: Array[Memoria] = []

func _ready():
	add_to_group("memory_display_controller")
	initialize_components()

func initialize_components():
	setup_memory_display_ui()
	connect_component_signals()

func setup_memory_display_ui():
	# Procura a UI na cena ou cria uma instância
	memory_display_ui = get_tree().get_first_node_in_group("memory_display_ui")
	
	if not memory_display_ui:
		push_warning("MemoryDisplayController: UI não encontrada. Criando componentes programaticamente.")
		create_ui_components()
	else:
		find_ui_components()

func create_ui_components():
	# Cria o PhotoViewer diretamente na cena principal para garantir z-index
	photo_viewer = PhotoViewer.new()
	photo_viewer.name = "PhotoViewer"
	get_tree().current_scene.add_child(photo_viewer)
	print("PhotoViewer adicionado diretamente à cena principal")
	
	# Cria o NarrativeText também na cena principal
	narrative_text = NarrativeText.new()
	narrative_text.name = "NarrativeText"
	get_tree().current_scene.add_child(narrative_text)
	print("NarrativeText adicionado diretamente à cena principal")
	
	# Cria UI container vazio (caso precisemos depois)
	memory_display_ui = Control.new()
	memory_display_ui.name = "MemoryDisplayUI"
	memory_display_ui.add_to_group("memory_display_ui")
	memory_display_ui.visible = false  # Escondido por enquanto
	get_tree().current_scene.add_child(memory_display_ui)

func find_ui_components():
	# Encontra componentes na UI existente
	photo_viewer = memory_display_ui.get_node_or_null("PhotoViewer")
	narrative_text = memory_display_ui.get_node_or_null("NarrativeText")
	
	if not photo_viewer:
		push_error("MemoryDisplayController: PhotoViewer não encontrado na UI")
	if not narrative_text:
		push_error("MemoryDisplayController: NarrativeText não encontrado na UI")

func connect_component_signals():
	if photo_viewer:
		photo_viewer.photo_displayed.connect(_on_photo_displayed)
		photo_viewer.photo_hidden.connect(_on_photo_hidden)
		print("PhotoViewer sinais conectados")
	
	if narrative_text:
		narrative_text.text_displayed_complete.connect(_on_text_complete)
		narrative_text.continue_pressed.connect(_on_continue_pressed)
		print("NarrativeText sinais conectados")
	else:
		print("ERRO: NarrativeText é null, não foi possível conectar sinais")

func display_memory(memory: Memoria):
	if not memory:
		push_error("MemoryDisplayController: Tentativa de exibir memória nula")
		return
	
	if is_displaying:
		# Adiciona à fila se já estiver exibindo outra memória
		display_queue.append(memory)
		return
	
	current_memory = memory
	is_displaying = true
	
	# Pausa o jogo se configurado
	if pause_game_during_display:
		get_tree().paused = true
	
	memory_display_started.emit(memory)
	start_memory_display()

func start_memory_display():
	if not current_memory:
		return
	
	print("Iniciando exibição da memória: ", current_memory.memory_title)
	
	# Exibe a foto se disponível
	if current_memory.memory_photo and photo_viewer:
		print("Memória tem foto: ", current_memory.memory_photo != null)
		print("PhotoViewer existe: ", photo_viewer != null)
		print("Exibindo foto...")
		photo_viewer.display_photo(current_memory.memory_photo, true)
	else:
		print("Sem foto, indo direto para texto...")
		print("current_memory.memory_photo: ", current_memory.memory_photo)
		print("photo_viewer: ", photo_viewer)
		_on_photo_displayed()  # Pula para o texto se não há foto

func _on_photo_displayed():
	# Após foto ser exibida, mostra o texto narrativo
	print("Foto exibida, mostrando texto narrativo...")
	if narrative_text and current_memory:
		print("Chamando display_narrative com: ", current_memory.memory_title)
		narrative_text.display_narrative(
			current_memory.memory_title,
			current_memory.memory_description,
			true
		)
	else:
		print("ERRO: narrative_text ou current_memory é null")
		print("narrative_text: ", narrative_text)
		print("current_memory: ", current_memory)

func _on_text_complete():
	# Texto foi totalmente exibido, aguarda interação do usuário
	pass

func _on_continue_pressed():
	# Usuário pressionou continuar, finaliza exibição
	print("Controller recebeu sinal de continuar!")
	finish_memory_display()

func finish_memory_display():
	if not is_displaying:
		return
	
	# Esconde componentes
	if photo_viewer:
		photo_viewer.hide_with_fade()
	else:
		_on_photo_hidden()

func _on_photo_hidden():
	# Limpa estado e emite sinal de finalização
	var finished_memory = current_memory
	current_memory = null
	is_displaying = false
	
	# Remove pausa do jogo
	if pause_game_during_display and get_tree():
		get_tree().paused = false
	
	# Esconde texto
	if narrative_text:
		narrative_text.hide_narrative()
	
	memory_display_finished.emit(finished_memory)
	
	# Processa próximo da fila se houver
	process_display_queue()

func process_display_queue():
	if display_queue.size() > 0:
		var next_memory = display_queue.pop_front()
		display_memory(next_memory)

func skip_current_display():
	if not is_displaying or not current_memory:
		return
	
	var skipped_memory = current_memory
	
	# Para animações
	if narrative_text:
		narrative_text.skip_typewriter()
	
	display_skipped.emit(skipped_memory)
	finish_memory_display()

func _input(event):
	# Permite pular com ESC ou clique
	if is_displaying and event.is_pressed():
		print("Input recebido durante display: ", event)
		if event.is_action("ui_cancel") or event is InputEventMouseButton:
			if narrative_text and narrative_text.is_displaying_text:
				print("Pulando typewriter...")
				narrative_text.skip_typewriter()
			else:
				print("Pulando display...")
				skip_current_display()

func get_display_status() -> Dictionary:
	return {
		"is_displaying": is_displaying,
		"current_memory": current_memory.memory_title if current_memory else "none",
		"queue_size": display_queue.size(),
		"game_paused": get_tree().paused if get_tree() else false
	}
