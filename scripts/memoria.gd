class_name Memoria
extends Area2D

# Configurações da memória
@export var memory_title: String = "Lembrança"
@export var memory_description: String = "Uma memória especial..."
@export var memory_photo: Texture2D
@export var discovery_distance: float = 32.0

# Estados da memória
var is_discovered: bool = false
var is_collected: bool = false
var memory_manager: Node

# Nós da cena
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var discovery_area: Area2D = $DiscoveryArea
@onready var discovery_collision: CollisionShape2D = $DiscoveryArea/CollisionShape2D

# Efeitos visuais
@onready var glow_effect: AnimationPlayer = $GlowEffect

func _ready():
	# Adiciona ao grupo de memórias
	add_to_group("memories")
	
	# Encontra o memory manager
	memory_manager = get_tree().get_first_node_in_group("memory_manager")
	
	# Inicialmente a memória está escondida (apenas para sniff)
	set_visible_state(false)
	
	# Conecta sinais
	body_entered.connect(_on_duquesa_entered)
	discovery_area.body_entered.connect(_on_discovery_area_entered)
	
	# Configura a área de descoberta
	setup_discovery_area()

func setup_discovery_area():
	# Configura o raio da área de descoberta
	if discovery_collision and discovery_collision.shape is CircleShape2D:
		discovery_collision.shape.radius = discovery_distance

func _on_discovery_area_entered(body):
	if body.name == "Duquesa" and not is_discovered:
		discover_memory()

func discover_memory():
	if is_discovered:
		return
		
	is_discovered = true
	set_visible_state(true)
	
	# Efeito visual de descoberta
	if glow_effect and glow_effect.has_animation("discover"):
		glow_effect.play("discover")
	

func _on_duquesa_entered(body):
	# Memória não é mais coletada automaticamente
	# Agora é necessário usar a ação DIG quando próximo
	pass

func collect_memory():
	if is_collected:
		return
		
	is_collected = true
	
	# Mostra a interface da memória
	show_memory_interface()
	
	# Avisa o memory manager
	if memory_manager:
		memory_manager.advance_to_next_memory()
	
	# Remove a memória da cena
	queue_free()

func show_memory_interface():
	# Por agora, apenas mostra no console
	# No futuro, isso será substituído por uma interface real
	print("=== MEMÓRIA COLETADA ===")
	print("Título: ", memory_title)
	print("Descrição: ", memory_description)
	print("========================")

func set_visible_state(is_visible: bool):
	if sprite:
		sprite.visible = is_visible
	if collision:
		collision.set_deferred("disabled", not is_visible)

# Função chamada pelo sniff para verificar se esta é a memória alvo
func is_current_target() -> bool:
	if not memory_manager:
		return false
	
	var current_target = memory_manager.get_current_memory_target()
	return current_target == self

# Retorna a distância até a Duquesa
func get_distance_to_duquesa() -> float:
	var duquesa = get_tree().get_first_node_in_group("player")
	if duquesa:
		return global_position.distance_to(duquesa.global_position)
	return INF

# Verifica se a memória pode ser coletada pela Duquesa (para usar com DIG)
func can_be_collected_by_player(player_position: Vector2, max_distance: float = 48.0) -> bool:
	if not is_discovered or is_collected:
		return false
	
	var distance = global_position.distance_to(player_position)
	return distance <= max_distance

# Método público para coletar a memória via DIG
func attempt_collection_by_dig(player_position: Vector2) -> bool:
	if can_be_collected_by_player(player_position):
		collect_memory()
		return true
	return false
