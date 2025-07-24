# run_state.gd - Lógica para quando a Duquesa está correndo.
extends "res://scripts/state.gd"

## Configurações do Estado Run (editáveis no Inspector)
@export_group("Run Settings")
@export var attacks_while_running: bool = true  ## Se permite ataques enquanto corre
@export var stop_on_zero_input: bool = true  ## Se para imediatamente quando não há input

# Chamado uma vez, no momento exato em que entramos no estado de corrida.
func enter():
	# A primeira coisa a fazer é tocar a animação de corrida.
	character.get_node("AnimatedSprite2D").play("run")


# Roda a cada frame de física enquanto estivermos neste estado.
func process_physics(delta: float) -> State:
	# 1. APLICAR FÍSICA E INPUT
	# --------------------------
	# Mesmo correndo, a gravidade precisa ser aplicada caso ela saia de uma plataforma.
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
		
	# Pega a direção do input do jogador (esquerda/direita).
	var direction = Input.get_axis("move_left", "move_right")
	
	# Aplica a velocidade horizontal para mover o personagem.
	character.velocity.x = direction * character.speed
	
	
	# 2. ATUALIZAR VISUAIS
	# --------------------
	# Vira o sprite para a direção em que estamos nos movendo.
	if direction > 0:
		character.get_node("AnimatedSprite2D").flip_h = false
	elif direction < 0:
		character.get_node("AnimatedSprite2D").flip_h = true
		
	
	# 3. VERIFICAR POR TRANSIÇÕES PARA OUTROS ESTADOS
	# -----------------------------------------------
	# Se sairmos do chão (pulando ou caindo), devemos ir para o estado 'Air'.
	if not character.is_on_floor():
		return state_machine.get_node("Air")
		
	# Se o jogador parar de se mover, devemos voltar para o estado 'Idle'.
	if stop_on_zero_input and direction == 0:
		return state_machine.get_node("Idle")
		
	# Se o jogador apertar o pulo, vamos para o estado 'Air'.
	if Input.is_action_just_pressed("jump"):
		return state_machine.get_node("Air")
	
	# Se o jogador apertar sniff, vamos para o estado 'Sniff'.
	if Input.is_action_just_pressed("sniff"):
		return state_machine.get_node("Sniff")
	
	# Se o jogador apertar dig, vamos para o estado 'Dig'.
	if Input.is_action_just_pressed("dig"):
		return state_machine.get_node("Dig")
	
	# Permite ataques durante corrida se habilitado
	if attacks_while_running:
		# Se o jogador apertar bark, vamos para o estado 'Bark'.
		if Input.is_action_just_pressed("bark"):
			return state_machine.get_node("Bark")
		
		# Se o jogador apertar bite, vamos para o estado 'Bite'.
		if Input.is_action_just_pressed("bite"):
			return state_machine.get_node("Bite")

	# Se nenhuma das condições acima for atendida, continuamos no estado 'Run'.
	return null


# Chamado uma vez, no momento exato em que saímos do estado de corrida.
func exit():
	# É uma boa prática zerar a velocidade horizontal ao parar de correr.
	# Isso evita que a personagem "deslize" um pouco ao entrar no estado Idle.
	character.velocity.x = 0
