# idlestate.gd (versão final)
extends "res://scripts/state.gd"

## Configurações do Estado Idle (editáveis no Inspector)
@export_group("Idle Settings")
@export var instant_run_transition: bool = true  ## Se transição para Run é instantânea ou com delay
@export var attacks_from_idle: bool = true  ## Se permite ataques diretamente do Idle

@export_group("Idle Animations")
@export var sit_delay: float = 3.0  ## Tempo em segundos para começar a sentar
@export var lie_delay: float = 10.0  ## Tempo em segundos para começar a deitar
@export var sleep_delay: float = 15.0  ## Tempo em segundos para começar a dormir

var idle_timer: float = 0.0
var current_idle_state: String = "idle"  # "idle", "sit", "lie", "sleep"

# Chamado uma vez quando entramos no estado Idle.
func enter():
	character.get_node("AnimatedSprite2D").play("idle")
	character.velocity.x = 0
	# Reinicia o timer e estado idle
	idle_timer = 0.0
	current_idle_state = "idle"

# Roda a cada frame de física.
func process_physics(delta: float) -> State:
	# Aplica a gravidade se o personagem não estiver no chão.
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
		# Se sairmos do chão (caindo), devemos ir para o estado 'Air'.
		return state_machine.get_node("Air")
	
	# Qualquer input interrompe as animações idle e volta para o estado normal
	var has_input = (Input.get_axis("move_left", "move_right") != 0 or 
					 Input.is_action_just_pressed("jump") or
					 (attacks_from_idle and (Input.is_action_just_pressed("bark") or Input.is_action_just_pressed("bite"))))
	
	if has_input:
		# Reset idle timer e animação se houve input
		if current_idle_state != "idle":
			idle_timer = 0.0
			current_idle_state = "idle"
			character.get_node("AnimatedSprite2D").play("idle")
	else:
		# Incrementa timer apenas se não há input
		idle_timer += delta
		
		# Gerencia transições de animação idle
		update_idle_animation()
	
	# Verifica transições normais apenas se há input
	if has_input:
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

# Função para gerenciar as transições de animação idle
func update_idle_animation():
	if current_idle_state == "idle" and idle_timer >= sit_delay:
		# Transição para sit
		current_idle_state = "sit"
		character.get_node("AnimatedSprite2D").play("sit")
	elif current_idle_state == "sit" and idle_timer >= lie_delay:
		# Transição para lie (deitar)
		current_idle_state = "lie"
		character.get_node("AnimatedSprite2D").play("lie")
	elif current_idle_state == "lie" and idle_timer >= sleep_delay:
		# Transição para sleep
		current_idle_state = "sleep"
		character.get_node("AnimatedSprite2D").play("sleep")
