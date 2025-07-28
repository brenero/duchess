# duquesa.gd - Agora muito mais limpo!
extends CharacterBody2D

@export var speed = 250.0
@export var gravity = 800.0
@export var jump_velocity = -400.0

@export_group("Slope Rotation")
@export var rotation_speed: float = 5.0
@export var raycast_length: float = 40.0
@export var min_angle_threshold: float = 0.05
@export var max_rotation_angle: float = 0.3
@export var slope_smoothing: float = 0.8

@export_group("Step Up System")
@export var step_up_height: float = 20.0
@export var step_up_distance: float = 12.0
@export var step_up_speed: float = 400.0
@export var step_up_threshold: float = 1.0

@onready var state_machine = $StateMachine
@onready var sprite = $AnimatedSprite2D
@onready var slope_raycast_left = $SlopeRaycastLeft
@onready var slope_raycast_right = $SlopeRaycastRight
@onready var wall_raycast = $WallRaycast
@onready var step_raycast = $StepRaycast

var current_slope_angle: float = 0.0
var target_slope_angle: float = 0.0
var last_valid_angles: Array[float] = []

# A lógica de input, animação e estado agora está nos estados individuais.
# O script principal só precisa aplicar o movimento final.
func _physics_process(delta):
	if state_machine and state_machine.current_state:
		var new_state = state_machine.current_state.process_physics(delta)
		if new_state:
			state_machine.transition_to(new_state)
	
	# Tentar step-up se estiver bloqueado horizontalmente
	if is_on_floor() and abs(velocity.x) > 0:
		attempt_step_up(delta)
	
	move_and_slide()
	
	# Aplicar rotação baseada no slope apenas quando estiver no chão
	if is_on_floor():
		update_slope_rotation(delta)

func _ready():
	# Garante que as partículas comecem desabilitadas
	if has_node("DustParticles"):
		var particles = get_node("DustParticles")
		particles.emitting = false
	
	# Configurar raycasts para detecção de slope e step-up
	setup_slope_raycasts()
	setup_stepup_raycasts()

func setup_slope_raycasts():
	if slope_raycast_left and slope_raycast_right:
		slope_raycast_left.target_position = Vector2(-raycast_length/2, raycast_length)
		slope_raycast_right.target_position = Vector2(raycast_length/2, raycast_length)
		slope_raycast_left.enabled = true
		slope_raycast_right.enabled = true

func detect_slope_angle() -> float:
	if not slope_raycast_left or not slope_raycast_right:
		return current_slope_angle
	
	var left_hit = slope_raycast_left.is_colliding()
	var right_hit = slope_raycast_right.is_colliding()
	
	if left_hit and right_hit:
		var left_point = slope_raycast_left.get_collision_point()
		var right_point = slope_raycast_right.get_collision_point()
		
		# Calcular o ângulo baseado na diferença de altura entre os pontos
		var height_diff = right_point.y - left_point.y
		var horizontal_distance = right_point.x - left_point.x
		
		if abs(horizontal_distance) > 0.1:
			var raw_angle = atan2(height_diff, horizontal_distance)
			
			# Filtrar ângulos extremos
			raw_angle = clamp(raw_angle, -max_rotation_angle, max_rotation_angle)
			
			# Adicionar à lista de ângulos recentes para suavização
			last_valid_angles.push_back(raw_angle)
			if last_valid_angles.size() > 5:
				last_valid_angles.pop_front()
			
			# Calcular média dos últimos ângulos para suavização
			var smoothed_angle = 0.0
			for angle in last_valid_angles:
				smoothed_angle += angle
			smoothed_angle /= last_valid_angles.size()
			
			# Aplicar threshold para evitar micro-rotações
			if abs(smoothed_angle - current_slope_angle) > min_angle_threshold:
				return smoothed_angle
	
	return current_slope_angle

func update_slope_rotation(delta: float):
	if not sprite:
		return
	
	# Detectar novo ângulo alvo
	target_slope_angle = detect_slope_angle()
	
	# Suavizar a transição usando lerp com damping
	current_slope_angle = lerp_angle(current_slope_angle, target_slope_angle, rotation_speed * delta)
	
	# Aplicar rotação final ao sprite
	sprite.rotation = lerp_angle(sprite.rotation, current_slope_angle, slope_smoothing)

func setup_stepup_raycasts():
	if wall_raycast and step_raycast:
		wall_raycast.target_position = Vector2(step_up_distance, 0)
		step_raycast.target_position = Vector2(step_up_distance, -step_up_height)
		wall_raycast.enabled = true
		step_raycast.enabled = true

func attempt_step_up(delta: float):
	if not wall_raycast or not step_raycast:
		return
	
	# Determinar direção do movimento
	var direction = sign(velocity.x)
	if direction == 0:
		return
	
	# Ajustar raycasts para a direção atual
	wall_raycast.target_position = Vector2(step_up_distance * direction, 0)
	step_raycast.target_position = Vector2(step_up_distance * direction, -step_up_height)
	
	# Forçar atualização dos raycasts
	wall_raycast.force_raycast_update()
	step_raycast.force_raycast_update()
	
	# Verificar diferentes cenários de step-up
	var wall_collision = wall_raycast.is_colliding()
	var step_collision = step_raycast.is_colliding()
	
	if wall_collision:
		var wall_point = wall_raycast.get_collision_point()
		var step_height = wall_point.y - global_position.y
		
		# Cenário 1: Parede baixa com espaço livre acima (step clássico)
		if not step_collision and step_height > -step_up_height and step_height < -step_up_threshold:
			apply_step_up_force(direction, delta, 1.0)
			
		# Cenário 2: Início de slope - força mais suave mas constante
		elif step_height > -step_up_height and step_height < -step_up_threshold:
			apply_step_up_force(direction, delta, 0.6)
			
	# Cenário 3: Verificar se está "grudado" numa parede de slope
	# Detectar se a velocidade horizontal está sendo muito reduzida
	var expected_speed = abs(velocity.x)
	if expected_speed > 50 and is_on_wall():
		# Aplicar uma força de "escalada" mais suave
		apply_step_up_force(direction, delta, 0.4)

func apply_step_up_force(direction: float, delta: float, intensity: float):
	# Aplicar impulso vertical proporcional à intensidade
	var vertical_force = -step_up_speed * delta * 60 * intensity
	velocity.y = min(velocity.y, vertical_force)
	
	# Manter momentum horizontal
	var horizontal_boost = direction * step_up_speed * delta * 0.3 * intensity
	velocity.x += horizontal_boost
	
	# Pequeno ajuste adicional para superar friction em slopes
	if intensity < 1.0:  # Para slopes, não para steps normais
		velocity.x *= 1.1
