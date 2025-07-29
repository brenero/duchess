# dig_state.gd - Estado para quando a Duquesa está cavando
extends "res://scripts/states/state.gd"

## Configurações do Estado Dig (editáveis no Inspector)
@export_group("Dig Settings")
@export var dig_duration: float = 1.5  ## Duração do cavar em segundos
@export var dig_loops: int = 2  ## Quantas vezes repete a animação
@export var movement_allowed: bool = false  ## Se permite movimento durante dig
@export var cancel_threshold: float = 0.3  ## Em que % permite cancelar (0.3 = 30%)

@export_group("Memory Collection Settings")
@export var collection_distance: float = 48.0  ## Distância máxima para coletar memórias

var dig_timer: float = 0.0
var loops_completed: int = 0

# Controller para descoberta de memórias
var memory_discovery_controller: MemoryDiscoveryController

# Chamado quando o estado é inicializado
func init(character_ref, state_machine_ref):
	super.init(character_ref, state_machine_ref)
	
	# Esconde a animação de smoke no início
	if has_node("AnimatedSprite2D"):
		var smoke_sprite = get_node("AnimatedSprite2D")
		smoke_sprite.visible = false

# Chamado uma vez quando entramos no estado Dig
func enter():
	# Para o movimento horizontal
	character.velocity.x = 0
	
	# Inicializa memory controller se necessário
	_initialize_memory_controller()
	
	# Sempre executa a animação de dig primeiro
	print("Cavando...")
	
	# Toca a animação de cavar
	character.get_node("AnimatedSprite2D").play("dig")
	
	# Inicia a animação de smoke
	start_smoke_animation()
	
	# Reinicia o timer e contadores
	dig_timer = 0.0
	loops_completed = 0

# Roda a cada frame de física enquanto estivermos cavando
func process_physics(delta: float) -> State:
	# 1. APLICAR FÍSICA BÁSICA
	# ------------------------
	# Aplica gravidade se não estiver no chão
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
		# Se sairmos do chão durante o cavar, vamos para Air
		return state_machine.get_node("Air")
	
	# Controla movimento horizontal
	if movement_allowed:
		# Permite movimento lento durante dig
		var direction = Input.get_axis("move_left", "move_right")
		character.velocity.x = direction * character.speed * 0.3  # Movimento reduzido
		
		# Atualiza direção do sprite
		if direction > 0:
			character.get_node("AnimatedSprite2D").flip_h = false
			update_smoke_offset()  # Atualiza offset do smoke quando muda direção
		elif direction < 0:
			character.get_node("AnimatedSprite2D").flip_h = true
			update_smoke_offset()  # Atualiza offset do smoke quando muda direção
	else:
		# Mantém parado durante dig
		character.velocity.x = 0
	
	# 2. ATUALIZAR POSIÇÃO DO SMOKE
	# ------------------------------
	# Atualiza a posição do smoke a cada frame para seguir o cachorro
	update_smoke_offset()
	
	# 3. GERENCIAR DURAÇÃO DO CAVAR
	# -----------------------------
	dig_timer += delta
	
	# Verifica se completou um loop da animação
	var loop_duration = dig_duration / dig_loops
	if dig_timer >= loop_duration * (loops_completed + 1):
		loops_completed += 1
		
		# Se completou todos os loops, termina
		if loops_completed >= dig_loops:
			# NOVA MECÂNICA: Tenta coletar memória APÓS completar animação
			var collected_memory: Memoria = null
			if memory_discovery_controller:
				collected_memory = memory_discovery_controller.attempt_dig_collection(character.global_position)
			
			if collected_memory:
				print("Memória coletada! Exibindo interface...")
				_display_collected_memory(collected_memory)
			else:
				print("Nenhuma memória encontrada neste local.")
			
			# Verifica se há input de movimento para ir para Run
			var direction = Input.get_axis("move_left", "move_right")
			if direction != 0:
				return state_machine.get_node("Run")
			# Senão volta para Idle
			else:
				return state_machine.get_node("Idle")
	
	# 4. PERMITIR CANCELAMENTO PRECOCE
	# ---------------------------------
	# Permite cancelar com movimento após o threshold
	if dig_timer >= dig_duration * cancel_threshold:
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0:
			return state_machine.get_node("Run")
		
		# Permite cancelar com pulo
		if Input.is_action_just_pressed("jump"):
			return state_machine.get_node("Air")
		
		# Permite cancelar com outros ataques
		if Input.is_action_just_pressed("bark"):
			return state_machine.get_node("Bark")
		
		if Input.is_action_just_pressed("bite"):
			return state_machine.get_node("Bite")
		
		if Input.is_action_just_pressed("sniff"):
			return state_machine.get_node("Sniff")
	
	# Continua no estado Dig
	return null

# Inicia a animação de smoke com múltiplas rajadas
func start_smoke_animation():
	# Esconde o smoke principal (não vamos usar mais)
	if has_node("AnimatedSprite2D"):
		var smoke_sprite = get_node("AnimatedSprite2D")
		smoke_sprite.visible = false
		
	# Cria apenas rajadas atrás da pata
	create_additional_smoke_bursts()

# Atualiza a posição do smoke baseado na direção do sprite do cachorro
func update_smoke_offset():
	# Apenas atualiza posições das rajadas (não há mais smoke principal)
	update_additional_smoke_positions()

