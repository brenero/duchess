# 🐕 Duchess - Development Roadmap
## Comprehensive Development Plan for Narrative Platformer

---

## 🎯 Project Vision & Philosophy

**Duchess** is a heartfelt narrative 2D platformer about a Rottweiler puppy collecting memories of her life with Lívia. The game serves as an emotional tribute that provides closure through interactive storytelling.

### Core Philosophy
- **Emotional Connection**: Every mechanic serves the narrative
- **Quality over Quantity**: Focused, polished experience  
- **Technical Excellence**: Clean, maintainable architecture
- **Player Experience**: Intuitive controls and meaningful interactions

### Target Experience
- **Duration**: 15-20 minutes of core gameplay
- **Tone**: Nostalgic, touching, ultimately healing
- **Mechanics**: Simple platforming with memory collection
- **Conclusion**: Emotional farewell and closure

---

## 📊 Current Status & Completed Features

### ✅ Phase 0: Foundation (COMPLETED)
- **FSM Character Controller** with 7 states (Idle, Run, Air, Bark, Bite, Sniff, Dig)
- **Memory Collection System** with ordered discovery and directional hints
- **Component Architecture** with SlopeDetector and StepUpAssistant
- **Controller Pattern** implementation for memory and hint systems
- **Audio System** with bark effects and ambient sounds
- **Advanced Movement** with slope rotation and step-up assistance

### 🔧 Technical Infrastructure
- Component-based architecture established
- MVC pattern implemented for complex systems  
- Signal-based communication between systems
- Comprehensive FSM with fluid state transitions
- Physics improvements for smooth movement

---

## 🗺️ Development Phases

## Phase 1: Narrative Experience & Interface (HIGH PRIORITY)
**Timeline**: 2-3 weeks  
**Focus**: Player experience and emotional impact

### 1.1 Memory Interface System
**Status**: 🔴 Not Started  
**Estimate**: 1 week

**Objectives**:
- [ ] Create memory display UI overlay
- [ ] Implement photo viewing with real photos (Texture2D)
- [ ] Add narrative text system for each memory
- [ ] Design polaroid/vintage photo frame aesthetic
- [ ] Smooth fade in/out transitions
- [ ] Continue button (non-automatic progression)

**Technical Requirements**:
```
ui/
├── MemoryDisplayUI.gd (overlay controller)
├── PhotoViewer.gd (image display component)
├── NarrativeText.gd (text display with typewriter effect)
└── memory_display.tscn (UI scene)
```

### 1.2 Audio & Atmosphere
**Status**: 🔴 Not Started  
**Estimate**: 3-4 days

**Objectives**:
- [ ] Background music composition/selection
- [ ] Memory-specific audio cues
- [ ] Ambient sound layers (birds, wind, farm sounds)
- [ ] Audio transitions between areas
- [ ] Volume balancing and mixing

### 1.3 Level Design & Visual Polish
**Status**: 🔴 Not Started  
**Estimate**: 1 week

**Objectives**:
- [ ] Design main level layout with memory placement
- [ ] Create farm-themed background art
- [ ] Implement parallax scrolling backgrounds
- [ ] Add environmental details and decorations
- [ ] Memory location theming (match memory content)

---

## Phase 2: Technical Architecture Refinement (MEDIUM PRIORITY)  
**Timeline**: 2-3 weeks  
**Focus**: Code quality and maintainability

### 2.1 Component Registry System
**Status**: 🔴 Not Started  
**Estimate**: 3-4 days

**Problem**: Inconsistent dependency management across states
**Solution**: Centralized component registry with dependency injection

```
core/
├── ComponentRegistry.gd (centralized component management)
├── ServiceLocator.gd (service discovery pattern)  
└── DependencyInjector.gd (automated dependency resolution)
```

**Benefits**: Eliminates hardcoded dependencies, improves testability

### 2.2 State System Refactoring
**Status**: 🔴 Not Started  
**Estimate**: 1-2 weeks

**Targets for Refactoring**:

#### dig_state.gd (265 lines → 4 components)
```
dig_state.gd (265 lines) →
├── dig_state.gd (~50 lines - state logic only)
├── DigAnimationComponent.gd (smoke effects, animations)
├── MemoryCollectorComponent.gd (collection mechanics)
└── DiggingMechanicsComponent.gd (physics and timing)
```

#### bite_state.gd (178 lines → 4 components)  
```
bite_state.gd (178 lines) →
├── bite_state.gd (~40 lines - state transitions)
├── AttackComponent.gd (damage, timing, hitboxes)
├── DashComponent.gd (dash mechanics)
└── ComboSystemComponent.gd (combo chains)
```

**Benefits**: Single responsibility, reusable components, easier testing

### 2.3 Input & Animation Systems
**Status**: 🔴 Not Started  
**Estimate**: 4-5 days

#### Input Handler Component
**Problem**: Input handling duplicated across all states
**Solution**: Centralized input processing with buffering

```
components/InputHandlerComponent.gd:
├── collect_input() - centralized input gathering
├── buffer_actions() - responsive input buffering  
├── get_movement_axis() - standardized movement
└── is_action_buffered() - buffered action checking
```

#### Animation Controller
**Problem**: Animation names hardcoded, no centralized control
**Solution**: Configurable animation management system

```
components/AnimationController.gd:
├── play_animation(state_name) - state→animation mapping
├── blend_animations() - smooth transitions
├── queue_animation() - animation sequences
└── animation_events - signal system for animation events
```

---

## Phase 3: Game Content & Polish (MEDIUM PRIORITY)
**Timeline**: 1-2 weeks  
**Focus**: Content creation and final polish

### 3.1 Memory Content Creation
**Status**: 🔴 Not Started  
**Estimate**: 4-5 days

**Objectives**:
- [ ] Collect and prepare real photos from Lívia/Duchess
- [ ] Write narrative text for each memory (Portuguese)
- [ ] Create memory sequence that builds emotional arc
- [ ] Design memory placement in level for natural progression
- [ ] Implement memory unlock/progression system

### 3.2 Final Gameplay Polish  
**Status**: 🔴 Not Started  
**Estimate**: 3-4 days

**Objectives**:
- [ ] Fine-tune movement physics and responsiveness
- [ ] Balance difficulty and accessibility
- [ ] Add particle effects and visual feedback
- [ ] Implement screen transitions and effects
- [ ] Add accessibility options (subtitles, volume controls)

### 3.3 Ending Sequence
**Status**: 🔴 Not Started  
**Estimate**: 2-3 days

**Objectives**:
- [ ] Design emotional conclusion after final memory
- [ ] Create farewell scene with meaningful interaction
- [ ] Implement credits sequence
- [ ] Add replay/reflection mechanics
- [ ] Final emotional beat and closure

---

## Phase 4: Release Preparation (LOW PRIORITY)
**Timeline**: 1 week  
**Focus**: Testing, optimization, and distribution

### 4.1 Testing & Bug Fixes
**Status**: 🔴 Not Started  
**Estimate**: 3-4 days

**Objectives**:
- [ ] Comprehensive playthrough testing
- [ ] Performance optimization and profiling
- [ ] Cross-platform compatibility testing
- [ ] Bug fixes and edge case handling
- [ ] Save system implementation (if needed)

### 4.2 Documentation & Distribution
**Status**: 🔴 Not Started  
**Estimate**: 2-3 days

**Objectives**:
- [ ] Player documentation and controls guide
- [ ] Build configurations for target platforms
- [ ] Distribution package preparation
- [ ] Version control and release tagging
- [ ] Post-release support planning

---

## 📈 Progress Tracking & Metrics

### Development Metrics
| Phase | Components | Status | Estimated Hours | Complexity |
|-------|------------|--------|----------------|------------|
| Phase 0 (Foundation) | ✅ Complete | 100% | ~40 hours | ⭐⭐⭐⭐⭐ |
| Phase 1 (Experience) | 3 systems | 🔴 0% | ~60 hours | ⭐⭐⭐⭐ |
| Phase 2 (Architecture) | 6 components | 🔴 0% | ~80 hours | ⭐⭐⭐⭐⭐ |
| Phase 3 (Content) | 3 systems | 🔴 0% | ~40 hours | ⭐⭐⭐ |
| Phase 4 (Release) | 2 systems | 🔴 0% | ~30 hours | ⭐⭐ |

