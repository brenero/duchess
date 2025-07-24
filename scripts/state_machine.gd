# statemachine.gd (versão final e robusta)
extends Node

@export var initial_state: State
var current_state: State

func _ready():
	# Primeiro, um loop para inicializar TODOS os estados filhos.
	for child_state in get_children():
		if child_state is State:
			# Para cada estado, chamamos sua função init, passando a Duquesa (owner) e a si mesmo.
			child_state.init(owner, self)
			
	# AGORA, com todos os estados já inicializados, podemos entrar
	# no estado inicial com total segurança.
	if initial_state:
		current_state = initial_state
		current_state.enter() # Não precisamos mais passar parâmetros aqui.

func transition_to(new_state: State):
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter() # E nem aqui.
