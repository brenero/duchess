# 🐕 Duchess - Roadmap de Desenvolvimento
## Jogo Narrativo em Tributo à Duquesa e Lívia

---

## 📖 **Visão Geral do Projeto**

**Duchess** é um jogo narrativo 2D sobre uma cachorrinha Rottweiler que sobe plataformas coletando memórias de sua vida com Lívia. O jogo é um tributo tocante que culmina em uma despedida que nunca puderam ter na vida real.

### **História Central:**
- Lívia ganhou Duquesa aos 4 anos
- Cresceram juntas como melhores amigas
- Aos 15 anos, Lívia mudou de cidade para estudar
- Duquesa faleceu na fazenda e Lívia não pôde se despedir
- O jogo oferece essa despedida através de uma jornada emocional

---

## ✅ **Sistemas Implementados**

### **Core Gameplay**
- [x] Sistema FSM completo da Duquesa (Idle, Run, Air, Bark, Bite, Sniff, Dig)
- [x] Sistema de memórias ordenadas com MemoryManager
- [x] Sistema de dicas direcionais no Sniff (setas e exclamação)
- [x] Coleta automática de memórias em sequência
- [x] Animações progressivas no idle (idle → sit → lie → sleep)

### **Controles**
- [x] Movimento: A/D ou setas
- [x] Pulo: Spacebar
- [x] Sniff: Q (mostra dicas para memórias)
- [x] Bark: F (audio incluído)
- [x] Bite: Shift (com dash)
- [x] Suporte completo a gamepad

---

## 🎯 **Roadmap de Desenvolvimento**

### **FASE 1: Interface e Experiência Narrativa** 🖼️
**Prioridade: ALTA | Prazo: 1-2 semanas**

#### **1.1 Interface de Memórias**
- [ ] Criar UI overlay para exibir memórias coletadas
- [ ] Sistema de fade in/out suave
- [ ] Integração com fotos reais (Texture2D)
- [ ] Textos narrativos para cada memória
- [ ] Botão para continuar (não automático)
- [ ] Efeito de polaroid/moldura vintage

#### **1.2 Sistema de Fotos**
- [ ] Preparar assets das fotos (Lívia + Duquesa)
- [ ] Criar estrutura de dados para memórias narrativas
- [ ] Sistema de legendas contextuais
- [ ] Ordem cronológica das memórias (4 anos → 15 anos)

#### **1.3 Melhorias UX**
- [ ] Indicador de progresso das memórias (X/Total)
- [ ] Tutorial visual para controles
- [ ] Feedback visual quando memória é descoberta
- [ ] Sistema de pausar memórias (se necessário)

---

### **FASE 2: Level Design e Ambientação** 🏔️
**Prioridade: ALTA | Prazo: 2-3 semanas**

#### **2.1 Design do Nível Principal**
- [ ] Criar layout vertical das plataformas (fazenda → céu)
- [ ] Posicionamento estratégico das memórias
- [ ] Plataformas temáticas (casa, quintal, campo, nuvens)
- [ ] Sistemas de checkpoints invisíveis

#### **2.2 Sistema de Background Progressivo**
- [ ] ParallaxBackground com múltiplas camadas
- [ ] Transição gradual: fazenda → campo → céu → estrelas
- [ ] Sistema de altura que altera ambiente
- [ ] Iluminação que muda conforme altura

#### **2.3 Ambiente Interativo**
- [ ] Elementos de cenário que reagem à Duquesa
- [ ] Flores que balançam, grama que move
- [ ] Pássaros ou borboletas decorativas
- [ ] Sistema de dia/noite baseado na altura

---

### **FASE 3: Audio Design Emocional** 🎵
**Prioridade: MÉDIA | Prazo: 1-2 semanas**

#### **3.1 Trilha Sonora**
- [ ] Música de fundo melancólica mas esperançosa
- [ ] Variações da música baseadas na altura/progresso
- [ ] Tema musical único para cena final
- [ ] Sistema de fade entre tracks

#### **3.2 Efeitos Sonoros**
- [ ] SFX para coleta de memórias (som carinhoso)
- [ ] Sons ambiente (vento, folhas, pássaros)
- [ ] Melhoria nos sons de latido (mais emotivos)
- [ ] Sons de passos na grama/terra

