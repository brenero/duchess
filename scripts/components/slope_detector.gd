# slope_detector.gd - Component para detecção de slopes e rotação do sprite
class_name SlopeDetector
extends Node

## Componente responsável por detectar slopes e aplicar rotação no sprite do personagem
## Usa um sistema de raycasts duais para calcular ângulos e aplica suavização

# Referências
var character: CharacterBody2D
var sprite: AnimatedSprite2D
var raycast_left: RayCast2D
var raycast_right: RayCast2D

# Configurações exportadas
@export_group("Slope Detection")
@export var rotation_speed: float = 5.0
@export var raycast_length: float = 40.0
@export var min_angle_threshold: float = 0.05
@export var max_rotation_angle: float = 0.3
@export var slope_smoothing: float = 0.8

# Estado interno
var current_slope_angle: float = 0.0
var target_slope_angle: float = 0.0
var last_valid_angles: Array[float] = []

func initialize(char: CharacterBody2D, spr: AnimatedSprite2D, left: RayCast2D, right: RayCast2D):
	"""Inicializa o componente com as referências necessárias"""
	character = char
	sprite = spr
	raycast_left = left
	raycast_right = right
	setup_raycasts()

func setup_raycasts():
	"""Configura os raycasts para detecção de slope"""
	if raycast_left and raycast_right:
		raycast_left.target_position = Vector2(-raycast_length/2, raycast_length)
		raycast_right.target_position = Vector2(raycast_length/2, raycast_length)
		raycast_left.enabled = true
		raycast_right.enabled = true

func update_rotation(delta: float):
	"""Atualiza a rotação do sprite baseada na detecção de slope"""
	if not character or not sprite:
		return
	
	# Só aplicar rotação quando estiver no chão
	if not character.is_on_floor():
		return
	
	# Detectar novo ângulo alvo
	target_slope_angle = detect_slope_angle()
	
	# Suavizar a transição usando lerp com damping
	current_slope_angle = lerp_angle(current_slope_angle, target_slope_angle, rotation_speed * delta)
	
	# Aplicar rotação final ao sprite
	sprite.rotation = lerp_angle(sprite.rotation, current_slope_angle, slope_smoothing)

func detect_slope_angle() -> float:
	"""Detecta o ângulo do slope usando os raycasts"""
	if not raycast_left or not raycast_right:
		return current_slope_angle
	
	var left_hit = raycast_left.is_colliding()
	var right_hit = raycast_right.is_colliding()
	
	if left_hit and right_hit:
		var left_point = raycast_left.get_collision_point()
		var right_point = raycast_right.get_collision_point()
		
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

func get_current_angle() -> float:
	"""Retorna o ângulo atual do slope (útil para outros componentes)"""
	return current_slope_angle

func reset_rotation():
	"""Reseta a rotação do sprite para posição neutra"""
	current_slope_angle = 0.0
	target_slope_angle = 0.0
	last_valid_angles.clear()
	if sprite:
		sprite.rotation = 0.0