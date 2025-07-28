# step_up_assistant.gd - Component para assistência na subida de slopes e degraus
class_name StepUpAssistant
extends Node

## Componente responsável por detectar obstáculos baixos e aplicar força assistida
## para permitir entrada suave em slopes e subida de pequenos degraus

# Referências
var character: CharacterBody2D
var wall_raycast: RayCast2D
var step_raycast: RayCast2D

# Configurações exportadas
@export_group("Step Up Settings")
@export var step_up_height: float = 20.0
@export var step_up_distance: float = 12.0
@export var step_up_speed: float = 400.0
@export var step_up_threshold: float = 1.0

func initialize(char: CharacterBody2D, wall: RayCast2D, step: RayCast2D):
	"""Inicializa o componente com as referências necessárias"""
	character = char
	wall_raycast = wall
	step_raycast = step
	setup_raycasts()

func setup_raycasts():
	"""Configura os raycasts para detecção de step-up"""
	if wall_raycast and step_raycast:
		wall_raycast.target_position = Vector2(step_up_distance, 0)
		step_raycast.target_position = Vector2(step_up_distance, -step_up_height)
		wall_raycast.enabled = true
		step_raycast.enabled = true

func attempt_step_up(delta: float):
	"""Tenta aplicar assistência de step-up se necessário"""
	if not character or not wall_raycast or not step_raycast:
		return
	
	# Só tentar step-up se estiver no chão e se movendo
	if not character.is_on_floor() or abs(character.velocity.x) == 0:
		return
	
	# Determinar direção do movimento
	var direction = sign(character.velocity.x)
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
		var step_height = wall_point.y - character.global_position.y
		
		# Cenário 1: Parede baixa com espaço livre acima (step clássico)
		if not step_collision and _is_valid_step_height(step_height):
			apply_step_up_force(direction, delta, 1.0)
			
		# Cenário 2: Início de slope - força mais suave mas constante
		elif _is_valid_step_height(step_height):
			apply_step_up_force(direction, delta, 0.6)
			
	# Cenário 3: Verificar se está "grudado" numa parede de slope
	if _is_stuck_on_wall():
		apply_step_up_force(direction, delta, 0.4)

func apply_step_up_force(direction: float, delta: float, intensity: float):
	"""Aplica força de step-up com intensidade variável"""
	if not character:
		return
	
	# Aplicar impulso vertical proporcional à intensidade
	var vertical_force = -step_up_speed * delta * 60 * intensity
	character.velocity.y = min(character.velocity.y, vertical_force)
	
	# Manter momentum horizontal
	var horizontal_boost = direction * step_up_speed * delta * 0.3 * intensity
	character.velocity.x += horizontal_boost
	
	# Pequeno ajuste adicional para superar friction em slopes
	if intensity < 1.0:  # Para slopes, não para steps normais
		character.velocity.x *= 1.1

func _is_valid_step_height(step_height: float) -> bool:
	"""Verifica se a altura do degrau é válida para step-up"""
	return step_height > -step_up_height and step_height < -step_up_threshold

func _is_stuck_on_wall() -> bool:
	"""Detecta se o personagem está "grudado" numa parede"""
	var expected_speed = abs(character.velocity.x)
	return expected_speed > 50 and character.is_on_wall()

func set_step_up_enabled(enabled: bool):
	"""Habilita/desabilita o sistema de step-up"""
	if wall_raycast:
		wall_raycast.enabled = enabled
	if step_raycast:
		step_raycast.enabled = enabled

func get_step_up_info() -> Dictionary:
	"""Retorna informações de debug sobre o sistema step-up"""
	return {
		"wall_collision": wall_raycast.is_colliding() if wall_raycast else false,
		"step_collision": step_raycast.is_colliding() if step_raycast else false,
		"character_on_floor": character.is_on_floor() if character else false,
		"character_on_wall": character.is_on_wall() if character else false
	}