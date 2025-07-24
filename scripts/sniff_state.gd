# sniff_state.gd - Estado para quando a Duquesa está farejando
extends "res://scripts/state.gd"

## Configurações do Estado Sniff (editáveis no Inspector)
@export_group("Sniff Settings")
@export var sniff_duration: float = 1.2  ## Duração do farejar em segundos
@export var jump_cancel_threshold: float = 0.8  ## Em que % da duração permite cancelar com pulo (0.8 = 80%)
@export var bite_interrupt_enabled: bool = true  ## Se permite interromper sniff com bite
@export var bark_interrupt_enabled: bool = true  ## Se permite interromper sniff com bark

var sniff_timer: float = 0.0

# Chamado uma vez quando entramos no estado Sniff
func enter():
	# Para o movimento horizontal
	character.velocity.x = 0
	
	# Toca a animação de farejar
	character.get_node("AnimatedSprite2D").play("sniff")
	
	# Reinicia o timer
	sniff_timer = 0.0

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
	
	# 2. GERENCIAR DURAÇÃO DO FAREJAR
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
	# Limpa qualquer configuração específica do sniff se necessário
	pass
