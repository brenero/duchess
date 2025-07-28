extends Node

# Array de NodePaths que define a ordem das memórias na fase
@export var ordered_memories: Array[NodePath]

# Índice da memória atual que deve ser encontrada
var current_memory_index: int = 0

# Signal emitido quando uma memória é coletada
signal memory_collected(memory_index: int)

# Signal emitido quando todas as memórias foram coletadas
signal all_memories_collected()

func _ready():
	# Adiciona este nó ao grupo para fácil acesso
	add_to_group("memory_manager")

# Retorna o nó da memória atual que deve ser encontrada
func get_current_memory_target() -> Node2D:
	if current_memory_index >= ordered_memories.size():
		return null
	
	var memory_path = ordered_memories[current_memory_index]
	var memory_node = get_node(memory_path)
	
	if memory_node and is_instance_valid(memory_node):
		return memory_node
	else:
		# Se a memória não existe, tenta avançar para a próxima
		advance_to_next_memory()
		return get_current_memory_target()

# Avança para a próxima memória na ordem
func advance_to_next_memory():
	memory_collected.emit(current_memory_index)
	current_memory_index += 1
	
	if current_memory_index >= ordered_memories.size():
		all_memories_collected.emit()
		print("Todas as memórias foram coletadas!")

# Retorna se ainda há memórias para coletar
func has_memories_remaining() -> bool:
	return current_memory_index < ordered_memories.size()

# Retorna o progresso atual (quantas memórias foram coletadas)
func get_progress() -> Dictionary:
	return {
		"collected": current_memory_index,
		"total": ordered_memories.size(),
		"percentage": float(current_memory_index) / float(ordered_memories.size()) * 100.0
	}

# Reseta o progresso das memórias (útil para restart)
func reset_progress():
	current_memory_index = 0
