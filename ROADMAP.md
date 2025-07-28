# Duchess Game - Roadmap de Refatorações Arquiteturais

## 🎯 Visão Geral
Este roadmap documenta as melhorias arquiteturais identificadas para transformar a base de código em uma arquitetura moderna baseada em componentes, melhorando manutenibilidade, testabilidade e velocidade de desenvolvimento.

## ✅ Refatorações Concluídas

### v0.1 - Sistema de Movimento Avançado
- [x] **SlopeDetector Component** - Detecção e rotação de sprite em slopes
- [x] **StepUpAssistant Component** - Assistência inteligente para subida
- [x] **duquesa.gd Refactor** - Migração para arquitetura baseada em componentes
- [x] **CharacterBody2D Physics** - Configurações otimizadas para slopes

**Resultados**: Script principal reduzido de 177→74 linhas, separação clara de responsabilidades.

---

## 🚧 Refatorações Planejadas

## Fase 1: Infraestrutura Crítica (ALTA PRIORIDADE)

### 1.1 Component Registry System
**Status**: 🔴 Não iniciado  
**Estimativa**: 2-3 sessões  
**Responsável**: -

**Objetivos**:
- Criar sistema centralizado de gerenciamento de componentes
- Implementar dependency injection para estados
- Estabelecer service locator pattern

**Arquivos Afetados**:
- `scripts/core/ComponentRegistry.gd` (novo)
- `scripts/core/ServiceLocator.gd` (novo)
- `scripts/state_machine.gd` (modificado)

**Benefícios**:
- Base sólida para futuras refatorações
- Eliminação de dependências hardcoded
- Melhor testabilidade dos componentes

---

### 1.2 Refatoração do dig_state.gd
**Status**: 🔴 Não iniciado  
**Estimativa**: 3-4 sessões  
**Responsável**: -

**Problema Atual**:
- 265 linhas violando Single Responsibility Principle
- Gerencia escavação + animações + efeitos + coleta de memórias
- Lógica de controle espalhada e difícil de manter

**Componentes a Extrair**:
```
dig_state.gd (265 linhas) →
├── dig_state.gd (~50 linhas - apenas lógica de estado)
├── components/DigAnimationComponent.gd (animações + smoke effects)
├── components/MemoryCollectorComponent.gd (coleta de memórias)
└── components/DiggingMechanicsComponent.gd (física da escavação)
```

**Benefícios**:
- Estados mais focados e testáveis
- Componentes reutilizáveis
- Lógica de animação centralizada

---

### 1.3 Refatoração do bite_state.gd
**Status**: 🔴 Não iniciado  
**Estimativa**: 2-3 sessões  
**Responsável**: -

**Problema Atual**:
- 178 linhas misturando ataque + dash + combos
- Lógica de combate complexa em um só lugar

**Componentes a Extrair**:
```
bite_state.gd (178 linhas) →
├── bite_state.gd (~40 linhas - apenas transições de estado)
├── components/AttackComponent.gd (dano, timing, hitboxes)
├── components/DashComponent.gd (mecânicas de dash)
└── components/ComboSystemComponent.gd (cadeias de combo)
```

**Benefícios**:
- Sistema de combate modular
- Componentes reutilizáveis para outros ataques
- Facilita balanceamento e tweaking

---

## Fase 2: Sistemas de Qualidade de Vida (MÉDIA PRIORIDADE)

### 2.1 Input Handler Component
**Status**: 🔴 Não iniciado  
**Estimativa**: 1-2 sessões  
**Responsável**: -

**Problema Atual**:
- `Input.get_axis()` e `Input.is_action_just_pressed()` duplicados em todos os estados
- Sem input buffering ou processamento centralizado

**Solução**:
```
components/InputHandlerComponent.gd:
├── collect_input() - centraliza coleta de inputs
├── buffer_actions() - buffering para responsividade
├── get_movement_axis() - movimento padronizado
└── is_action_buffered() - ações com buffer
```

**Estados Afetados**:
- `idle_state.gd`, `run_state.gd`, `air_state.gd`, `bite_state.gd`, `bark_state.gd`

**Benefícios**:
- Eliminação de código duplicado
- Input mais responsivo com buffering
- Configuração centralizada de controles

---

### 2.2 Animation Controller System
**Status**: 🔴 Não iniciado  
**Estimativa**: 2-3 sessões  
**Responsável**: -

**Problema Atual**:
- Nomes de animação hardcoded em cada estado
- Sem controle centralizado ou blending
- Lógica de animação espalhada

**Solução**:
```
components/AnimationController.gd:
├── play_animation(state_name) - mapping estado→animação
├── blend_animations() - transições suaves
├── queue_animation() - fila de animações
└── animation_events - signals para animações

config/AnimationMap.gd:
└── state_to_animation = {"idle": "idle", "run": "run", ...}
```

