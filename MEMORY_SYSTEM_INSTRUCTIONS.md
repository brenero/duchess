# Sistema de Memórias - Instruções de Uso

## Como usar o sistema de memórias ordenadas com dicas direcionais:

### 1. Configurar o MemoryManager na sua cena principal

1. Na cena onde você quer usar o sistema (ex: main.tscn), adicione um nó Node chamado "MemoryManager"
2. Adicione o script `memory_manager.gd` a este nó
3. No Inspector, vá em `Groups` e adicione o nó ao grupo "memory_manager"

### 2. Adicionar memórias à sua cena

1. Para cada memória que você quer na fase, instancie a cena `memoria.tscn`
2. Posicione as memórias onde você quiser na fase
3. Configure as propriedades de cada memória no Inspector:
   - `Memory Title`: Título da lembrança
   - `Memory Description`: Descrição da lembrança
   - `Memory Photo`: Textura da foto (se você tiver)
   - `Discovery Distance`: Distância para mostrar exclamação (padrão: 32px)

### 3. Configurar a ordem das memórias

1. Selecione o nó MemoryManager
2. No Inspector, encontre a propriedade "Ordered Memories"
3. Defina o tamanho do array (quantas memórias você tem)
4. Arraste e solte os nós das memórias da árvore de cena para os campos do array, na ordem que você quer

### 4. Como funciona o sistema de dicas

Quando a Duquesa usa o **Sniff** (tecla Q):

- **Seta para direita** ➡️ : A próxima memória está à direita
- **Seta para esquerda** ⬅️ : A próxima memória está à esquerda  
- **Exclamação** ❗ : Você está muito próximo da memória (dentro da discovery_distance)

### 5. Como coletar memórias

1. Use **Sniff** (Q) para ver as dicas direcionais
2. Siga as setas para encontrar a memória
3. Quando aparecer a exclamação, você está próximo
4. **Caminhe até a memória** para coletá-la automaticamente
5. O sistema avança automaticamente para a próxima memória na ordem

### 6. Configurações disponíveis

**No SniffState (Inspector da Duquesa > StateMachine > Sniff):**
- `Discovery Distance`: Distância para mostrar exclamação (padrão: 48px)
- `Hint Update Rate`: Frequência de atualização das dicas (padrão: 0.1s)

**Na Memoria (Inspector de cada memória):**
- `Memory Title`: Título da lembrança
- `Memory Description`: Descrição da lembrança
- `Memory Photo`: Foto da lembrança (Texture2D)
- `Discovery Distance`: Distância específica desta memória

### 7. Eventos disponíveis

O MemoryManager emite signals que você pode conectar:

```gdscript
# Quando uma memória é coletada
memory_manager.memory_collected.connect(_on_memory_collected)

# Quando todas as memórias foram coletadas
memory_manager.all_memories_collected.connect(_on_all_memories_collected)
```

### 8. Exemplo de uso

```gdscript
# Verificar progresso das memórias
var progress = memory_manager.get_progress()
print("Coletadas: ", progress.collected, "/", progress.total)
print("Porcentagem: ", progress.percentage, "%")

# Verificar se ainda há memórias
if memory_manager.has_memories_remaining():
    print("Ainda há memórias para coletar!")

# Resetar progresso (útil para restart)
memory_manager.reset_progress()
```

### 9. Notas importantes

- As memórias devem ser coletadas **em ordem**
- Apenas a próxima memória da lista será mostrada nas dicas
- As memórias ficam invisíveis até serem descobertas pelo Sniff
- O sistema funciona apenas quando a Duquesa está no chão (não no ar)
- As dicas são atualizadas automaticamente enquanto você faz Sniff