# state.gd (versão final e robusta)
class_name State
extends Node

var character: CharacterBody2D
var state_machine: Node

# Esta é a nossa nova função de inicialização controlada.
func init(_character: CharacterBody2D, _state_machine: Node):
	self.character = _character
	self.state_machine = _state_machine

# As outras funções voltam a ser simples, sem parâmetros em enter().
func enter():
	pass

func process_physics(_delta: float) -> State:
	return null

func exit():
	pass