**Benefícios**:
- Animações centralizadas e configuráveis
- Transições mais suaves
- Fácil modificação de mapeamentos

---

### 2.3 Memory System Refactor
**Status**: 🔴 Não iniciado  
**Estimativa**: 2-3 sessões  
**Responsável**: -

**Problema Atual**:
- `dig_state.gd` cria controllers internamente
- Dependências buscadas via `get_tree()`
- Acoplamento forte entre estados e sistema de memória

**Solução**:
```
systems/MemorySystem.gd:
├── MemoryEventBus.gd (comunicação desacoplada)
├── MemoryState.gd (gerenciamento de estado)
└── MemoryCollectionService.gd (lógica de coleta)
```

**Benefícios**:
- Comunicação desacoplada via eventos
- Testabilidade melhorada
- Sistema de memória independente

---

## Fase 3: Otimizações e Polimento (BAIXA PRIORIDADE)

### 3.1 Physics Component
**Status**: 🔴 Não iniciado  
**Estimativa**: 1-2 sessões

**Objetivo**: Centralizar lógica de física repetida (gravidade, ground checking)

### 3.2 Performance Optimizations
**Status**: 🔴 Não iniciado  
**Estimativa**: 1-2 sessões

**Objetivo**: Otimizações de performance baseadas em profiling

### 3.3 Code Documentation & Testing
**Status**: 🔴 Não iniciado  
**Estimativa**: 2-3 sessões

**Objetivo**: Documentação completa e testes unitários para componentes

---

## 📊 Métricas de Progresso

| Fase | Componentes | Status | Linhas Refatoradas | Complexidade Reduzida |
|------|-------------|--------|--------------------|----------------------|
| Fase 0 (Concluída) | 2 | ✅ 100% | ~140 linhas | ⭐⭐⭐⭐⭐ |
| Fase 1 | 6 | 🔴 0% | ~500 linhas estimadas | ⭐⭐⭐⭐⭐ |
| Fase 2 | 3 | 🔴 0% | ~200 linhas estimadas | ⭐⭐⭐⭐ |
| Fase 3 | 3 | 🔴 0% | ~100 linhas estimadas | ⭐⭐⭐ |

**Meta**: Reduzir complexidade em 70% e melhorar manutenibilidade em 80%

---

## 🎯 Padrões Arquiteturais Alvo

### Entity-Component-System (ECS) Híbrido
```
duquesa.gd (Entity):
├── PhysicsComponent
├── AnimationComponent  
├── InputComponent
├── SlopeDetector
├── StepUpAssistant
└── StateMachine (gerencia componentes de estado)
```

### Service Locator com Dependency Injection
```
ServiceRegistry:
├── register_service(name, instance)
├── get_service(name)
└── inject_dependencies(target, dependencies)

Uso nos Estados:
state.init(character, state_machine, services: ServiceRegistry)
```

### Event Bus para Comunicação Desacoplada
```
EventBus:
├── memory_events (descoberta, coleta, processamento)
├── animation_events (início, fim, loops)
├── input_events (pressionado, liberado, buffered)
└── state_events (entrada, saída, transições)
```

---

## 📋 Como Contribuir

### Preparação para Refatoração
1. **Análise**: Revisar código atual e identificar responsabilidades
2. **Design**: Definir interfaces dos componentes
3. **Implementação**: Criar componentes seguindo padrões estabelecidos
4. **Migração**: Refatorar código existente para usar componentes
5. **Testes**: Verificar funcionalidade e performance
6. **Documentação**: Atualizar documentação e exemplos

### Padrões de Commit
- `feat: add [ComponentName] component`
- `refactor: extract [functionality] from [state/script]`
- `docs: update roadmap with [component] completion`

### Branches
- `refactor/component-registry` - Fase 1.1
- `refactor/dig-state-components` - Fase 1.2  
- `refactor/bite-state-components` - Fase 1.3
- `refactor/input-handler` - Fase 2.1

---

## 📈 Resultados Esperados

### Qualidade de Código
- **Redução de Duplicação**: 80% menos código repetido
- **Single Responsibility**: Cada classe com propósito único
- **Testabilidade**: 100% dos componentes testáveis isoladamente
- **Manutenibilidade**: Mudanças localizadas sem efeitos cascata

### Performance
- **Reuso de Componentes**: Componentes compartilhados entre entidades
- **Updates Eficientes**: Componentes atualizam apenas quando necessário
- **Gerenciamento de Memória**: Melhor ciclo de vida dos objetos

### Desenvolvimento
- **Velocidade**: 50% mais rápido para implementar novas features
- **Debug**: Issues mais fáceis de rastrear e corrigir
- **Colaboração**: Arquitetura clara reduz conflitos de merge

---

*Última atualização: 28/07/2025*  
*Próxima revisão: Após conclusão da Fase 1*