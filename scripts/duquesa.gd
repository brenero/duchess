# duquesa.gd - Agora muito mais limpo!
extends CharacterBody2D

@export var speed = 250.0
@export var gravity = 800.0
@export var jump_velocity = -400.0

@onready var state_machine = $StateMachine

# A lógica de input, animação e estado agora está nos estados individuais.
# O script principal só precisa aplicar o movimento final.
func _physics_process(delta):
	if state_machine and state_machine.current_state:
		var new_state = state_machine.current_state.process_physics(delta)
		if new_state:
			state_machine.transition_to(new_state)
	
	move_and_slide()

func _ready():
	# Garante que as partículas comecem desabilitadas
	if has_node("DustParticles"):
		var particles = get_node("DustParticles")
		particles.emitting = false
