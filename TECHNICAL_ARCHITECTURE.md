# 🏗️ Duchess - Technical Architecture Documentation

## 🎯 Architecture Overview

Duchess follows a **Component-Based Architecture** with **MVC patterns** for complex systems, emphasizing separation of concerns and maintainability.

### Core Architectural Principles
- **Component Composition over Inheritance**
- **Single Responsibility Principle**
- **Dependency Injection for Testability**
- **Signal-Based Communication for Decoupling**
- **Service Locator Pattern for Flexibility**

---

## 🏛️ System Architecture Layers

### **Presentation Layer (View)**
```
ui/
├── HintBalloon.gd              # Directional hint UI component
├── MemoryDisplayUI.gd          # Memory viewing interface (planned)
├── PhotoViewer.gd              # Photo display component (planned)
└── NarrativeText.gd            # Text display with typewriter effect (planned)
```

### **Controller Layer (Business Logic)**
```
controllers/
├── memory_discovery_controller.gd    # Memory location and discovery logic
├── hint_system_controller.gd         # Hint presentation and timing
└── [Future controllers for UI, audio, etc.]
```

### **Model Layer (Data & States)**
```
states/
├── state.gd                    # Base state class
├── idle_state.gd              # Progressive idle animations
├── run_state.gd               # Movement state
├── air_state.gd               # Jumping/falling physics
├── bark_state.gd              # Audio attack state
├── bite_state.gd              # Combat state with combos
├── sniff_state.gd             # Memory discovery state
└── dig_state.gd               # Memory collection state

models/
├── memory_manager.gd          # Memory system orchestrator
├── memoria.gd                 # Individual memory instances
└── [Game data models]
```

### **Component Layer (Reusable Systems)**
```
components/
├── slope_detector.gd          # Terrain slope detection and sprite rotation
└── step_up_assistant.gd       # Movement assistance for slope entry
```

---

## 🔄 Finite State Machine (FSM) Architecture

### **State Machine Structure**
```
StateMachine (state_machine.gd)
├── initialize() - Sets up states and initial state
├── process_physics() - Delegates to current state
├── change_state() - Handles state transitions
└── states: Dictionary - Maps state names to instances
```

### **Character Controller Integration**
```gdscript
# duquesa.gd - Main character controller (74 lines)
func _ready():
    setup_components()        # Initialize SlopeDetector, StepUpAssistant
    setup_state_machine()    # Initialize FSM with all states
    
func _physics_process(delta):
    state_machine.process_physics(self, delta)  # Delegate to current state
    apply_physics(delta)      # Apply movement after state processing
```

### **State Lifecycle Pattern**
```gdscript
# Base pattern for all states
extends State

func enter(character: CharacterBody2D, state_machine: StateMachine):
    # Initialize state, start animations, set up timers
    
func process_physics(character: CharacterBody2D, delta: float) -> State:
    # Handle input, physics, update animations
    # Return next state or null to continue current state
    
func exit():
    # Cleanup animations, stop timers, reset state
```

---

## 🎮 Character Movement System

### **Movement Components**
1. **SlopeDetector Component**
   - Dual RayCast2D nodes for slope detection
   - Calculates terrain angle using `atan2(height_diff, horizontal_distance)`
   - Applies sprite rotation with configurable smoothing
   - Moving average for angle stability

2. **StepUpAssistant Component**
   - Wall and step detection using additional raycasts
   - Multi-scenario step-up assistance with force application
   - Configurable force intensity based on step height
   - Smooth slope entry mechanics

### **Physics Configuration**
```gdscript
# CharacterBody2D optimized for slope movement
floor_stop_on_slope = false      # Allows sliding on slopes
floor_constant_speed = true      # Maintains speed on inclines
floor_max_angle = deg_to_rad(45) # Maximum climbable angle
floor_snap_length = 10.0         # Ground snapping distance
```

---

## 🧠 Memory System Architecture (MVC Pattern)

### **Model-View-Controller Separation**