#### **3.3 Audio Implementação**
- [ ] AudioStreamPlayer2D para sons posicionais
- [ ] Sistema de volume dinâmico
- [ ] Configurações de audio acessíveis

---

### **FASE 4: Cena Final e Narrativa** 💕
**Prioridade: ALTA | Prazo: 2-3 semanas**

#### **4.1 Encontro Final**
- [ ] Cena do topo da jornada (entre as estrelas)
- [ ] Aparição da Lívia (sprite ou silhueta)
- [ ] Sistema de cutscene controlado
- [ ] Transição cinematográfica

#### **4.2 Diálogo de Despedida**
- [ ] Sistema de texto emotional
- [ ] Falas da Lívia (texto ou voiceover)
- [ ] Opções de interação da Duquesa
- [ ] Timing emocional apropriado

#### **4.3 Final Emotivo**
- [ ] Animação da despedida
- [ ] Efeito visual da Duquesa "partindo"
- [ ] Transição para constelação/estrela
- [ ] Créditos com fotos reais (se possível)

---

### **FASE 5: Polish e Refinamento** ✨
**Prioridade: MÉDIA | Prazo: 1-2 semanas**

#### **5.1 Efeitos Visuais**
- [ ] Sistema de partículas para memórias
- [ ] Glow effects e iluminação atmosférica
- [ ] Animações de transição mais suaves
- [ ] Efeitos de vento e movimento

#### **5.2 Balanceamento de Gameplay**
- [ ] Ajuste de dificuldade das plataformas
- [ ] Velocidade ideal de movimento
- [ ] Distâncias ótimas para descoberta de memórias
- [ ] Fluidez da jornada narrativa

#### **5.3 Acessibilidade**
- [ ] Opções de volume e controles
- [ ] Suporte para diferentes resoluções
- [ ] Modo daltônico (se necessário)
- [ ] Instruções claras e intuitivas

---

### **FASE 6: Conteúdo e Expansão** 📚
**Prioridade: BAIXA | Prazo: Opcional**

#### **6.1 Memórias Extras**
- [ ] Sistema de memórias opcionais/secretas
- [ ] Histórias paralelas da vida na fazenda
- [ ] Easter eggs carinhosos
- [ ] Múltiplos finais (se apropriado)

#### **6.2 Modo Foto**
- [ ] Captura de screenshots das memórias
- [ ] Álbum de fotos coletadas
- [ ] Sharing de momentos especiais

---

## 🎮 **Considerações Técnicas**

### **Performance**
- Manter 60 FPS estável
- Otimizar texturas para diferentes dispositivos
- Sistema de loading suave entre seções

### **Compatibilidade**
- PC (Windows/Linux/Mac)
- Possível port para mobile (futuro)
- Suporte a múltiplas resoluções

### **Arquitetura de Código**
- Manter sistema FSM modular
- Documentar todas as funcionalidades narrativas
- Sistema de save/load para progresso

---

## 📝 **Notas de Desenvolvimento**

### **Filosofia do Projeto**
- **Emoção sobre mecânica**: Cada sistema deve servir à narrativa
- **Simplicidade elegante**: Controles fáceis, impacto emocional profundo
- **Respeito à história**: Cada elemento deve honrar a memória real

### **Público-Alvo**
- Pessoas que perderam pets queridos
- Amantes de jogos narrativos indie
- Quem aprecia histórias tocantes e sinceras

### **Sucesso do Projeto**
O jogo será considerado bem-sucedido se conseguir:
1. Emocionar genuinamente os jogadores
2. Oferecer uma experiência de closure/despedida
3. Honrar apropriadamente a memória da Duquesa real

---

## 🚀 **Próximos Passos Imediatos**

1. **[EM PROGRESSO]** Implementar Interface de Memórias
2. **[PLANEJADO]** Preparar assets das fotos reais
3. **[PLANEJADO]** Criar textos narrativos para cada memória
4. **[FUTURO]** Level design da jornada vertical

---

*"Para todas as despedidas que não pudemos dar... 🐕💕"*

**Última atualização:** 28 de Janeiro de 2025  
**Versão do Roadmap:** 1.0