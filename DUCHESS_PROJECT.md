# 🐕 Duchess Game - Project Documentation

## 📖 Project Overview & Story

**Duchess** is a narrative 2D platformer game made in Godot 4.4 about a Rottweiler puppy collecting memories of her life with Lívia. The game serves as a touching tribute that culminates in a farewell they never had in real life.

### Central Story
- Lívia received Duchess when she was 4 years old
- They grew up together as best friends  
- At 15, Lívia moved to another city to study
- Duchess passed away on the farm and Lívia couldn't say goodbye
- The game offers this farewell through an emotional journey

### Game Vision
A **narrative platformer** where players control Duchess climbing platforms and collecting memories through a **Sniff** mechanic. Each memory tells part of their story together, building to an emotional conclusion that provides closure.

---

## 🏗️ Technical Architecture

### Development Setup
- **Engine**: Godot 4.4
- **Language**: GDScript  
- **Architecture**: Component-based FSM with MVC controllers
- **Repository**: https://github.com/brenero/duchess

### Core Systems

#### Character Controller (FSM-based)
**Main Controller**: `duquesa.gd` - Orchestrates components and core movement
**Components**:
- `SlopeDetector` - Slope detection and sprite rotation
- `StepUpAssistant` - Movement assistance for slope entry
- `StateMachine` - Manages character states

#### Character States
1. **Idle** - Progressive animations (idle → sit → lie → sleep)
2. **Run** - Movement with attack capabilities  
3. **Air** - Jumping/falling with aerial control
4. **Bark** - Ground-only audio attack with sound effects
5. **Bite** - Dynamic attack with movement support and combos
6. **Sniff** - Memory discovery with directional hints
7. **Dig** - Memory collection with smoke effects

#### Memory System (MVC Pattern)
- **MemoryManager** - Orchestrates ordered memory collection
- **MemoryDiscoveryController** - Handles memory finding logic  
- **HintSystemController** - Manages directional hints and UI
- **Memoria** - Individual memory instances with metadata

---

## 🎮 Controls & Gameplay

### Input Controls
- **Movement**: A/D keys or Left/Right arrows
- **Jump**: Spacebar
- **Bark**: F key (audio attack)
- **Bite**: Shift key (dash attack with combos)
- **Sniff**: Q key (reveals memory hints)
- **Dig**: Z key (collect memories)
- **Gamepad**: Full controller support

### Core Gameplay Loop
1. **Explore** platforms using movement and jumps
2. **Sniff** (Q) to reveal directional hints to memories
3. **Navigate** using arrow hints pointing to next memory
4. **Dig** (Z) when near memory to collect and view
5. **Experience** narrative through memory photos and text
6. **Progress** through ordered sequence of memories

### Memory Discovery Mechanics
- **Ordered Collection**: Memories must be collected in sequence
- **Directional Hints**: Arrow system points toward next memory
- **Distance-based**: Hints appear when within discovery range
- **Visual Feedback**: Exclamation marks indicate discoverable memories
- **Sniff Integration**: Q key reveals all available hints

---

## 📁 Project Structure

```
duchess/
├── scripts/
│   ├── duquesa.gd                    # Main character controller
│   ├── state_machine.gd              # FSM implementation  
│   ├── components/                   # Component-based architecture
│   │   ├── slope_detector.gd         # Slope detection & rotation
│   │   └── step_up_assistant.gd      # Movement assistance
│   ├── controllers/                  # MVC Controllers
│   │   ├── memory_discovery_controller.gd
│   │   └── hint_system_controller.gd
│   ├── states/                       # FSM States
│   │   ├── state.gd                  # Base state class
│   │   ├── idle_state.gd             # Progressive idle animations
│   │   ├── run_state.gd              # Movement state
│   │   ├── air_state.gd              # Jumping/falling state
│   │   ├── bark_state.gd             # Audio attack state
│   │   ├── bite_state.gd             # Combat state with combos
│   │   ├── sniff_state.gd            # Memory discovery state
│   │   └── dig_state.gd              # Memory collection state
│   └── memory_manager.gd             # Memory system orchestrator
├── scenes/
│   ├── duquesa.tscn                  # Main character scene
│   ├── main.tscn                     # Main game scene
│   ├── memoria.tscn                  # Memory instance scene
│   └── parallax_background.tscn      # Background system
└── assets/
    ├── duquesa/                      # Character sprites & animations
    │   ├── RottweilerIdle.png        # Idle animation frames
    │   ├── RittieRun.png             # Running animation
    │   ├── RottweilerBark.png        # Bark animation
    │   ├── RottweilerAttack.png      # Bite animation
    │   ├── RottweilerSniff.png       # Sniff animation
    │   ├── Sittiing.png              # Sit animation
    │   ├── LieDownn.png              # Lie down animation
    │   ├── SleepDogg.png             # Sleep animation
    │   └── bark_dog*.mp3             # Bark sound effects
    ├── animations/
    │   └── duquesa.tres              # SpriteFrames resource
    ├── sounds/                       # Audio assets
    │   ├── Morning.mp3               # Ambient morning sounds
    │   └── Evening.mp3               # Ambient evening sounds
    ├── bg/                           # Background assets
    ├── items/                        # Game items (dog house, etc)
    └── tiles/                        # Tileset assets
```

