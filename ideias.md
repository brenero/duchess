# Documento de Design de Jogo (GDD) - Duchess (Resumo)
*Última Atualização: 28 de Julho de 2025*

---

## 1. Visão Geral e Filosofia

- **Título (Provisório):** Duchess
- **Gênero:** Plataforma Narrativa com elementos de Coleta e Exploração.
- **Pilar Emocional:** O jogo é um tributo à amizade entre a cachorrinha Duquesa e sua dona, Lívia. Ele explora temas de amor, memória, perda e oferece ao jogador (e à criadora) uma despedida simbólica que não pôde acontecer. A experiência deve ser contemplativa, tocante e, em última análise, reconfortante.

---

## 2. Loop de Gameplay Principal (O Ciclo Híbrido)

O jogador progride no jogo através de um ciclo de exploração e desbloqueio, inspirado em jogos como Kingdom Two Crowns, mas adaptado para uma experiência puramente narrativa.

- **Explorar:** O jogador explora uma área semi-aberta para encontrar um conjunto específico de "Recursos de Memória" (os Brinquedos Perdidos).
- **Coletar:** Utilizando as habilidades da Duquesa (Pulo, Faro, Cavar), o jogador coleta o número necessário de recursos.
- **Desbloquear:** A coleção completa de um conjunto de brinquedos é "entregue" a um ponto central (a Caixa de Brinquedos), que por sua vez remove uma barreira, abrindo caminho para uma nova área linear.
- **Progredir na Narrativa:** Esta nova área linear é uma "Trilha da Memória", uma seção de plataforma focada que leva o jogador a uma Memória principal (uma foto + texto).
- **Repetir:** Após vivenciar a memória, o jogador é apresentado a um novo conjunto de brinquedos a serem encontrados, iniciando um novo ciclo.

---

## 3. Sistemas de Jogo e Objetivos

### Recurso Colecionável: "Brinquedos Perdidos"
- **Função:** Servem como a "moeda" que o jogador usa para desbloquear a progressão.
- **Conjuntos Definidos:**
  - 3x Bolinhas de Tênis
  - 2x Chinelos (o par)
  - 1x Urso de Pelúcia

### Sistema de Desbloqueio: "A Caixa de Brinquedos"
- **Função:** Atua como o "altar" central e o indicador visual de progresso. Localizada em uma área "hub" segura, a caixa exibe quais brinquedos precisam ser encontrados e mostra os que já foram coletados. Completar um conjunto aciona o desbloqueio da próxima Barreira.

### Recompensa Narrativa: "As Memórias"
- **Função:** São os principais marcos da história. Encontradas no final das seções lineares (as "Trilhas da Memória"), elas apresentam ao jogador uma foto e um texto que aprofundam a relação entre Duquesa e Lívia.

---

## 4. Exemplo de Design de Nível: "A Travessia do Riacho"

### Memória Associada
- **"A Memória da Travessura"** (Ex: um dia em que Duquesa quase caiu na água, gerando uma memória de susto e risada).

### Filosofia de Design
A mecânica do nível reflete o tema da memória. O desafio cria uma tensão lúdica e um senso de risco controlado, preparando o jogador para a história que será contada.

### Progressão da Fase
O nível é dividido em três partes para ensinar e testar o jogador de forma natural:

- **Parte 1 (Introdução):** O jogador atravessa troncos estáveis que apenas se movem com a correnteza. O objetivo é aprender a pular em alvos móveis.
- **Parte 2 (Desafio):** O jogador encontra troncos parados que afundam ritmicamente ao serem pisados. O objetivo é aprender a não ficar parado e a se mover com um fluxo constante.
- **Parte 3 (Clímax):** Os últimos troncos antes da Memória movem-se com a correnteza E afundam ao serem pisados. O objetivo é combinar as duas habilidades aprendidas para superar um desafio final emocionante.

### Mecânica de Falha (Soft Punish)
Se a Duquesa cair na água em qualquer ponto, não há "morte" ou "game over". Uma correnteza suave a leva de volta para o início do trecho de plataformas que ela estava tentando atravessar, incentivando uma nova tentativa sem quebrar a imersão.
