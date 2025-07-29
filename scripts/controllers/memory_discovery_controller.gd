class_name MemoryDiscoveryController
extends Node

## Controller responsável pela lógica de descoberta e localização de memórias
## Separa a lógica de negócio da apresentação e estados

# Signals para comunicação desacoplada
signal memory_discovered(memory: Memoria)
signal memory_collected(memory: Memoria)
signal current_target_changed(new_target: Memoria)

# Referências principais
var memory_manager: Node
var player: CharacterBody2D

# Cache para performance
var _current_target_cache: Memoria
var _cache_valid: bool = false

func _ready():
	# Inicializa referências
	await get_tree().process_frame  # Espera um frame para garantir que tudo foi carregado
	initialize_references()

func initialize_references():
	# Encontra componentes necessários
	memory_manager = get_tree().get_first_node_in_group("memory_manager")
	player = get_tree().get_first_node_in_group("player")
	
	if not memory_manager:
		push_error("MemoryDiscoveryController: MemoryManager não encontrado!")
		return
		
	if not player:
		push_error("MemoryDiscoveryController: Player não encontrado!")
		return
	
	# Conecta aos signals do memory manager para invalidar cache
	if memory_manager.has_signal("memory_collected"):
		memory_manager.memory_collected.connect(_on_memory_collected)

## Retorna a memória alvo atual (com cache para performance)
func get_current_target_memory() -> Memoria:
	if not _cache_valid or not _current_target_cache:
		_update_target_cache()
	return _current_target_cache

## Verifica se o player está próximo de alguma memória para descoberta
func check_memory_proximity(player_position: Vector2, discovery_distance: float = 48.0) -> bool:
	var target = get_current_target_memory()
	if not target:
		return false
		
	var distance = player_position.distance_to(target.global_position)
	return distance <= discovery_distance

## Calcula o tipo de dica baseado na posição do player e da memória alvo
func calculate_hint_type(player_position: Vector2, discovery_distance: float = 48.0) -> HintBalloon.HintType:
	var target = get_current_target_memory()
	if not target:
		return HintBalloon.HintType.NONE
	
	var distance = player_position.distance_to(target.global_position)
	
	# Se está muito próximo, mostra exclamação
	if distance <= discovery_distance:
		return HintBalloon.HintType.EXCLAMATION
	
	# Determina direção horizontal
	var direction_x = target.global_position.x - player_position.x
	
	if direction_x > 0:
		return HintBalloon.HintType.ARROW_RIGHT
	else:
		return HintBalloon.HintType.ARROW_LEFT

## Força descoberta de uma memória específica
func discover_memory(memory: Memoria):
	if memory and not memory.is_discovered:
		memory.discover_memory()
		memory_discovered.emit(memory)

## Força coleta de uma memória específica
func collect_memory(memory: Memoria):
	if memory and memory.is_discovered and not memory.is_collected:
		memory.collect_memory()
		memory_collected.emit(memory)

## Tenta coletar memória via DIG na posição do player
func attempt_dig_collection(player_position: Vector2) -> Memoria:
	# Pega todas as memórias próximas
	var memories = get_tree().get_nodes_in_group("memories")
	
	for memory in memories:
		if memory is Memoria:
			if memory.attempt_collection_by_dig(player_position):
				memory_collected.emit(memory)
				print("Memória coletada via DIG: ", memory.memory_title)
				return memory
	
	print("Nenhuma memória próxima para cavar")
	return null

## Verifica se há uma memória coletável na posição (para feedback visual)
func has_collectible_memory_at_position(player_position: Vector2, max_distance: float = 48.0) -> Memoria:
	var memories = get_tree().get_nodes_in_group("memories")
	
	for memory in memories:
		if memory is Memoria and memory.can_be_collected_by_player(player_position, max_distance):
			return memory
	
	return null

## Retorna informações de progresso
func get_discovery_progress() -> Dictionary:
	if not memory_manager or not memory_manager.has_method("get_progress"):
		return {"collected": 0, "total": 0, "percentage": 0.0}
	
	return memory_manager.get_progress()

## Verifica se ainda há memórias para descobrir
func has_memories_remaining() -> bool:
	if not memory_manager or not memory_manager.has_method("has_memories_remaining"):
		return false
	
	return memory_manager.has_memories_remaining()

## Reseta o progresso de descoberta
func reset_discovery_progress():
	if memory_manager and memory_manager.has_method("reset_progress"):
		memory_manager.reset_progress()
		_invalidate_cache()

# === MÉTODOS PRIVADOS ===

func _update_target_cache():
	if not memory_manager or not memory_manager.has_method("get_current_memory_target"):
		_current_target_cache = null
		_cache_valid = false
		return
	
	var new_target = memory_manager.get_current_memory_target()
	
	# Se o alvo mudou, emite signal
	if new_target != _current_target_cache:
		_current_target_cache = new_target
		current_target_changed.emit(new_target)
	
	_cache_valid = true

func _invalidate_cache():
	_cache_valid = false

func _on_memory_collected(_memory_index: int):
	# Invalida cache quando uma memória é coletada
	_invalidate_cache()
	
	# Emite signal de coleta se necessário
	var collected_memory = _current_target_cache
	if collected_memory:
		memory_collected.emit(collected_memory)

## Método de debug para verificar estado interno
func debug_info() -> Dictionary:
	return {
		"memory_manager_found": memory_manager != null,
		"player_found": player != null,
		"cache_valid": _cache_valid,
		"current_target": _current_target_cache.memory_title if _current_target_cache else "none",
		"memories_remaining": has_memories_remaining()
	}
