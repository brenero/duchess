class_name HintSystemController
extends Node

## Controller responsável pelo sistema de dicas visuais
## Gerencia a apresentação de hints sem conhecer a lógica de descoberta

# Configurações
@export_group("Hint System Settings")
@export var hint_update_rate: float = 0.1  ## Taxa de atualização das dicas em segundos
@export var auto_hide_on_exit: bool = true  ## Se deve esconder hints automaticamente

# Signals para comunicação
signal hint_shown(hint_type: HintBalloon.HintType)
signal hint_hidden()

# Componentes
var hint_balloon: HintBalloon
var discovery_controller: MemoryDiscoveryController
var player: CharacterBody2D

# Estado interno
var _is_active: bool = false
var _hint_timer: float = 0.0
var _last_hint_type: HintBalloon.HintType = HintBalloon.HintType.NONE

func _ready():
	# Inicializa referências
	await get_tree().process_frame
	initialize_references()

func initialize_references():
	# Encontra player
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("HintSystemController: Player não encontrado!")
		return
	
	# Encontra hint balloon no player
	hint_balloon = player.get_node_or_null("HintBalloon")
	if not hint_balloon:
		push_error("HintSystemController: HintBalloon não encontrado no player!")
		return
	
	# Encontra ou cria discovery controller
	discovery_controller = get_node_or_null("../MemoryDiscoveryController")
	if not discovery_controller:
		# Tenta encontrar em outro lugar da árvore
		discovery_controller = get_tree().get_first_node_in_group("memory_discovery_controller")
	
	if not discovery_controller:
		push_warning("HintSystemController: MemoryDiscoveryController não encontrado. Criando um temporário.")
		create_discovery_controller()

func create_discovery_controller():
	# Cria controller se não existir (fallback)
	discovery_controller = MemoryDiscoveryController.new()
	discovery_controller.name = "MemoryDiscoveryController"
	get_parent().add_child(discovery_controller)
	discovery_controller.add_to_group("memory_discovery_controller")

func _process(delta: float):
	if _is_active:
		_update_hints(delta)

## Ativa o sistema de hints
func activate_hints():
	if not _is_active:
		_is_active = true
		_hint_timer = 0.0
		_update_hints(0.0)  # Atualização imediata

## Desativa o sistema de hints
func deactivate_hints():
	if _is_active:
		_is_active = false
		if auto_hide_on_exit:
			hide_hints()

## Força atualização imediata das dicas
func force_hint_update():
	if _is_active and player and discovery_controller:
		_show_appropriate_hint()

## Esconde todas as dicas
func hide_hints():
	if hint_balloon and hint_balloon.visible:
		hint_balloon.hide_hint()
		_last_hint_type = HintBalloon.HintType.NONE
		hint_hidden.emit()

## Mostra dica específica (para casos especiais)
func show_specific_hint(hint_type: HintBalloon.HintType):
	if hint_balloon:
		hint_balloon.show_hint(hint_type)
		_last_hint_type = hint_type
		hint_shown.emit(hint_type)

## Verifica se o sistema está ativo
func is_active() -> bool:
	return _is_active

## Retorna o tipo de hint atual
func get_current_hint_type() -> HintBalloon.HintType:
	return _last_hint_type

## Configura a taxa de atualização
func set_update_rate(new_rate: float):
	hint_update_rate = max(0.01, new_rate)  # Mínimo de 10ms

# === MÉTODOS PRIVADOS ===

func _update_hints(delta: float):
	if not player or not discovery_controller or not hint_balloon:
		return
	
	_hint_timer += delta
	
	# Atualiza apenas na taxa configurada
	if _hint_timer >= hint_update_rate:
		_show_appropriate_hint()
		_hint_timer = 0.0

func _show_appropriate_hint():
	# Calcula o tipo de hint apropriado
	var hint_type = discovery_controller.calculate_hint_type(
		player.global_position,
		48.0  # Usando distância padrão - pode ser configurável no futuro
	)
	
	# Só atualiza se mudou
	if hint_type != _last_hint_type:
		_last_hint_type = hint_type
		
		if hint_type == HintBalloon.HintType.NONE:
			hide_hints()
		else:
			hint_balloon.show_hint(hint_type)
			hint_shown.emit(hint_type)

## Para debug e desenvolvimento
func debug_info() -> Dictionary:
	return {
		"is_active": _is_active,
		"hint_balloon_found": hint_balloon != null,
		"discovery_controller_found": discovery_controller != null,
		"player_found": player != null,
		"current_hint_type": HintBalloon.HintType.keys()[_last_hint_type],
		"update_rate": hint_update_rate,
		"timer": _hint_timer
	}

## Método para configurar dependências externamente (útil para testes)
func set_dependencies(balloon: HintBalloon, controller: MemoryDiscoveryController, player_node: CharacterBody2D):
	hint_balloon = balloon
	discovery_controller = controller  
	player = player_node