# Cria rajadas de smoke adicionais atrás da pata
func create_additional_smoke_bursts():
	# Remove rajadas anteriores se existirem
	clean_additional_smoke_bursts()
	
	# Cria três rajadas atrás da pata
	for i in range(3):
		var additional_smoke = AnimatedSprite2D.new()
		additional_smoke.name = "AdditionalSmoke" + str(i)
		
		# Copia as configurações do smoke principal
		if has_node("AnimatedSprite2D"):
			var main_smoke = get_node("AnimatedSprite2D")
			additional_smoke.sprite_frames = main_smoke.sprite_frames
			additional_smoke.animation = "smoke"
			additional_smoke.self_modulate = main_smoke.self_modulate
			additional_smoke.texture_filter = main_smoke.texture_filter
			
		# Adiciona ao nó do estado
		add_child(additional_smoke)
		additional_smoke.play("smoke")
		
		# Adiciona delay progressivo para criar efeito sequencial
		var delay = (i + 1) * 0.1  # 0.1s, 0.2s e 0.3s de delay
		additional_smoke.frame_progress = delay
		
		# Escala gradativa: primeira normal, segunda e terceira maiores
		var scale_factor = 1.0 + (i * 0.3)  # 1.0, 1.3, 1.6
		additional_smoke.scale = Vector2(scale_factor, scale_factor)
		
		# Remove offset - vamos usar posicionamento manual
		additional_smoke.offset = Vector2(0, 0)
		
		# Define z_index para ficar na frente do personagem
		additional_smoke.z_index = 2

# Atualiza posições das rajadas adicionais
func update_additional_smoke_positions():
	var main_sprite = character.get_node("AnimatedSprite2D")
	var main_sprite_global_pos = main_sprite.global_position
	
	# Configurações de posição
	var paw_offset_y = 18
	var back_spacing = 15  # Espaçamento maior entre as rajadas atrás
	
	# Posição Y fixa para todas as rajadas (alinhadas no chão)
	# Agora sem offset, volta ao cálculo normal
	var fixed_ground_y = main_sprite_global_pos.y + paw_offset_y
	
	for i in range(3):
		var smoke_node = get_node_or_null("AdditionalSmoke" + str(i))
		if smoke_node:
			# Calcula posição atrás da pata baseado na direção
			var back_offset_x
			if main_sprite.flip_h:
				# Olhando esquerda - rajadas vão para a direita (atrás)
				# Primeira rajada mais próxima da pata dianteira (8px para frente = -8px)
				back_offset_x = 0 + (i * back_spacing)  # +0, +15, +30
				# Sprites de trás flipam para simular terra sendo jogada para trás
				smoke_node.flip_h = true
			else:
				# Olhando direita - rajadas vão para a esquerda (atrás)  
				# Primeira rajada mais próxima da pata dianteira (8px para frente = +8px)
				back_offset_x = 0 - (i * back_spacing)  # -0, -15, -30
				# Sprites de trás não flipam quando olhando direita
				smoke_node.flip_h = false
			
			# Para compensar a escala e manter base alinhada, ajusta Y manualmente
			var scale_factor = 1.0 + (i * 0.4)  # 1.0, 1.4, 1.8
			var sprite_height = 64  # Altura assumida do sprite
			var scale_y_compensation = (scale_factor - 1.0) * (sprite_height / 2.0)  # Metade da altura extra
			
			# Todas as rajadas na mesma altura Y (base), apenas X varia
			smoke_node.global_position = Vector2(main_sprite_global_pos.x + back_offset_x, fixed_ground_y - scale_y_compensation)

# Remove rajadas adicionais
func clean_additional_smoke_bursts():
	for i in range(3):
		var smoke_node = get_node_or_null("AdditionalSmoke" + str(i))
		if smoke_node:
			smoke_node.queue_free()

# Chamado quando saímos do estado Dig
func exit():
	# Para a animação de smoke e esconde
	if has_node("AnimatedSprite2D"):
		var smoke_sprite = get_node("AnimatedSprite2D")
		smoke_sprite.stop()
		smoke_sprite.visible = false
	
	# Remove rajadas adicionais
	clean_additional_smoke_bursts()


# === MÉTODOS PRIVADOS PARA MEMÓRIAS ===

# Inicializa o memory discovery controller
func _initialize_memory_controller():
	if memory_discovery_controller:
		return  # Já inicializado
	
	# Tenta encontrar controller existente
	memory_discovery_controller = get_tree().get_first_node_in_group("memory_discovery_controller")
	
	if not memory_discovery_controller:
		# Cria um novo controller se não existir
		memory_discovery_controller = MemoryDiscoveryController.new()
		memory_discovery_controller.name = "MemoryDiscoveryController"
		
		# Adiciona à árvore principal
		get_tree().current_scene.add_child(memory_discovery_controller)
		memory_discovery_controller.add_to_group("memory_discovery_controller")
		
		print("DigState: MemoryDiscoveryController criado automaticamente")

# Exibe a interface da memória coletada
func _display_collected_memory(memory: Memoria):
	if not memory:
		return
	
	# Procura o controller de exibição de memórias
	var memory_display_controller = get_tree().get_first_node_in_group("memory_display_controller")
	
	if not memory_display_controller:
		# Cria o controller se não existir
		memory_display_controller = preload("res://scripts/controllers/memory_display_controller.gd").new()
		memory_display_controller.name = "MemoryDisplayController"
		get_tree().current_scene.add_child(memory_display_controller)
		print("DigState: MemoryDisplayController criado automaticamente")
	
	# Exibe a memória através do controller
	memory_display_controller.display_memory(memory)
