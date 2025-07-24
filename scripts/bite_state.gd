# bite_state.gd - Estado para quando a Duquesa está mordendo/atacando
extends "res://scripts/state.gd"

## Configurações do Estado Bite (editáveis no Inspector)
@export_group("Bite Settings")
@export var bite_duration: float = 0.6  ## Duração da mordida em segundos
@export var damage_timing: float = 0.5  ## Em que % da duração o dano é causado (0.5 = 50%)
@export var combo_threshold: float = 0.7  ## Em que % permite fazer combo (0.7 = 70%)
@export var cancel_threshold: float = 0.8  ## Em que % permite cancelar com pulo (0.8 = 80%)
@export var bark_combo_enabled: bool = true  ## Se permite fazer bark após bite
@export var bite_combo_enabled: bool = true  ## Se permite fazer combo de bites

@export_group("Dash Settings")
@export var dash_enabled: bool = true  ## Se ativa o dash durante bite
@export var dash_speed_multiplier: float = 1.8  ## Multiplicador de velocidade durante dash
@export var dash_duration: float = 0.2  ## Duração do dash em segundos
@export var dash_preserve_direction: bool = true  ## Se preserva direção quando não há input

var bite_timer: float = 0.0
var has_dealt_damage: bool = false  # Para garantir que o dano seja dado apenas uma vez
var is_aerial_bite: bool = false  # Para rastrear se é um ataque aéreo
var dash_direction: float = 0.0  # Direção do dash (1 = direita, -1 = esquerda)
var is_dashing: bool = false  # Se está no período de dash

# Chamado uma vez quando entramos no estado Bite
func enter():
	# Detecta se é um ataque aéreo
	is_aerial_bite = not character.is_on_floor()
	
	# Sempre usa run_bite (tanto no chão quanto no ar)
	character.get_node("AnimatedSprite2D").play("run_bite")
	
	# Configura dash se habilitado
	if dash_enabled:
		is_dashing = true
		# Determina direção do dash
		var input_direction = Input.get_axis("move_left", "move_right")
		if input_direction != 0:
			dash_direction = input_direction
		elif dash_preserve_direction:
			# Preserva direção atual do sprite se não há input
			dash_direction = 1.0 if not character.get_node("AnimatedSprite2D").flip_h else -1.0
		else:
			dash_direction = 0.0
	else:
		is_dashing = false
		dash_direction = 0.0
	
	# Reinicia o timer e flag de dano
	bite_timer = 0.0
	has_dealt_damage = false
	
	# Som de ataque removido - apenas bark tem som
	# get_node("AttackSound").play()

# Roda a cada frame de física enquanto estivermos atacando
func process_physics(delta: float) -> State:
	# 1. APLICAR FÍSICA BÁSICA
	# ------------------------
	# Aplica gravidade se não estiver no chão
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
		# Se começamos no chão mas saímos durante o ataque, vamos para Air
		if not is_aerial_bite:
			return state_machine.get_node("Air")
	
	# Controla movimento horizontal
	if not is_aerial_bite:
		# Verifica se ainda está no período de dash
		if is_dashing and bite_timer < dash_duration:
			# Durante dash: aplica velocidade aumentada na direção do dash
			var dash_speed = character.speed * dash_speed_multiplier
			character.velocity.x = dash_direction * dash_speed
		else:
			# Após dash: movimento normal com input
			is_dashing = false
			var direction = Input.get_axis("move_left", "move_right")
			character.velocity.x = direction * character.speed
		
		# Atualiza direção do sprite baseada na velocidade atual
		if character.velocity.x > 0:
			character.get_node("AnimatedSprite2D").flip_h = false
		elif character.velocity.x < 0:
			character.get_node("AnimatedSprite2D").flip_h = true
	else:
		# Bite aéreo: também aplica dash se habilitado
		if is_dashing and bite_timer < dash_duration:
			# Durante dash aéreo: aplica velocidade aumentada na direção do dash
			var dash_speed = character.speed * dash_speed_multiplier
			character.velocity.x = dash_direction * dash_speed
		else:
			# Após dash aéreo: mantém momentum atual (não aplica input no ar)
			is_dashing = false
	
	# 2. GERENCIAR DURAÇÃO DO ATAQUE
	# ------------------------------
	bite_timer += delta
	
	# Causar dano no timing configurado se ainda não foi feito
	if bite_timer >= bite_duration * damage_timing and not has_dealt_damage:
		# Aqui você pode implementar lógica de dano a inimigos próximos
		deal_damage()
		has_dealt_damage = true
	
	# Se o ataque terminou, decidir qual estado ir
	if bite_timer >= bite_duration:
		# Se foi um ataque aéreo, verifica se ainda estamos no ar
		if is_aerial_bite:
			if not character.is_on_floor():
				return state_machine.get_node("Air")
			else:
				# Tocamos o chão durante o ataque aéreo
				var direction = Input.get_axis("move_left", "move_right")
				if direction != 0:
					return state_machine.get_node("Run")
				else:
					return state_machine.get_node("Idle")
		else:
			# Ataque no chão - comportamento normal
			var direction = Input.get_axis("move_left", "move_right")
			if direction != 0:
				return state_machine.get_node("Run")
			else:
				return state_machine.get_node("Idle")
	
	# 3. PERMITIR COMBO DE ATAQUES
	# ----------------------------
	# Permite fazer outro bite (combo) se habilitado (apenas ataques no chão)
	if not is_aerial_bite and bite_combo_enabled and bite_timer >= bite_duration * combo_threshold and Input.is_action_just_pressed("bite"):
		# Reinicia o ataque para fazer combo
		bite_timer = 0.0
		has_dealt_damage = false
		character.get_node("AnimatedSprite2D").play("run_bite")
		
		# Reaplica dash no combo se habilitado
		if dash_enabled:
			is_dashing = true
			var input_direction = Input.get_axis("move_left", "move_right")
			if input_direction != 0:
				dash_direction = input_direction
			elif dash_preserve_direction:
				dash_direction = 1.0 if not character.get_node("AnimatedSprite2D").flip_h else -1.0
			else:
				dash_direction = 0.0
	
	# Permite fazer bark após bite se habilitado (apenas ataques no chão)
	if not is_aerial_bite and bark_combo_enabled and bite_timer >= bite_duration * combo_threshold and Input.is_action_just_pressed("bark"):
		return state_machine.get_node("Bark")
	
	# Permite fazer sniff após bite (apenas ataques no chão)
	if not is_aerial_bite and bite_timer >= bite_duration * combo_threshold and Input.is_action_just_pressed("sniff"):
		return state_machine.get_node("Sniff")
	
	# Permite cancelar com pulo no final do ataque (apenas ataques no chão)
	if not is_aerial_bite and bite_timer >= bite_duration * cancel_threshold and Input.is_action_just_pressed("jump"):
		return state_machine.get_node("Air")
	
	# Continua no estado Bite
	return null

# Função para causar dano (pode ser expandida posteriormente)
func deal_damage():
	# Debug print para ver quando o dano é causado
	print("Duquesa causou dano!")
	
	# Aqui você pode implementar:
	# - Detecção de inimigos próximos
	# - Aplicação de dano
	# - Efeitos visuais/sonoros
	# - Knockback, etc.

# Chamado quando saímos do estado Bite
func exit():
	# Para o som se estiver tocando
	# if character.get_node("AttackSound").is_playing():
	#     character.get_node("AttackSound").stop()
	pass
