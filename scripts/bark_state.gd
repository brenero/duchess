# bark_state.gd - Estado para quando a Duquesa está latindo
extends "res://scripts/state.gd"

## Configurações do Estado Bark (editáveis no Inspector)
@export_group("Bark Settings")
@export var bark_duration: float = 1.0  ## Duração do latido em segundos
@export var jump_cancel_threshold: float = 0.8  ## Em que % da duração permite cancelar com pulo (0.8 = 80%)
@export var bite_interrupt_enabled: bool = true  ## Se permite interromper bark com bite

var bark_timer: float = 0.0

# Chamado uma vez quando entramos no estado Bark
func enter():
	# Para o movimento horizontal
	character.velocity.x = 0
	
	# Toca a animação de latido
	character.get_node("AnimatedSprite2D").play("bark")
	
	# Reinicia o timer
	bark_timer = 0.0
	
	# Toca o som de latido se houver
	# character.get_node("BarkSound").play()

# Roda a cada frame de física enquanto estivermos latindo
func process_physics(delta: float) -> State:
	# 1. APLICAR FÍSICA BÁSICA
	# ------------------------
	# Aplica gravidade se não estiver no chão
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
		# Se sairmos do chão durante o latido, vamos para Air
		return state_machine.get_node("Air")
	
	# Mantém parado horizontalmente durante o latido
	character.velocity.x = 0
	
	# 2. GERENCIAR DURAÇÃO DO LATIDO
	# ------------------------------
	bark_timer += delta
	
	# Se o latido terminou, decidir qual estado ir
	if bark_timer >= bark_duration:
		# Verifica se há input de movimento para ir para Run
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0:
			return state_machine.get_node("Run")
		# Senão volta para Idle
		else:
			return state_machine.get_node("Idle")
	
	# 3. AÇÕES PERMITIDAS DURANTE LATIDO
	# ----------------------------------
	# Permite fazer bite durante bark (se habilitado)
	if bite_interrupt_enabled and Input.is_action_just_pressed("bite"):
		return state_machine.get_node("Bite")
	
	# Permite pular no final do latido (conforme threshold configurado)
	if bark_timer >= bark_duration * jump_cancel_threshold and Input.is_action_just_pressed("jump"):
		return state_machine.get_node("Air")
	
	# Continua no estado Bark
	return null

# Chamado quando saímos do estado Bark
func exit():
	# Para o som se estiver tocando
	# if character.get_node("BarkSound").is_playing():
	#     character.get_node("BarkSound").stop()
	pass
