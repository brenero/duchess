# air_state.gd - Estado para quando a Duquesa está no ar (pulando ou caindo)
extends "res://scripts/state.gd"

## Configurações do Estado Air (editáveis no Inspector)
@export_group("Air Control Settings")
@export_range(0.0, 1.0) var air_control: float = 1.0  ## Controle horizontal no ar (1.0 = controle total, 0.5 = reduzido)
@export var aerial_attacks_enabled: bool = true  ## Se permite ataques no ar
@export var coyote_time: float = 0.1  ## Tempo em segundos para pular após sair do chão

# Chamado uma vez quando entramos no estado Air
func enter():
	# Se chegamos aqui por um pulo, aplicamos a velocidade de pulo
	if character.is_on_floor():
		character.velocity.y = character.jump_velocity
	
	# Toca a animação apropriada dependendo da velocidade vertical
	if character.velocity.y < 0:
		character.get_node("AnimatedSprite2D").play("run")  # Usando run como placeholder
	else:
		character.get_node("AnimatedSprite2D").play("run")  # Usando run como placeholder

# Roda a cada frame de física enquanto estivermos no ar
func process_physics(delta: float) -> State:
	# 1. APLICAR FÍSICA
	# -----------------
	# Sempre aplicar gravidade quando no ar
	character.velocity.y += character.gravity * delta
	
	# Pegar input horizontal para movimento no ar
	var direction = Input.get_axis("move_left", "move_right")
	
	# Permitir movimento horizontal no ar (com controle configurável)
	character.velocity.x = direction * character.speed * air_control
	
	# 2. ATUALIZAR VISUAIS
	# --------------------
	# Virar sprite conforme direção horizontal
	if direction > 0:
		character.get_node("AnimatedSprite2D").flip_h = false
	elif direction < 0:
		character.get_node("AnimatedSprite2D").flip_h = true
	
	# 3. VERIFICAR TRANSIÇÕES
	# -----------------------
	# Permite ataques no ar se habilitado
	if aerial_attacks_enabled:
		# Permite bark no ar (ataque aéreo)
		if Input.is_action_just_pressed("bark"):
			return state_machine.get_node("Bark")
		
		# Permite bite no ar (ataque aéreo)
		if Input.is_action_just_pressed("bite"):
			return state_machine.get_node("Bite")
	
	# Se tocamos o chão, decidir para qual estado ir
	if character.is_on_floor():
		# Se estamos nos movendo horizontalmente, ir para Run
		if direction != 0:
			return state_machine.get_node("Run")
		# Senão, ir para Idle
		else:
			return state_machine.get_node("Idle")
	
	# Se ainda estamos no ar, continuar neste estado
	return null

# Chamado quando saímos do estado Air
func exit():
	pass
