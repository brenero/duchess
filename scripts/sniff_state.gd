# sniff_state.gd - Estado para quando a Duquesa está farejando
extends "res://scripts/state.gd"

## Configurações do Estado Sniff (editáveis no Inspector)
@export_group("Sniff Settings")
@export var sniff_duration: float = 1.2  ## Duração do farejar em segundos
@export var jump_cancel_threshold: float = 0.8  ## Em que % da duração permite cancelar com pulo (0.8 = 80%)
@export var bite_interrupt_enabled: bool = true  ## Se permite interromper sniff com bite
@export var bark_interrupt_enabled: bool = true  ## Se permite interromper sniff com bark

@export_group("Memory Hint Settings")
@export var discovery_distance: float = 48.0  ## Distância para mostrar exclamação
@export var hint_update_rate: float = 0.1  ## Taxa de atualização das dicas em segundos

var sniff_timer: float = 0.0
var hint_timer: float = 0.0
var memory_manager: Node
var hint_balloon: Node2D

# Chamado uma vez quando entramos no estado Sniff
func enter():
	# Para o movimento horizontal
	character.velocity.x = 0
	
	# Toca a animação de farejar
	character.get_node("AnimatedSprite2D").play("sniff")
	
	# Reinicia os timers
	sniff_timer = 0.0
	hint_timer = 0.0
	
	# Inicializa referências (se ainda não foram feitas)
	if not memory_manager:
		memory_manager = get_tree().get_first_node_in_group("memory_manager")
		if memory_manager:
			print("MemoryManager encontrado: ", memory_manager.name)
		else:
			print("MemoryManager não encontrado! Certifique-se de que há um nó com script memory_manager.gd no grupo 'memory_manager'")
	
	if not hint_balloon:
		hint_balloon = character.get_node("HintBalloon")
	
	# Atualiza as dicas imediatamente
	update_memory_hints()

# Roda a cada frame de física enquanto estivermos farejando
func process_physics(delta: float) -> State:
	# 1. APLICAR FÍSICA BÁSICA
	# ------------------------
	# Aplica gravidade se não estiver no chão
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
		# Se sairmos do chão durante o farejar, vamos para Air
		return state_machine.get_node("Air")
	
	# Mantém parado horizontalmente durante o farejar
	character.velocity.x = 0
	
	# 2. ATUALIZAR DICAS DE MEMÓRIA
	# -----------------------------
	hint_timer += delta
	if hint_timer >= hint_update_rate:
		update_memory_hints()
		hint_timer = 0.0
	
	# 3. GERENCIAR DURAÇÃO DO FAREJAR
	# -------------------------------
	sniff_timer += delta
	
	# Se o farejar terminou, decidir qual estado ir
	if sniff_timer >= sniff_duration:
		# Verifica se há input de movimento para ir para Run
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0:
			return state_machine.get_node("Run")
		# Senão volta para Idle
		else:
			return state_machine.get_node("Idle")
	
	# 3. AÇÕES PERMITIDAS DURANTE FAREJAR
	# -----------------------------------
	# Permite fazer bite durante sniff (se habilitado)
	if bite_interrupt_enabled and Input.is_action_just_pressed("bite"):
		return state_machine.get_node("Bite")
	
	# Permite fazer bark durante sniff (se habilitado)
	if bark_interrupt_enabled and Input.is_action_just_pressed("bark"):
		return state_machine.get_node("Bark")
	
	# Permite pular no final do farejar (conforme threshold configurado)
	if sniff_timer >= sniff_duration * jump_cancel_threshold and Input.is_action_just_pressed("jump"):
		return state_machine.get_node("Air")
	
	# Continua no estado Sniff
	return null

# Chamado quando saímos do estado Sniff
func exit():
	# Esconde o balão de dicas
	if hint_balloon:
		hint_balloon.hide_hint()

# Atualiza as dicas de direção para as memórias
func update_memory_hints():
	if not memory_manager or not hint_balloon:
		return
	
	# Verifica se o memory_manager tem o método necessário
	if not memory_manager.has_method("get_current_memory_target"):
		print("MemoryManager não tem o método get_current_memory_target")
		return
	
	# Pega a próxima memória alvo
	var target_memory = memory_manager.get_current_memory_target()
	
	if not target_memory:
		# Se não há mais memórias, esconde as dicas
		hint_balloon.hide_hint()
		return
	
	# Calcula a distância até a memória alvo
	var distance = character.global_position.distance_to(target_memory.global_position)
	
	# Se está muito próximo, mostra exclamação
	if distance <= discovery_distance:
		hint_balloon.show_hint(hint_balloon.HintType.EXCLAMATION)
		return
	
	# Determina a direção horizontal
	var direction_x = target_memory.global_position.x - character.global_position.x
	
	if direction_x > 0:
		# Memória está à direita
		hint_balloon.show_hint(hint_balloon.HintType.ARROW_RIGHT)
	else:
		# Memória está à esquerda
		hint_balloon.show_hint(hint_balloon.HintType.ARROW_LEFT)
