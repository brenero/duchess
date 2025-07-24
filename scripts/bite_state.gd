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

var bite_timer: float = 0.0
var has_dealt_damage: bool = false  # Para garantir que o dano seja dado apenas uma vez

# Chamado uma vez quando entramos no estado Bite
func enter():
	# Para o movimento horizontal
	character.velocity.x = 0
	
	# Toca a animação de ataque/mordida
	character.get_node("AnimatedSprite2D").play("bite")
	
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
		# Se sairmos do chão durante o ataque, vamos para Air
		return state_machine.get_node("Air")
	
	# Mantém parado horizontalmente durante o ataque
	character.velocity.x = 0
	
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
		# Verifica se há input de movimento para ir para Run
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0:
			return state_machine.get_node("Run")
		# Senão volta para Idle
		else:
			return state_machine.get_node("Idle")
	
	# 3. PERMITIR COMBO DE ATAQUES
	# ----------------------------
	# Permite fazer outro bite (combo) se habilitado
	if bite_combo_enabled and bite_timer >= bite_duration * combo_threshold and Input.is_action_just_pressed("bite"):
		# Reinicia o ataque para fazer combo
		bite_timer = 0.0
		has_dealt_damage = false
		character.get_node("AnimatedSprite2D").play("bite")
	
	# Permite fazer bark após bite se habilitado
	if bark_combo_enabled and bite_timer >= bite_duration * combo_threshold and Input.is_action_just_pressed("bark"):
		return state_machine.get_node("Bark")
	
	# Permite fazer sniff após bite
	if bite_timer >= bite_duration * combo_threshold and Input.is_action_just_pressed("sniff"):
		return state_machine.get_node("Sniff")
	
	# Permite cancelar com pulo no final do ataque
	if bite_timer >= bite_duration * cancel_threshold and Input.is_action_just_pressed("jump"):
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
