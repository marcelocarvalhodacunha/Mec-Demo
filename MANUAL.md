# Mec Test Demo — plataforma 2D (Godot 4.7)

Demo com 3 mecânicas: **câmera com limites**, **diálogo letra por letra** e **inventário com Resource**.
Sprites são *placeholders*: jogador = Little RPG Characters (Human Knight); fundo, chão e baús = Kingdom Pixels.

**Controles:** A/D ou setas = mover · ESPAÇO/W/↑ = pular · E = interagir · ENTER = avançar diálogo · TAB = inventário

## Estrutura

```
scenes/                      scripts/
  main.tscn                    main.gd                  liga as peças (poucas linhas)
  actors/player.tscn           actors/player.gd         movimento, pulo, câmera, inventário
  levels/level_01.tscn         levels/level.gd          bounds + ponto de spawn + paredes laterais
  objects/platform.tscn        objects/platform.gd      chão/plataforma redimensionável (@tool)
  objects/chest.tscn           objects/chest.gd         baú (extends Interactable)
							   objects/interactable.gd  base de tudo que usa [E]
							   objects/kill_zone.gd     queda no buraco -> respawn
  ui/hud.tscn                  ui/hud.gd                ajuda, "[E] ..." e avisos
  ui/dialogue_box.tscn         ui/dialogue_box.gd       MECÂNICA 2
  ui/inventory_ui.tscn         ui/inventory_ui.gd       MECÂNICA 3 (tela)
  ui/inventory_slot.tscn       ui/inventory_slot.gd
items/*.tres                 data/item.gd, data/inventory.gd   MECÂNICA 3 (dados)
							 systems/events.gd        AUTOLOAD "Events" (barramento de sinais)
```

**Regra geral:** cada peça cuida de si e conversa pelo autoload `Events` (sinais), sem referência direta
a outras peças. O `Main` só posiciona o jogador, passa os limites à câmera e entrega o inventário à UI.

## Mecânica 1 — Câmera que segue o jogador (Camera2D)
- A `Camera2D` é **filha do `Player`** (`player.tscn`): por herdar a posição, ela o segue sozinha.
- **Suavização:** `position_smoothing_enabled = true` e `position_smoothing_speed = 8` — a câmera "persegue" o jogador em vez de colar nele.
  `limit_smoothed = true` suaviza também quando encosta nos limites. `zoom = 6` faz a tela mostrar 192×108 px de mundo (mesma proporção dos fundos).
- **Limites da fase:** `Level.bounds` (Rect2i, editável no Inspector da fase) é a área jogável.
  No `_ready`, o `Main` chama `player.set_camera_limits(level.bounds)`, que preenche `limit_left/top/right/bottom` da câmera.
  Resultado: a câmera nunca mostra nada fora da fase. O `Level` usa o mesmo `bounds` para criar paredes invisíveis nas laterais.
- **Fundo em camadas (parallax):** `Background` na fase tem 5 `Parallax2D` (imagens do Kingdom Pixels). Cada uma tem `scroll_scale` diferente
  (0.02 céu … 0.75 troncos próximos) e `repeat_size = 192` para repetir infinitamente.
- Para outra fase: duplicar `level_01.tscn`, ajustar `bounds`, plataformas e baús.

## Mecânica 2 — Caixa de diálogo letra por letra (Control + RichTextLabel + visible_characters)
- `dialogue_box.tscn` é um `CanvasLayer` (fica por cima do jogo) com `PanelContainer` (Control) → `SpeakerLabel`, **`RichTextLabel`** (`TextLabel`) e `HintLabel`.
- Quem quer falar emite `Events.dialogue_requested.emit(speaker, lines)` (o baú faz isso). A `DialogueBox` escuta e abre.
- **O efeito:** para cada fala, `visible_characters = 0` (nenhuma letra visível) e um `Tween` anima `visible_characters` até
  `get_total_character_count()` (total de letras; ignora tags BBCode). A duração é `letras × 0.035 s` (`SECONDS_PER_CHAR`).
  Como é `RichTextLabel`, dá para usar BBCode nas falas: `[b]negrito[/b]`, `[color=yellow]cor[/color]`.
- **ENTER (`advance_dialog`):** se ainda está "digitando", mata o Tween e põe `visible_characters = -1` (mostra tudo); se já terminou, vai para a próxima fala.
  Na última, fecha o painel e emite `Events.dialogue_finished` (o baú espera esse sinal com `await` para entregar o item).
- Durante o diálogo, `Events.block_input()` impede o jogador de andar/pular/interagir.

## Mecânica 3 — Inventário simples (Resource personalizado + Controls)
- **`Item` (`data/item.gd`)** é um `Resource` com `item_name`, `description`, `icon`. Cada item é um arquivo `.tres` em `items/`
  — criado/editado só pelo Inspector (clique direito em `items/` → New Resource → Item).
- **`Inventory` (`data/inventory.gd`)** também é um `Resource`: `max_slots`, lista `items`, métodos `add()`, `remove()`, `is_full()` e o sinal `items_changed`.
  Ele só guarda dados; **não desenha nada**. É criado em `player.tscn` (propriedade `inventory` do Player).
- **Como o item chega:** cada `Chest` na fase tem um campo `item` (arrastar um `.tres`). Ao abrir (`E`), o baú mostra as falas,
  espera `dialogue_finished` e chama `player.inventory.add(item)`; se o inventário está cheio, avisa e não abre.
- **Tela:** `InventoryUI` (CanvasLayer → `Control` → `GridContainer`) cria um `InventorySlot` (PanelContainer: ícone + nome) por espaço.
  Ela escuta `inventory.items_changed` e redistribui os itens pelos slots (`_refresh`). TAB abre/fecha (e também trava o jogador).
- Padrão usado: **dados (Resource) separados da apresentação (Controls)** — a UI só observa o sinal.

## Como estender
- **Novo item:** criar `.tres` em `items/` e arrastar para o campo `Item` de um baú.
- **Novo objeto interativo (NPC, alavanca):** criar script `extends Interactable`, sobrescrever `interact(player)` e `get_prompt()`.
- **Nova plataforma:** instanciar `platform.tscn` e mudar `size` no Inspector (visual e colisão acompanham).
- **Ajustar o "feel" do pulo:** grupo *Movimento* no Inspector do Player (velocidade, pulo, coyote time, jump buffer).
