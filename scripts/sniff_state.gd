# sniff_state.gd - Estado para quando a Duquesa está farejando
# REFATORADO: Agora usa controllers para separação de responsabilidades
extends "res://scripts/state.gd"

## Configurações do Estado Sniff (editáveis no Inspector)
@export_group("Sniff Settings")
@export var sniff_duration: float = 1.2  ## Duração do farejar em segundos
@export var jump_cancel_threshold: float = 0.8  ## Em que % da duração permite cancelar com pulo (0.8 = 80%)
@export var bite_interrupt_enabled: bool = true  ## Se permite interromper sniff com bite
@export var bark_interrupt_enabled: bool = true  ## Se permite interromper sniff com bark

# Estado interno do sniff
var sniff_timer: float = 0.0

# Controllers (injetados via dependency injection ou encontrados automaticamente)
var hint_system_controller: HintSystemController

# Chamado uma vez quando entramos no estado Sniff
func enter():
	# Para o movimento horizontal
	character.velocity.x = 0
	
	# Toca a animação de farejar
	character.get_node("AnimatedSprite2D").play("sniff")
	
	# Reinicia o timer
	sniff_timer = 0.0
	
	# Inicializa controller se necessário
	_initialize_hint_controller()
	
	# Ativa o sistema de hints
	if hint_system_controller:
		hint_system_controller.activate_hints()

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
	# Desativa o sistema de hints
	if hint_system_controller:
		hint_system_controller.deactivate_hints()

# === MÉTODOS PRIVADOS ===

# Inicializa o hint controller (dependency injection ou service locator)
func _initialize_hint_controller():
	if hint_system_controller:
		return  # Já inicializado
	
	# Tenta encontrar controller existente
	hint_system_controller = get_tree().get_first_node_in_group("hint_system_controller")
	
	if not hint_system_controller:
		# Cria um novo controller se não existir
		_create_hint_controller()

func _create_hint_controller():
	# Cria e configura o controller
	hint_system_controller = HintSystemController.new()
	hint_system_controller.name = "HintSystemController"
	
	# Adiciona à árvore (como child do character para organização)
	character.add_child(hint_system_controller)
	hint_system_controller.add_to_group("hint_system_controller")
	
	print("SniffState: HintSystemController criado automaticamente")

# Método para injetar dependências (útil para testes ou configuração manual)
func set_hint_controller(controller: HintSystemController):
	hint_system_controller = controller
