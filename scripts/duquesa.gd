# duquesa.gd - Agora com arquitetura baseada em componentes!
extends CharacterBody2D

@export var speed = 250.0
@export var gravity = 800.0
@export var jump_velocity = -400.0

@onready var state_machine = $StateMachine
@onready var sprite = $AnimatedSprite2D

# Componentes para movimento avançado
var slope_detector: SlopeDetector
var step_up_assistant: StepUpAssistant

# Referências dos raycasts
@onready var slope_raycast_left = $SlopeRaycastLeft
@onready var slope_raycast_right = $SlopeRaycastRight
@onready var wall_raycast = $WallRaycast
@onready var step_raycast = $StepRaycast

# A lógica de input, animação e estado agora está nos estados individuais.
# O script principal só precisa aplicar o movimento final.
func _physics_process(delta):
	if state_machine and state_machine.current_state:
		var new_state = state_machine.current_state.process_physics(delta)
		if new_state:
			state_machine.transition_to(new_state)
	
	# Usar componente para assistência de step-up
	if step_up_assistant:
		step_up_assistant.attempt_step_up(delta)
	
	move_and_slide()
	
	# Usar componente para rotação de slope
	if slope_detector:
		slope_detector.update_rotation(delta)

func _ready():
	# Garante que as partículas comecem desabilitadas
	if has_node("DustParticles"):
		var particles = get_node("DustParticles")
		particles.emitting = false
	
	# Inicializar componentes
	setup_components()

func setup_components():
	"""Inicializa os componentes de movimento avançado"""
	# Criar e configurar componente de detecção de slope
	slope_detector = SlopeDetector.new()
	add_child(slope_detector)
	slope_detector.initialize(self, sprite, slope_raycast_left, slope_raycast_right)
	
	# Criar e configurar componente de assistência step-up
	step_up_assistant = StepUpAssistant.new()
	add_child(step_up_assistant)
	step_up_assistant.initialize(self, wall_raycast, step_raycast)

# Métodos de conveniência para acessar funcionalidades dos componentes
func get_current_slope_angle() -> float:
	"""Retorna o ângulo atual do slope"""
	return slope_detector.get_current_angle() if slope_detector else 0.0

func reset_slope_rotation():
	"""Reseta a rotação do sprite"""
	if slope_detector:
		slope_detector.reset_rotation()

func set_step_up_enabled(enabled: bool):
	"""Habilita/desabilita o sistema de step-up"""
	if step_up_assistant:
		step_up_assistant.set_step_up_enabled(enabled)