---

## 🚀 Current Implementation Status

### ✅ Completed Systems
- **Complete FSM** with all 7 states fully implemented
- **Progressive Idle** animations with configurable timing
- **Audio System** with bark sound effects and ambient sounds
- **Memory Collection** system with ordered discovery
- **Directional Hints** system with sniff integration
- **Component Architecture** for slope detection and movement assistance
- **Controller Pattern** for memory and hint systems
- **Physics Improvements** with slope rotation and step-up assistance

### 🔧 Technical Features
- **Fluid State Transitions** with combo support
- **Ground/Air Restrictions** for appropriate actions
- **Dynamic Combat** system with dash mechanics
- **Sprite Rotation** based on terrain slopes
- **Movement Assistance** for smooth slope entry
- **Configurable Parameters** for all systems

### 🎨 Visual & Audio
- **Sprite Animations** for all character states
- **Audio Integration** with randomized bark sounds
- **Ambient Audio** for morning/evening atmosphere
- **Automatic Sprite Flipping** based on movement direction
- **Smoke Effects** for digging animation
- **Hint Balloon System** with directional arrows

---

## 🛠️ Development Workflow

### Common Commands
- **Run Game**: F5 in Godot Editor
- **Debug**: F7 in Godot Editor  
- **Export**: Project > Export in Godot

### Git Configuration
- **Local User**: brenero
- **Local Email**: brenoaugusto93@gmail.com
- **Repository**: Uses specific GitHub account for this project
- **Branch Strategy**: Feature branches for major systems

### Code Standards
- **Component-based Architecture**: Prefer composition over inheritance
- **Single Responsibility**: Each class has one clear purpose
- **MVC Pattern**: Controllers handle complex business logic
- **Dependency Injection**: Services injected rather than hardcoded
- **Signal-based Communication**: Loose coupling between systems

---

## 📋 API Reference & Usage

### Memory System Setup
1. Add `MemoryManager` node to main scene
2. Add to "memory_manager" group
3. Configure `ordered_memories` array with NodePaths
4. Place `memoria.tscn` instances in level
5. Configure memory properties (title, description, photo)

### Component Integration
```gdscript
# Initialize components in character _ready()
slope_detector = SlopeDetector.new()
slope_detector.initialize(self, sprite, raycast_left, raycast_right)

step_up_assistant = StepUpAssistant.new()  
step_up_assistant.initialize(self, wall_raycast, step_raycast)
```

### State Creation Pattern
```gdscript
extends State

func enter(character: CharacterBody2D, state_machine: StateMachine):
    # Initialize state
    
func process_physics(character: CharacterBody2D, delta: float) -> State:
    # Handle input, physics, animations
    # Return next state or null to stay
    
func exit():
    # Cleanup when leaving state
```

---

## 🐛 Troubleshooting

### Common Issues
- **Memory not collecting**: Check if MemoryManager is in "memory_manager" group
- **Hints not showing**: Verify sniff range and memory discovery_distance
- **State transitions failing**: Check return values in process_physics()
- **Slope rotation jerky**: Adjust rotation_speed and slope_smoothing parameters
- **Step-up not working**: Verify raycast collision_mask and enabled status

### Debug Information
- Use `get_current_slope_angle()` to check slope detection
- Check `get_step_up_info()` for step-up system debug data
- Monitor state transitions through StateMachine signals
- Verify memory collection order through MemoryManager

---

*This document serves as the comprehensive project reference for developers and contributors to understand the Duchess game architecture, systems, and implementation details.*

---

*Last Updated: 28/07/2025*  
*Next Review: After major system implementations*