#### **MemoryManager (Model)**
```gdscript
# Central memory orchestrator
class_name MemoryManager

var ordered_memories: Array[NodePath]    # Sequential memory collection
var current_memory_index: int = 0        # Progress tracking
var memories_discovered: Array[Memoria]  # Discovery state

func get_current_target_memory() -> Memoria
func advance_to_next_memory()
func is_memory_collected(memoria: Memoria) -> bool
```

#### **MemoryDiscoveryController (Controller)**
```gdscript
# Business logic for memory discovery
class_name MemoryDiscoveryController

# Core functionality
func get_current_target_memory() -> Memoria
func calculate_hint_type(player_pos: Vector2, distance: float) -> HintType
func check_memory_proximity(player_pos: Vector2, distance: float) -> bool

# Signals for decoupled communication
signal memory_discovered(memory: Memoria)
signal memory_collected(memory: Memoria)
signal current_target_changed(new_target: Memoria)
```

#### **HintSystemController (View Controller)**
```gdscript
# Presentation logic for hints
class_name HintSystemController

func activate_hints()              # Enable hint system
func deactivate_hints()           # Disable hint system
func force_hint_update()          # Manual refresh
func set_update_rate(rate: float) # Configure update frequency

# Signals for UI coordination
signal hint_shown(hint_type: HintType)
signal hint_hidden()
```

### **Memory Discovery Flow**
```
1. Player enters Sniff state
2. SniffState calls hint_system_controller.activate_hints()
3. HintSystemController queries MemoryDiscoveryController.get_current_target_memory()
4. Distance and direction calculated for current target
5. HintBalloon UI updated via signals
6. Player follows hints to memory location
7. Dig state triggered when in proximity
8. Memory collected and progress advanced
```

---

## 🎨 Animation & Audio Systems

### **Animation Management**
```gdscript
# Progressive idle system
idle_state.gd:
├── idle_timer: 3.0s     → sit animation
├── sit_timer: 5.0s      → lie down animation  
├── lie_timer: 7.0s      → sleep animation
└── reset on movement or input
```

### **Audio Integration**
```gdscript
# Bark state with randomized audio
bark_state.gd:
├── bark_sounds: Array[AudioStream] # Multiple bark variations
├── randomized_playback()           # Prevents repetition
└── audio_duration_based_timing     # State duration matches audio
```

### **Sprite Management**
```gdscript
# Automatic sprite flipping and rotation
duquesa.gd:
├── slope_detector.apply_sprite_rotation() # Terrain-based rotation
└── update_sprite_direction()              # Movement-based flipping
```

---

## 🔧 Component System Architecture

### **Component Initialization Pattern**
```gdscript
# duquesa.gd component setup
func setup_components():
    # Slope detection component
    slope_detector = SlopeDetector.new()
    add_child(slope_detector)
    slope_detector.initialize(self, sprite, slope_raycast_left, slope_raycast_right)
    
    # Step-up assistance component  
    step_up_assistant = StepUpAssistant.new()
    add_child(step_up_assistant)
    step_up_assistant.initialize(self, wall_raycast, step_raycast)
```

### **Component Communication**
```gdscript
# Components expose data through methods
func get_current_slope_angle() -> float:
    return slope_detector.get_current_angle()
    
func get_step_up_info() -> Dictionary:
    return step_up_assistant.get_debug_info()
```

---

## 🏗️ Refactoring Roadmap

### **Completed Refactorings**
- ✅ **SlopeDetector Component** - Extracted from duquesa.gd (reduced from 177→74 lines)
- ✅ **StepUpAssistant Component** - Movement assistance system
- ✅ **MVC Memory System** - Separated discovery, management, and presentation
- ✅ **Controller Pattern** - Business logic extracted from states

### **Planned Refactorings (High Priority)**

#### **Component Registry System**
```gdscript
# Centralized component management
core/ComponentRegistry.gd:
├── register_service(name: String, instance: Object)
├── get_service(name: String) -> Object
├── inject_dependencies(target: Object, deps: Dictionary)
└── resolve_dependencies(target: Object)
```