### Quality Goals
- **Code Complexity**: 70% reduction in monolithic code
- **Maintainability**: 80% improvement in code organization
- **Feature Velocity**: 50% faster implementation of new features
- **Bug Density**: 60% reduction through better architecture
- **Player Experience**: Emotional impact and intuitive controls

---

## 🎯 Technical Architecture Goals

### Target Architecture Patterns

#### Entity-Component-System (ECS) Hybrid
```
duquesa.gd (Entity):
├── PhysicsComponent (gravity, movement)
├── AnimationComponent (centralized animation control)
├── InputComponent (buffered input handling)
├── SlopeDetector (terrain interaction)
├── StepUpAssistant (movement assistance)
└── StateMachine (orchestrates state components)
```

#### Service Locator with Dependency Injection
```
ServiceRegistry:
├── register_service(name: String, instance: Object)
├── get_service(name: String) -> Object
├── inject_dependencies(target: Object, deps: Dictionary)
└── resolve_dependencies(target: Object)

Usage in States:
state.initialize(character, state_machine, services: ServiceRegistry)
```

#### Event Bus for Decoupled Communication
```
EventBus:
├── memory_events (discovery, collection, viewing)
├── animation_events (start, complete, transition)
├── input_events (pressed, released, buffered)
├── state_events (enter, exit, transition)
└── ui_events (show, hide, interact)
```

---

## 📋 Contribution Guidelines

### Branch Strategy
- `main` - Stable, playable builds
- `develop` - Integration branch for features
- `feature/[system-name]` - Individual feature development
- `refactor/[component-name]` - Architecture improvements
- `content/[memory-batch]` - Content and asset additions

### Commit Message Standards
- `feat: add [feature name]` - New features
- `refactor: extract [component] from [system]` - Architecture improvements
- `content: add [memory/asset type]` - Content additions
- `fix: resolve [issue description]` - Bug fixes
- `docs: update [documentation type]` - Documentation updates

### Code Review Process
1. **Self Review**: Test functionality and check code standards
2. **Architecture Review**: Ensure component design principles
3. **Integration Testing**: Verify system interactions
4. **Player Experience**: Test from player perspective
5. **Documentation**: Update relevant documentation

---

## 🎮 Player Experience Priorities

### Primary Experience Goals
1. **Emotional Resonance**: Each memory should feel meaningful
2. **Intuitive Controls**: No tutorial needed, natural discovery
3. **Smooth Progression**: Clear guidance without hand-holding  
4. **Technical Polish**: No bugs or friction to break immersion
5. **Meaningful Conclusion**: Satisfying emotional closure

### Success Criteria
- **Completion Rate**: 90%+ of players reach the ending
- **Emotional Impact**: Players report feeling moved by the experience
- **Technical Quality**: No game-breaking bugs or major friction
- **Accessibility**: Playable by wide range of skill levels
- **Memorability**: Players remember and recommend the experience

---

## 🔄 Roadmap Review & Updates

### Review Schedule
- **Weekly**: Progress on current phase objectives
- **Bi-weekly**: Overall roadmap alignment and priority adjustment
- **Phase Completion**: Comprehensive review and next phase preparation
- **Major Milestone**: Architecture decisions and technical debt assessment

### Adaptation Criteria
- **Player Feedback**: Adjust based on playtesting insights
- **Technical Discoveries**: Modify approach based on implementation learnings
- **Scope Changes**: Adjust timeline and features based on available resources
- **Quality Standards**: Maintain high bar for emotional impact and technical quality

---

*This roadmap serves as the living document for Duchess development, balancing narrative goals with technical excellence to create a meaningful player experience.*

---

*Last Updated: 28/07/2025*  
*Next Review: Weekly progress assessment*