# idlestate.gd (versão final)
extends "res://scripts/state.gd"

# Chamado uma vez quando entramos no estado Idle.
func enter():
	character.get_node("AnimatedSprite2D").play("idle")
	character.velocity.x = 0

# Roda a cada frame de física.
func process_physics(delta: float) -> State:
	# Aplica a gravidade se o personagem não estiver no chão.
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
	
	# Verifica se o jogador começou a se mover para transicionar para Run.
	if Input.get_axis("move_left", "move_right") != 0:
		return state_machine.get_node("Run")
		
	# Verifica se o jogador pulou para transicionar para Air.
	if Input.is_action_just_pressed("jump") and character.is_on_floor():
		return state_machine.get_node("Air")
		
	# Se nada acontecer, continua no estado Idle.
	return null