#### **State Component Extraction**
```
dig_state.gd (265 lines) → 4 focused components:
├── dig_state.gd (~50 lines - state logic only)
├── DigAnimationComponent.gd (smoke effects, animations)
├── MemoryCollectorComponent.gd (collection mechanics)
└── DiggingMechanicsComponent.gd (physics and timing)

bite_state.gd (178 lines) → 4 specialized components:
├── bite_state.gd (~40 lines - state transitions)
├── AttackComponent.gd (damage, timing, hitboxes)
├── DashComponent.gd (dash mechanics)
└── ComboSystemComponent.gd (combo chains)
```

#### **Input Handler Component**
```gdscript
# Centralized input processing
components/InputHandlerComponent.gd:
├── collect_input() - centralized input gathering
├── buffer_actions() - responsive input buffering
├── get_movement_axis() - standardized movement
└── is_action_buffered() - buffered action checking
```

### **Target Architecture Patterns**

#### **Entity-Component-System (ECS) Hybrid**
```
duquesa.gd (Entity):
├── PhysicsComponent (gravity, movement)
├── AnimationComponent (centralized animation control)
├── InputComponent (buffered input handling)
├── SlopeDetector (terrain interaction)
├── StepUpAssistant (movement assistance)
└── StateMachine (orchestrates state components)
```

#### **Event Bus for Decoupled Communication**
```
EventBus:
├── memory_events (discovery, collection, viewing)
├── animation_events (start, complete, transition)
├── input_events (pressed, released, buffered)
├── state_events (enter, exit, transition)
└── ui_events (show, hide, interact)
```

---

## 🧪 Testing & Debugging Architecture

### **Component Testing Pattern**
```gdscript
# Each component exposes debug information
func debug_info() -> Dictionary:
    return {
        "component_name": get_script().get_path().get_file(),
        "state": get_current_state(),
        "performance_metrics": get_performance_data()
    }
```

### **Integration Testing**
```gdscript
# Console debugging commands
var discovery = get_tree().get_first_node_in_group("memory_discovery_controller")
print(discovery.debug_info())

var hint_system = get_tree().get_first_node_in_group("hint_system_controller")
print(hint_system.debug_info())
```

### **Debugging Tools**
- **get_current_slope_angle()** - Monitor slope detection
- **get_step_up_info()** - Debug step-up system
- **StateMachine signals** - Track state transitions
- **MemoryManager progress** - Verify collection order

---

## ⚡ Performance Considerations

### **Optimization Strategies**
- **Component Caching**: Results cached in MemoryDiscoveryController
- **Update Rate Control**: Configurable update frequency for hint system
- **Lazy Initialization**: Components created only when needed
- **Signal-Based Updates**: Avoid polling, use reactive updates

### **Memory Management**
- **Singleton Controllers**: One instance per context
- **Automatic Cleanup**: Controllers self-manage lifecycle
- **Weak References**: Prevent circular dependencies
- **Resource Pooling**: Reuse common objects

---

## 🔧 Development Guidelines

### **Component Creation Pattern**
1. **Single Responsibility**: Each component has one clear purpose
2. **Dependency Injection**: Accept dependencies via initialize()
3. **Signal Communication**: Use signals for loose coupling
4. **Debug Support**: Implement debug_info() method
5. **Graceful Degradation**: Handle missing dependencies

### **State Development Pattern**
1. **Minimal Logic**: Focus only on state-specific behavior
2. **Controller Delegation**: Use controllers for complex logic
3. **Clean Transitions**: Clear enter/exit responsibilities
4. **Input Handling**: Delegate to InputHandlerComponent when available

### **Code Standards**
- **GDScript Naming**: snake_case for variables, PascalCase for classes
- **Signal Naming**: past_tense_verb pattern (memory_discovered, hint_shown)
- **Component Suffixes**: Component.gd for reusable components
- **Controller Suffixes**: Controller.gd for business logic controllers

---

*This document serves as the technical reference for understanding and contributing to the Duchess game architecture. It should be updated whenever significant architectural changes are made.*

---

*Last Updated: 28/07/2025*  
*Next Review: After major refactoring implementations*