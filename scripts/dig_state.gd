# dig_state.gd - Estado para quando a Duquesa está cavando
extends "res://scripts/state.gd"

## Configurações do Estado Dig (editáveis no Inspector)
@export_group("Dig Settings")
@export var dig_duration: float = 1.5  ## Duração do cavar em segundos
@export var dig_loops: int = 2  ## Quantas vezes repete a animação
@export var movement_allowed: bool = false  ## Se permite movimento durante dig
@export var cancel_threshold: float = 0.3  ## Em que % permite cancelar (0.3 = 30%)

@export_group("Particle Settings")
@export var particles_enabled: bool = true  ## Se ativa partículas de poeira
@export var particles_per_loop: int = 3  ## Quantas rajadas de partículas por loop
@export var particle_delay: float = 0.3  ## Delay mínimo entre rajadas de partículas
@export var burst_duration: float = 0.1  ## Duração de cada rajada em segundos

var dig_timer: float = 0.0
var loops_completed: int = 0
var particles_spawned: int = 0  # Contador de partículas já criadas
var last_particle_time: float = 0.0  # Tempo da última partícula

# Chamado uma vez quando entramos no estado Dig
func enter():
	# Para o movimento horizontal
	character.velocity.x = 0
	
	# Toca a animação de cavar
	character.get_node("AnimatedSprite2D").play("dig")
	
	# Para as partículas inicialmente
	if character.has_node("DustParticles"):
		var particles = character.get_node("DustParticles")
		particles.emitting = false
	
	# Reinicia o timer e contadores
	dig_timer = 0.0
	loops_completed = 0
	particles_spawned = 0
	last_particle_time = 0.0

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
		elif direction < 0:
			character.get_node("AnimatedSprite2D").flip_h = true
	else:
		# Mantém parado durante dig
		character.velocity.x = 0
	
	# 2. GERENCIAR PARTÍCULAS DE POEIRA
	# ---------------------------------
	if particles_enabled:
		manage_particles(delta)
	
	# 3. GERENCIAR DURAÇÃO DO CAVAR
	# -----------------------------
	dig_timer += delta
	
	# Verifica se completou um loop da animação
	var loop_duration = dig_duration / dig_loops
	if dig_timer >= loop_duration * (loops_completed + 1):
		loops_completed += 1
		
		# Se completou todos os loops, termina
		if loops_completed >= dig_loops:
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

# Gerencia a criação de partículas durante o dig
func manage_particles(delta: float):
	# Calcula quantas partículas devemos ter criado até agora
	var total_particles_expected = dig_loops * particles_per_loop
	var particles_per_second = total_particles_expected / dig_duration
	var expected_particles = int(dig_timer * particles_per_second)
	
	# Se devemos criar uma nova partícula e passou tempo suficiente desde a última
	if expected_particles > particles_spawned and dig_timer - last_particle_time >= particle_delay:
		spawn_dust_particles()
		particles_spawned += 1
		last_particle_time = dig_timer

# Cria partículas de poeira em rajadas controladas
func spawn_dust_particles():
	if character.has_node("DustParticles"):
		var particles = character.get_node("DustParticles")
		
		# Para GPUParticles2D - ativa emissão por um tempo curto
		if particles.has_method("restart"):
			particles.amount = 20  # Quantidade de partículas por rajada
			particles.emitting = true
			# Cria um timer para parar a emissão após burst_duration
			get_tree().create_timer(burst_duration).timeout.connect(_stop_particles)
		
		# Debug: print para verificar se está funcionando
		print("Dust particles burst at dig time: ", dig_timer)

# Para a emissão de partículas após uma rajada
func _stop_particles():
	if character.has_node("DustParticles"):
		var particles = character.get_node("DustParticles")
		particles.emitting = false

# Chamado quando saímos do estado Dig
func exit():
	# Para as partículas se estiverem rodando
	if character.has_node("DustParticles"):
		var particles = character.get_node("DustParticles")
		if particles.has_method("emitting"):
			particles.emitting = false
