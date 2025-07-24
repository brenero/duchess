# idlestate.gd (versão final)
extends "res://scripts/state.gd"

## Configurações do Estado Idle (editáveis no Inspector)
@export_group("Idle Settings")
@export var instant_run_transition: bool = true  ## Se transição para Run é instantânea ou com delay
@export var attacks_from_idle: bool = true  ## Se permite ataques diretamente do Idle

# Chamado uma vez quando entramos no estado Idle.
func enter():
	character.get_node("AnimatedSprite2D").play("idle")
	character.velocity.x = 0

# Roda a cada frame de física.
func process_physics(delta: float) -> State:
	# Aplica a gravidade se o personagem não estiver no chão.
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
		# Se sairmos do chão (caindo), devemos ir para o estado 'Air'.
		return state_machine.get_node("Air")
	
	# Verifica se o jogador começou a se mover para transicionar para Run.
	if instant_run_transition and Input.get_axis("move_left", "move_right") != 0:
		return state_machine.get_node("Run")
		
	# Verifica se o jogador pulou para transicionar para Air.
	if Input.is_action_just_pressed("jump"):
		return state_machine.get_node("Air")
	
	# Verifica ataques se habilitado
	if attacks_from_idle:
		# Verifica se o jogador apertou bark para transicionar para Bark.
		if Input.is_action_just_pressed("bark"):
			return state_machine.get_node("Bark")
		
		# Verifica se o jogador apertou bite para transicionar para Bite.
		if Input.is_action_just_pressed("bite"):
			return state_machine.get_node("Bite")
		
	# Se nada acontecer, continua no estado Idle.
	return null
