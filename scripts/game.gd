extends Node2D

class VirtualStick extends Control:
 signal vector_changed(value: Vector2)
 var active := false
 var axis := Vector2.ZERO
 func _ready() -> void:
  mouse_filter = Control.MOUSE_FILTER_STOP
  custom_minimum_size = Vector2(152,152)
 func _gui_input(event: InputEvent) -> void:
  if event is InputEventScreenTouch:
   active = event.pressed
   axis = _axis_from(event.position) if active else Vector2.ZERO
   vector_changed.emit(axis)
   queue_redraw()
  elif event is InputEventScreenDrag and active:
   axis = _axis_from(event.position)
   vector_changed.emit(axis)
   queue_redraw()
  elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
   active = event.pressed
   axis = _axis_from(event.position) if active else Vector2.ZERO
   vector_changed.emit(axis)
   queue_redraw()
  elif event is InputEventMouseMotion and active:
   axis = _axis_from(event.position)
   vector_changed.emit(axis)
   queue_redraw()
 func _axis_from(point: Vector2) -> Vector2:
  var value := (point - size * 0.5) / 54.0
  return value.limit_length(1.0)
 func _draw() -> void:
  var center := size * 0.5
  draw_circle(center,67,Color(0.025,0.055,0.075,0.72))
  draw_arc(center,67,0.0,TAU,48,Color(0.45,0.83,0.9,0.8),3.0,true)
  draw_circle(center,43,Color(0.15,0.28,0.32,0.45))
  draw_circle(center + axis * 39.0,25,Color(0.34,0.78,0.83,0.9))
  draw_arc(center + axis * 39.0,25,0.0,TAU,32,Color(0.82,0.97,0.94,0.95),2.0,true)

const SAVE_PATH := "user://aetherion_save.json"
const SPRITE_ATLAS: Texture2D = preload("res://assets/aetherion_sprites.svg")
const WORLD_TEXTURE: Texture2D = preload("res://assets/aetherion_world.svg")
const WORLD_SIZE := Vector2(1920, 1440)
const START_POS := Vector2(480, 380)
const RUINS_POS := Vector2(1600, 720)
const RACES := {
 "Terranie":{"hp":125,"ep":90,"atk":13,"def":5},
 "Varkari":{"hp":140,"ep":100,"atk":15,"def":4},
 "Elarianie":{"hp":105,"ep":135,"atk":12,"def":3},
 "Sylvari":{"hp":130,"ep":110,"atk":11,"def":6},
 "Noctari":{"hp":112,"ep":120,"atk":14,"def":3}
}
const ENEMY_NAMES := ["Dzik Eterowy","Strażnik Ruin","Pęknięty Łowca","Golem Odłamków"]
const ENEMY_COLORS := [Color("#a96b48"),Color("#8c9b9e"),Color("#684f87"),Color("#777b83")]
var race := "Varkari"
var player_pos := START_POS
var player_facing := Vector2.DOWN
var walk_phase := 0.0
var held := {"left":false,"right":false,"up":false,"down":false}
var hp := 140.0
var max_hp := 140.0
var ether := 100.0
var max_ether := 100.0
var level := 1
var xp := 0
var gold := 25
var atk := 15
var defense := 4
var transformed := false
var transform_left := 0.0
var transform_cd := 0.0
var attack_cd := 0.0
var attack_anim := 0.0
var attack_angle := 0.0
var attack_target := Vector2.ZERO
var skill_cd := 0.0
var skill_anim := 0.0
var quest := 0
var kills := 0
var inventory := {"Mikstura HP":3,"Odłamek Eterium":0,"Skóra bestii":0}
var equipment := {"Broń":"Ostrze Wędrowca","Pancerz":"Tunika Wędrowca"}
var owned_gear: Array[String] = ["Ostrze Wędrowca","Tunika Wędrowca"]
const GEAR_STATS := {
 "Ostrze Wędrowca":{"slot":"Broń","atk":0,"def":0,"hp":0},
 "Tunika Wędrowca":{"slot":"Pancerz","atk":0,"def":0,"hp":0},
 "Ostrze Eterium":{"slot":"Broń","atk":7,"def":0,"hp":0},
 "Pancerz Łowcy":{"slot":"Pancerz","atk":0,"def":4,"hp":30}
}
var boss_spawned := false
var boss_defeated := false
var autosave_timer := 0.0
var enemies: Array[Dictionary] = []
var loot_drops: Array[Dictionary] = []
var damage_numbers: Array[Dictionary] = []
var started := false
var rng := RandomNumberGenerator.new()
var camera: Camera2D
var ui: CanvasLayer
var status: Label
var hp_bar: ProgressBar
var ether_bar: ProgressBar
var action_buttons: Array[Button] = []
var quest_label: Label
var msg: Label
var panel: PanelContainer
var virtual_stick: VirtualStick
var bolt_cd := 0.0
var bolt_anim := 0.0
var dash_cd := 0.0
var dash_anim := 0.0
var dash_from := Vector2.ZERO
var dash_to := Vector2.ZERO
var player_hit_flash := 0.0
var ambient_particles: Array[Dictionary] = []
var ambient_time := 0.0

func _ready() -> void:
 rng.randomize()
 _init_ambient_particles()
 _spawn_enemies()
 _build_ui()
 _show_race_select()
 camera = Camera2D.new()
 camera.position = START_POS
 camera.position_smoothing_enabled = true
 camera.position_smoothing_speed = 7.0
 camera.limit_left = 0
 camera.limit_top = 0
 camera.limit_right = int(WORLD_SIZE.x)
 camera.limit_bottom = int(WORLD_SIZE.y)
 add_child(camera)
 camera.make_current()

func _spawn_enemies() -> void:
 for i in range(18):
  var enemy_hp := 42.0 + float(i % 4) * 13.0
  enemies.append({"name":ENEMY_NAMES[i%4],"pos":Vector2(rng.randf_range(90,1830),rng.randf_range(90,1350)),"hp":enemy_hp,"max_hp":enemy_hp,"damage":7.0+float(i%4)*2.0,"speed":42.0+float(i%4)*8.0,"alive":true,"type":i%4,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.52,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN})

func _build_ui() -> void:
 ui = CanvasLayer.new()
 add_child(ui)
 var root := Control.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 ui.add_child(root)
 var left := VBoxContainer.new()
 left.position = Vector2(12,8)
 left.custom_minimum_size = Vector2(390,105)
 root.add_child(left)
 status = Label.new()
 status.add_theme_font_size_override("font_size",16)
 left.add_child(status)
 hp_bar = _create_hud_bar(left,Color("#e45b69"))
 ether_bar = _create_hud_bar(left,Color("#55c9df"))
 quest_label = Label.new()
 quest_label.add_theme_font_size_override("font_size",14)
 left.add_child(quest_label)
 msg = Label.new()
 msg.modulate = Color(1,0.85,0.45)
 msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 left.add_child(msg)
 var right := VBoxContainer.new()
 right.set_anchors_preset(Control.PRESET_TOP_RIGHT)
 right.position = Vector2(-150,10)
 root.add_child(right)
 _button(right,"POSTAĆ",func(): _show_panel("Postać"))
 _button(right,"TORBA",func(): _show_panel("Ekwipunek"))
 _button(right,"SKILLE",func(): _show_panel("Umiejętności"))
 _button(right,"RZEMIOSŁO",func(): _show_panel("Rzemiosło"))
 _button(right,"MAPA",func(): _show_panel("Mapa"))
 _button(right,"KODEKS",func(): _show_panel("Kodeks"))
 _button(right,"ZADANIE",_quest_interact)
 _button(right,"ZAPISZ",_save_game)
 _button(right,"WCZYTAJ",_load_game)
 virtual_stick = VirtualStick.new()
 virtual_stick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
 virtual_stick.position = Vector2(18,-174)
 virtual_stick.size = Vector2(152,152)
 virtual_stick.vector_changed.connect(_on_virtual_stick)
 root.add_child(virtual_stick)
 var bottom := HBoxContainer.new()
 bottom.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
 bottom.position = Vector2(-520,-72)
 bottom.size = Vector2(510,62)
 bottom.alignment = BoxContainer.ALIGNMENT_END
 bottom.add_theme_constant_override("separation",6)
 root.add_child(bottom)
 action_buttons.clear()
 action_buttons.append(_button(bottom,"⚔\\nATAK",_attack,70,62))
 action_buttons.append(_button(bottom,"✦\\nFALA",_skill,70,62))
 action_buttons.append(_button(bottom,"◎\\nPROMIEŃ",_skill_bolt,78,62))
 action_buttons.append(_button(bottom,"➤\\nSZARŻA",_skill_dash,74,62))
 action_buttons.append(_button(bottom,"✧\\nFORMA",_transform,70,62))
 action_buttons.append(_button(bottom,"+\\nHP",_potion,66,62))
 panel = PanelContainer.new()
 panel.set_anchors_preset(Control.PRESET_CENTER)
 panel.position = Vector2(-205,-145)
 panel.custom_minimum_size = Vector2(410,290)
 var panel_style := StyleBoxFlat.new()
 panel_style.bg_color = Color(0.035,0.065,0.105,0.96)
 panel_style.border_color = Color("#75c6cf")
 panel_style.set_border_width_all(2)
 panel_style.set_corner_radius_all(18)
 panel_style.shadow_color = Color(0,0,0,0.62)
 panel_style.shadow_size = 14
 panel_style.content_margin_left = 16
 panel_style.content_margin_right = 16
 panel_style.content_margin_top = 14
 panel_style.content_margin_bottom = 14
 panel.add_theme_stylebox_override("panel",panel_style)
 root.add_child(panel)
 panel.hide()

func _create_hud_bar(parent: Node, fill_color: Color) -> ProgressBar:
 var bar := ProgressBar.new()
 bar.custom_minimum_size = Vector2(245,13)
 bar.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
 bar.show_percentage = false
 var background := StyleBoxFlat.new()
 background.bg_color = Color("#101722")
 background.border_color = Color("#617487")
 background.set_border_width_all(1)
 background.set_corner_radius_all(5)
 var fill := StyleBoxFlat.new()
 fill.bg_color = fill_color
 fill.set_corner_radius_all(4)
 bar.add_theme_stylebox_override("background",background)
 bar.add_theme_stylebox_override("fill",fill)
 parent.add_child(bar)
 return bar

func _button(parent: Node, label_text: String, callback: Callable, w: float=132.0, h: float=36.0) -> Button:
 var button := Button.new()
 button.text = label_text
 button.custom_minimum_size = Vector2(w,h)
 button.add_theme_font_size_override("font_size",15 if h >= 55 else 14)
 button.add_theme_color_override("font_color",Color("#eaf7ff"))
 button.add_theme_color_override("font_hover_color",Color("#ffffff"))
 button.add_theme_color_override("font_pressed_color",Color("#b9f6ef"))
 button.add_theme_color_override("font_disabled_color",Color("#718391"))
 button.tooltip_text = label_text.replace("\\n"," — ")
 var normal := StyleBoxFlat.new()
 normal.bg_color = Color("#101c2b")
 normal.border_color = Color("#67b9c5")
 normal.set_border_width_all(2)
 normal.set_corner_radius_all(13)
 normal.shadow_color = Color(0,0,0,0.48)
 normal.shadow_size = 6
 var hover := normal.duplicate()
 hover.bg_color = Color("#23465c")
 hover.border_color = Color("#b5f5ef")
 var pressed := normal.duplicate()
 pressed.bg_color = Color("#08111d")
 pressed.border_color = Color("#f4cf7b")
 button.add_theme_stylebox_override("normal",normal)
 button.add_theme_stylebox_override("hover",hover)
 button.add_theme_stylebox_override("pressed",pressed)
 button.add_theme_stylebox_override("focus",hover)
 button.pressed.connect(callback)
 parent.add_child(button)
 return button

func _move_button(parent: Node, label_text: String, direction: String) -> void:
 var button := Button.new()
 button.text = label_text
 button.custom_minimum_size = Vector2(48,54)
 button.button_down.connect(func(): held[direction] = true)
 button.button_up.connect(func(): held[direction] = false)
 parent.add_child(button)

func _clear_panel() -> void:
 for child in panel.get_children():
  child.queue_free()

func _show_race_select() -> void:
 panel.custom_minimum_size = Vector2(900, 450)
 panel.position = Vector2(-450, -225)
 panel.show()
 var box := VBoxContainer.new()
 box.add_theme_constant_override("separation", 12)
 panel.add_child(box)
 var title := Label.new()
 title.text = "AETHERION  /  WYBIERZ SWOJE PRZEZNACZENIE"
 title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 title.add_theme_font_size_override("font_size",24)
 title.add_theme_color_override("font_color",Color("#f4dfb0"))
 box.add_child(title)
 var subtitle := Label.new()
 subtitle.text = "Pięć ras. Pięć ścieżek mocy. Jedna wyprawa."
 subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 subtitle.add_theme_font_size_override("font_size",14)
 subtitle.add_theme_color_override("font_color",Color("#a9cbd7"))
 box.add_child(subtitle)
 var cards := HBoxContainer.new()
 cards.add_theme_constant_override("separation", 10)
 cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 box.add_child(cards)
 var descriptions := ["Wszechstronni wojownicy","Nieustępliwi berserkerzy","Mistrzowie energii","Zwinni strażnicy natury","Władcy mocy cienia"]
 for index in range(RACES.size()):
  var race_name := str(RACES.keys()[index])
  var stats: Dictionary = RACES[race_name]
  var card := PanelContainer.new()
  card.custom_minimum_size = Vector2(166, 310)
  var style := StyleBoxFlat.new()
  style.bg_color = Color("#101e30")
  style.border_color = Color("#41677d")
  style.set_border_width_all(1)
  style.set_corner_radius_all(12)
  card.add_theme_stylebox_override("panel", style)
  cards.add_child(card)
  var content := VBoxContainer.new()
  content.add_theme_constant_override("separation", 5)
  card.add_child(content)
  var portrait := TextureRect.new()
  var portrait_atlas := AtlasTexture.new()
  portrait_atlas.atlas = SPRITE_ATLAS
  portrait_atlas.region = Rect2(index * 128, 0, 128, 128)
  portrait.texture = portrait_atlas
  portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  portrait.custom_minimum_size = Vector2(145, 145)
  content.add_child(portrait)
  var name_label := Label.new()
  name_label.text = race_name.to_upper()
  name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  name_label.add_theme_font_size_override("font_size",17)
  name_label.add_theme_color_override("font_color",Color("#f2dfb5"))
  content.add_child(name_label)
  var desc := Label.new()
  desc.text = descriptions[index]
  desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  desc.add_theme_font_size_override("font_size",11)
  desc.add_theme_color_override("font_color",Color("#9bb7c9"))
  content.add_child(desc)
  var stats_label := Label.new()
  stats_label.text = "HP %d   ET %d\\nATAK %d   OBR %d" % [stats["hp"],stats["ep"],stats["atk"],stats["def"]]
  stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  stats_label.add_theme_font_size_override("font_size",12)
  content.add_child(stats_label)
  _button(content,"WYBIERZ",func(): _start_game(race_name),142,36)

func _start_game(selected_race: String) -> void:
 race = selected_race
 var stats: Dictionary = RACES[race]
 max_hp = stats["hp"]
 hp = max_hp
 max_ether = stats["ep"]
 ether = max_ether
 atk = stats["atk"]
 defense = stats["def"]
 started = true
 _clear_panel()
 panel.hide()
 _say("Witaj w Aetherion. Przyjmij zadanie u Kronikarza przy Kamiennym Kręgu.")
 _update_hud()

func _process(delta: float) -> void:
 if not started: return
 autosave_timer += delta
 if autosave_timer >= 30.0:
  autosave_timer = 0.0
  _save_game(true)
 attack_cd = maxf(0.0,attack_cd-delta)
 attack_anim = maxf(0.0,attack_anim-delta)
 skill_cd = maxf(0.0,skill_cd-delta)
 skill_anim = maxf(0.0,skill_anim-delta)
 bolt_cd = maxf(0.0,bolt_cd-delta)
 bolt_anim = maxf(0.0,bolt_anim-delta)
 dash_cd = maxf(0.0,dash_cd-delta)
 player_hit_flash = maxf(0.0,player_hit_flash-delta)
 dash_anim = maxf(0.0,dash_anim-delta)
 if dash_anim > 0.0:
  player_pos = dash_from.lerp(dash_to,1.0-dash_anim/0.32)
 transform_cd = maxf(0.0,transform_cd-delta)
 if transformed:
  transform_left -= delta
  ether = maxf(0.0,ether-4.0*delta)
  if transform_left <= 0.0 or ether <= 0.0:
   transformed = false
   _say("Przebudzenie wygasło.")
 var direction := Vector2.ZERO
 if held["left"] or Input.is_action_pressed("ui_left"): direction.x -= 1.0
 if held["right"] or Input.is_action_pressed("ui_right"): direction.x += 1.0
 if held["up"] or Input.is_action_pressed("ui_up"): direction.y -= 1.0
 if held["down"] or Input.is_action_pressed("ui_down"): direction.y += 1.0
 if direction.length() > 1.0: direction = direction.normalized()
 ambient_time += delta
 _update_ambient_particles(delta)
 if direction != Vector2.ZERO:
  player_facing = direction
  walk_phase += delta * 11.0
  player_pos += direction * (205.0 if transformed else 165.0) * delta
 player_pos.x = clampf(player_pos.x,24.0,WORLD_SIZE.x-24.0)
 player_pos.y = clampf(player_pos.y,24.0,WORLD_SIZE.y-24.0)
 camera.position = player_pos
 for i in range(enemies.size()):
  var enemy := enemies[i]
  if not enemy["alive"]:
   if bool(enemy.get("is_boss",false)):
    enemies[i] = enemy
    continue
   enemy["respawn"] += delta
   if enemy["respawn"] >= 18.0:
    enemy["alive"] = true
    enemy["hp"] = enemy["max_hp"]
    enemy["pos"] = Vector2(rng.randf_range(90,1830),rng.randf_range(90,1350))
    enemy["timer"] = 0.0
    enemy["windup"] = 0.0
    enemy["windup_total"] = 0.52
    enemy["respawn"] = 0.0
   enemies[i] = enemy
   continue
  enemy["attack_anim"] = maxf(0.0,float(enemy.get("attack_anim",0.0))-delta)
  enemy["hit_flash"] = maxf(0.0,float(enemy.get("hit_flash",0.0))-delta)
  var difference: Vector2 = player_pos - enemy["pos"]
  var is_boss := bool(enemy.get("is_boss",false))
  var attack_range := 112.0 if is_boss else 48.0
  var windup := float(enemy.get("windup",0.0))
  if windup > 0.0:
   windup = maxf(0.0,windup-delta)
   enemy["windup"] = windup
   if windup <= 0.0 and player_pos.distance_to(enemy["pos"]) <= attack_range:
    enemy["attack_anim"] = 0.34
    if dash_anim <= 0.0:
     player_hit_flash = 0.18
     hp -= maxf(2.0,enemy["damage"]-float(defense))
     if hp <= 0.0:
      hp = max_hp
      player_pos = START_POS
      gold = maxi(0,gold-8)
      _say("Odrodzenie przy kręgu. Utracono 8 złota.")
    else:
     _say("Uniknięto ataku dzięki Szarży!")
  elif difference.length() < 300.0 and difference.length() > attack_range:
   enemy["facing"] = difference.normalized()
   enemy["walk_phase"] = float(enemy.get("walk_phase",0.0)) + delta * 9.0
   enemy["pos"] += difference.normalized() * enemy["speed"] * delta
  elif difference.length() <= attack_range and windup <= 0.0:
   enemy["facing"] = difference.normalized()
   enemy["timer"] += delta
   if enemy["timer"] > 1.3:
    enemy["timer"] = 0.0
    enemy["windup"] = 0.82 if is_boss else 0.52
    enemy["windup_total"] = enemy["windup"]
  else:
   enemy["timer"] = maxf(0.0,float(enemy.get("timer",0.0))-delta*0.5)
  enemies[i] = enemy
 for i in range(damage_numbers.size()-1,-1,-1):
  var number: Dictionary = damage_numbers[i]
  number["life"] = float(number["life"]) - delta
  var number_pos: Vector2 = number["pos"]
  number["pos"] = number_pos + Vector2(0,-34.0*delta)
  if float(number["life"]) <= 0.0:
   damage_numbers.remove_at(i)
  else:
   damage_numbers[i] = number
 for i in range(loot_drops.size()-1,-1,-1):
  var drop: Dictionary = loot_drops[i]
  drop["life"] = float(drop.get("life",60.0)) - delta
  if player_pos.distance_to(drop["pos"]) <= 42.0:
   var item_name := str(drop["item"])
   inventory[item_name] = int(inventory.get(item_name,0)) + 1
   _say("Zebrano: %s" % item_name)
   loot_drops.remove_at(i)
  elif float(drop["life"]) <= 0.0:
   loot_drops.remove_at(i)
  else:
   loot_drops[i] = drop
 _update_hud()
 queue_redraw()

func _init_ambient_particles() -> void:
 ambient_particles.clear()
 for i in range(118):
  var x := rng.randf_range(24.0,WORLD_SIZE.x-24.0)
  var y := rng.randf_range(24.0,WORLD_SIZE.y-24.0)
  var tint := Color("#9df4df")
  if y < 470.0 and x > 1180.0:
   tint = Color("#c8eaff")
  elif y > 900.0 and x < 820.0:
   tint = Color("#ffe0a0")
  elif y > 850.0 and x > 1260.0:
   tint = Color("#ffad82")
  elif x > 930.0 and x < 1320.0:
   tint = Color("#8deeff")
  ambient_particles.append({
   "pos":Vector2(x,y),
   "velocity":Vector2(rng.randf_range(-5.0,5.0),rng.randf_range(-13.0,-3.0)),
   "size":rng.randf_range(1.0,2.8),
   "phase":rng.randf_range(0.0,TAU),
   "tint":tint
  })

func _update_ambient_particles(delta: float) -> void:
 for i in range(ambient_particles.size()):
  var mote: Dictionary = ambient_particles[i]
  var position: Vector2 = mote["pos"]
  var velocity: Vector2 = mote["velocity"]
  position += velocity * delta
  position.x += sin(ambient_time*0.7+float(mote["phase"]))*3.0*delta
  if position.y < 12.0:
   position.y = WORLD_SIZE.y-12.0
   position.x = rng.randf_range(24.0,WORLD_SIZE.x-24.0)
  if position.x < 12.0:
   position.x = WORLD_SIZE.x-12.0
  elif position.x > WORLD_SIZE.x-12.0:
   position.x = 12.0
  mote["pos"] = position
  ambient_particles[i] = mote

func _draw_ambient_particles() -> void:
 for mote in ambient_particles:
  var phase := float(mote["phase"])
  var pulse := 0.35+0.3*(0.5+0.5*sin(ambient_time*2.1+phase))
  var position: Vector2 = mote["pos"]
  var size := float(mote["size"])
  var tint: Color = mote["tint"]
  draw_circle(position,size*4.0,Color(tint.r,tint.g,tint.b,pulse*0.10))
  draw_circle(position,size,Color(tint.r,tint.g,tint.b,pulse*0.72))

func _on_virtual_stick(value: Vector2) -> void:
 held["left"] = value.x < -0.18
 held["right"] = value.x > 0.18
 held["up"] = value.y < -0.18
 held["down"] = value.y > 0.18

func _nearest_enemy(max_distance: float) -> int:
 var best := -1
 var nearest := max_distance
 for i in range(enemies.size()):
  var enemy := enemies[i]
  if enemy["alive"] and player_pos.distance_to(enemy["pos"]) < nearest:
   nearest = player_pos.distance_to(enemy["pos"])
   best = i
 return best

func _attack() -> void:
 if not started or attack_cd > 0.0: return
 attack_cd = 0.45
 var index := _nearest_enemy(105.0)
 if index < 0:
  _say("Brak celu w zasięgu.")
  return
 var enemy := enemies[index]
 player_facing = (enemy["pos"]-player_pos).normalized()
 attack_angle = player_facing.angle()
 attack_target = enemy["pos"]
 attack_anim = 0.24
 enemy["hit_flash"] = 0.18
 enemy["pos"] += player_facing * 9.0
 var damage := atk + (8 if transformed else 0)
 _spawn_damage_number(enemy["pos"],damage,transformed)
 enemy["hp"] -= damage
 if enemy["hp"] <= 0.0: _kill_enemy(index)
 else: enemies[index] = enemy

func _skill() -> void:
 if not started or skill_cd > 0.0: return
 if ether < 20.0:
  _say("Za mało Eterium.")
  return
 ether -= 20.0
 skill_cd = 4.0
 skill_anim = 0.72
 for i in range(enemies.size()):
  var enemy := enemies[i]
  if enemy["alive"] and player_pos.distance_to(enemy["pos"]) < 170.0:
   enemy["hit_flash"] = 0.18
   enemy["pos"] += (enemy["pos"]-player_pos).normalized() * 7.0
   _spawn_damage_number(enemy["pos"],atk*2,false)
   enemy["hp"] -= atk * 2
   if enemy["hp"] <= 0.0: _kill_enemy(i)
   else: enemies[i] = enemy
 _say("Technika Eterium!")

func _skill_bolt() -> void:
 if not started or bolt_cd > 0.0:
  return
 if ether < 28.0:
  _say("Za mało Eterium na Promień.")
  return
 var index := _nearest_enemy(285.0)
 if index < 0:
  _say("Brak celu dla Promienia.")
  return
 ether -= 28.0
 bolt_cd = 6.0
 bolt_anim = 0.38
 var enemy := enemies[index]
 player_facing = (enemy["pos"]-player_pos).normalized()
 attack_target = enemy["pos"]
 enemy["hit_flash"] = 0.2
 enemy["pos"] += (enemy["pos"]-player_pos).normalized() * 12.0
 var damage := atk * 3 + (18 if transformed else 0)
 _spawn_damage_number(enemy["pos"],damage,true)
 enemy["hp"] -= damage
 if enemy["hp"] <= 0.0:
  _kill_enemy(index)
 else:
  enemies[index] = enemy
 _say("PROMIEŃ ETERIUM!")

func _skill_dash() -> void:
 if not started or dash_cd > 0.0:
  return
 if ether < 16.0:
  _say("Za mało Eterium na Szarżę.")
  return
 var index := _nearest_enemy(310.0)
 if index < 0:
  _say("Brak celu dla Szarży.")
  return
 var enemy: Dictionary = enemies[index]
 var direction: Vector2 = (enemy["pos"] - player_pos).normalized()
 dash_from = player_pos
 dash_to = enemy["pos"] - direction * 58.0
 player_facing = direction
 dash_anim = 0.32
 dash_cd = 5.0
 ether -= 16.0
 enemy["hit_flash"] = 0.22
 enemy["pos"] += direction * 14.0
 var damage := int(atk * 2.4 + (12 if transformed else 0))
 _spawn_damage_number(enemy["pos"],damage,true)
 enemy["hp"] -= damage
 if enemy["hp"] <= 0.0:
  _kill_enemy(index)
 else:
  enemies[index] = enemy
 _say("SZARŻA ETERYCZNA!")

func _transform() -> void:
 if not started: return
 if transformed:
  transformed = false
  return
 if transform_cd > 0.0 or ether < 28.0:
  _say("Transformacja niedostępna.")
  return
 ether -= 28.0
 transformed = true
 transform_left = 16.0
 transform_cd = 32.0
 _say("PRZEBUDZENIE RDZENIA!")

func _potion() -> void:
 if not started: return
 if inventory["Mikstura HP"] <= 0:
  _say("Brak mikstur.")
  return
 inventory["Mikstura HP"] -= 1
 hp = minf(max_hp,hp+60.0)
 _say("Użyto mikstury.")

func _spawn_damage_number(position: Vector2, amount: int, empowered: bool) -> void:
 damage_numbers.append({"pos":position+Vector2(rng.randf_range(-8.0,8.0),-26.0),"amount":amount,"life":0.82,"empowered":empowered})

func _grant_xp(amount: int) -> void:
 if amount <= 0:
  return
 xp += amount
 while xp >= level * 100:
  xp -= level * 100
  level += 1
  max_hp += 10
  max_ether += 7
  atk += 2
  defense += 1
  hp = max_hp
  ether = max_ether
  _say("AWANS! Poziom %d" % level)

func _kill_enemy(index: int) -> void:
 var enemy := enemies[index]
 enemy["alive"] = false
 enemies[index] = enemy
 _grant_xp(20)
 gold += 5
 kills += 1
 if rng.randf() < 0.35:
  loot_drops.append({"item":"Skóra bestii","pos":enemy["pos"]+Vector2(rng.randf_range(-16,16),rng.randf_range(-16,16)),"life":60.0})
 if rng.randf() < 0.2:
  loot_drops.append({"item":"Odłamek Eterium","pos":enemy["pos"]+Vector2(rng.randf_range(-16,16),rng.randf_range(-16,16)),"life":60.0})
 if bool(enemy.get("is_boss",false)):
  boss_defeated = true
  quest = 6
  gold += 250
  _grant_xp(300)
  _say("STRAŻNIK RDZENIA POKONANY! +250 złota, +300 XP.")
 else:
  _say("Pokonano %s! +20 XP, +5 złota." % enemy["name"])
 if quest == 5 and bool(enemy.get("is_boss",false)):
  quest = 6
 if quest == 1 and kills >= 5:
  quest = 2
  gold += 35
  _grant_xp(50)
  _say("Zadanie wykonane. Wróć do Kronikarza.")

func _quest_interact() -> void:
 if not started: return
 # Etap ruin ma własny punkt interakcji — nie może być blokowany dystansem do Kronikarza.
 if quest == 3:
  if player_pos.distance_to(RUINS_POS) > 135.0:
   _say("Wschodnie Ruiny są zaznaczone na mapie. Udaj się do ich centrum.")
   return
  quest = 4
  gold += 75
  _grant_xp(100)
  _say("Ruiny zbadane! +75 złota, +100 XP. Rozdział I ukończony!")
  _update_hud()
  return
 if player_pos.distance_to(START_POS) > 145.0:
  _say("Kronikarz czeka przy Kamiennym Kręgu.")
  return
 if quest == 0:
  quest = 1
  kills = 0
  _say("Kronikarz: pokonaj 5 stworzeń nękających okolicę.")
 elif quest == 2:
  quest = 3
  gold += 25
  _say("Nagroda odebrana! +25 złota. Nowe zadanie: zbadaj Wschodnie Ruiny.")
 elif quest == 4:
  quest = 5
  boss_spawned = true
  enemies.append({"name":"Strażnik Rdzenia","pos":RUINS_POS+Vector2(0,105),"hp":620.0,"max_hp":620.0,"damage":22.0,"speed":58.0,"alive":true,"type":3,"timer":0.0,"respawn":0.0,"windup":0.0,"windup_total":0.82,"is_boss":true})
  _say("NOWE ZADANIE: pokonaj Strażnika Rdzenia we Wschodnich Ruinach!")
 elif quest == 5:
  _say("Strażnik Rdzenia czeka we Wschodnich Ruinach.")
 elif quest >= 6:
  _say("Rozdział I ukończony. Aetherion jest bezpieczne — dalsza wyprawa czeka.")
 else:
  _say("Pokonaj 5 stworzeń, a potem wróć po nagrodę.")
 _update_hud()

func _draw_npc() -> void:
 var p := START_POS + Vector2(0,-48)
 var now := float(Time.get_ticks_msec())/1000.0
 var bob := sin(now*2.4)*2.0
 draw_ellipse_shadow(p+Vector2(0,31),38,10)
 draw_circle(p+Vector2(0,-13+bob),25,Color(0.92,0.72,0.38,0.08))
 draw_colored_polygon(PackedVector2Array([p+Vector2(-17,2+bob),p+Vector2(0,-7+bob),p+Vector2(17,2+bob),p+Vector2(23,34+bob),p+Vector2(-23,34+bob)]),Color("#66513f"))
 draw_colored_polygon(PackedVector2Array([p+Vector2(-13,1+bob),p+Vector2(0,-5+bob),p+Vector2(13,1+bob),p+Vector2(9,28+bob),p+Vector2(-9,28+bob)]),Color("#a58a63"))
 draw_rect(Rect2(p.x-5,p.y+28+bob,4,9),Color("#342f31"))
 draw_rect(Rect2(p.x+2,p.y+28+bob,4,9),Color("#342f31"))
 draw_circle(p+Vector2(0,-16+bob),11,Color("#d7b58b"))
 draw_arc(p+Vector2(0,-17+bob),12.0,PI,TAU,20,Color("#493b36"),5.0,true)
 draw_circle(p+Vector2(-4,-16+bob),1.4,Color("#302d2b"))
 draw_circle(p+Vector2(4,-16+bob),1.4,Color("#302d2b"))
 draw_line(p+Vector2(16,-3+bob),p+Vector2(24,35+bob),Color("#8c6848"),4.0,true)
 draw_line(p+Vector2(16,-3+bob),p+Vector2(24,35+bob),Color("#d8bd82"),1.2,true)
 var crystal := p+Vector2(15,-12+bob+sin(now*3.0)*2.0)
 draw_circle(crystal,8.0,Color(0.3,0.9,0.9,0.18))
 draw_colored_polygon(PackedVector2Array([crystal+Vector2(0,-9),crystal+Vector2(6,-1),crystal+Vector2(3,8),crystal+Vector2(-4,6),crystal+Vector2(-6,-2)]),Color("#83e7df"))
 draw_string(ThemeDB.fallback_font,p+Vector2(-48,-43+bob),"KRONIKARZ",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#ffe7a6"))
 if quest < 6:
  var marker := p+Vector2(0,-63+bob+sin(now*4.0)*3.0)
  draw_circle(marker,12.0,Color(0.96,0.73,0.3,0.88))
  draw_string(ThemeDB.fallback_font,marker+Vector2(-4,6),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#392b1b"))

func _show_panel(panel_name: String) -> void:
 if not started: return
 panel.custom_minimum_size = Vector2(520, 380) if panel_name == "Ekwipunek" else (Vector2(660, 520) if panel_name == "Mapa" else (Vector2(620, 470) if panel_name == "Kodeks" else Vector2(440, 320)))
 panel.position = Vector2(-260, -190) if panel_name == "Ekwipunek" else (Vector2(-330, -260) if panel_name == "Mapa" else (Vector2(-310, -235) if panel_name == "Kodeks" else Vector2(-220, -160)))
 _clear_panel()
 panel.show()
 var box := VBoxContainer.new()
 box.add_theme_constant_override("separation", 9)
 panel.add_child(box)
 var header := HBoxContainer.new()
 box.add_child(header)
 var title := Label.new()
 title.text = panel_name.to_upper()
 title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 title.add_theme_font_size_override("font_size", 22)
 title.add_theme_color_override("font_color", Color("#f1d99f"))
 header.add_child(title)
 _button(header, "X", func(): panel.hide(), 38, 34)
 if panel_name == "Mapa":
  var map_view := TextureRect.new()
  map_view.texture = WORLD_TEXTURE
  map_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  map_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  map_view.custom_minimum_size = Vector2(610, 365)
  map_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  map_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
  box.add_child(map_view)
 if panel_name == "Ekwipunek":
  var summary := Label.new()
  summary.text = "PLECAK  •  ZŁOTO %d  •  PRZEDMIOTY %d" % [gold, inventory.size()+owned_gear.size()]
  summary.add_theme_color_override("font_color", Color("#a8d5df"))
  box.add_child(summary)
  var grid := GridContainer.new()
  grid.columns = 3
  grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
  grid.add_theme_constant_override("h_separation", 8)
  grid.add_theme_constant_override("v_separation", 8)
  box.add_child(grid)
  for item_name in inventory.keys():
   var count := int(inventory[item_name])
   var icon := "✚" if item_name == "Mikstura HP" else ("◆" if item_name == "Odłamek Eterium" else "◈")
   var item_button := Button.new()
   item_button.text = "%s\\n%s\\n× %d" % [icon, str(item_name), count]
   item_button.custom_minimum_size = Vector2(150, 78)
   item_button.add_theme_font_size_override("font_size", 13)
   item_button.tooltip_text = "Otwórz szczegóły: " + str(item_name)
   var item_style := StyleBoxFlat.new()
   item_style.bg_color = Color("#17283a")
   item_style.border_color = Color("#4c8292")
   item_style.set_border_width_all(2)
   item_style.set_corner_radius_all(10)
   item_button.add_theme_stylebox_override("normal", item_style)
   item_button.pressed.connect(func(): _show_item_detail(str(item_name)))
   grid.add_child(item_button)
  for gear_name in owned_gear:
   var gear_button := Button.new()
   var slot_name := str(GEAR_STATS[gear_name]["slot"])
   gear_button.text = "⚔\\n%s\\n%s" % [gear_name, "ZAŁOŻONE" if equipment.get(slot_name,"") == gear_name else "W PLECAKU"]
   gear_button.custom_minimum_size = Vector2(150, 78)
   gear_button.add_theme_font_size_override("font_size", 12)
   gear_button.pressed.connect(func(): _show_item_detail(gear_name))
   grid.add_child(gear_button)
  var hint := Label.new()
  hint.text = "Dotknij przedmiotu, aby zobaczyć opis i dostępne akcje."
  hint.add_theme_font_size_override("font_size", 12)
  hint.add_theme_color_override("font_color", Color("#9bb7c9"))
  box.add_child(hint)
  return
 var body := Label.new()
 body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 if panel_name == "Postać":
  body.text = "Rasa: %s\\nPoziom: %d  •  XP: %d\\nHP: %d/%d\\nEterium: %d/%d\\nAtak: %d  •  Obrona: %d\\nZłoto: %d\\nPokonani przeciwnicy: %d" % [race,level,xp,int(hp),int(max_hp),int(ether),int(max_ether),atk,defense,gold,kills]
 elif panel_name == "Rzemiosło":
  body.text = "Wytwarzaj wyposażenie z materiałów z potworów.\\nOstrze Eterium: 4 skóry + 3 odłamki (Atak +7).\\nPancerz Łowcy: 5 skór + 2 odłamki (Obrona +4, HP +30).\\nMikstura HP: 2 skóry + 1 odłamek."
 elif panel_name == "Mapa":
  var objective_text := "CEL: Wschodnie Ruiny" if quest >= 3 and quest <= 5 else ("CEL: wróć do Kronikarza" if quest == 2 else "CEL: Kamienny Krąg i pierwsze polowanie")
  body.text = "%s\\nPozycja: %d, %d\\n\\nKamienny Krąg • Zielone Ostępy • Korona Gór\\nKrypta Kryształów • Złote Pustkowia\\nWschodnie Ruiny • Popielne Ziemie" % [objective_text,int(player_pos.x),int(player_pos.y)]
 elif panel_name == "Kodeks":
  body.text = "AETHERION — KRONIKI ETERIUM\\n\\nPIĘĆ RODÓW\\nTerranie — wszechstronni i wytrwali.\\nVarkari — silni wojownicy o niezłomnej woli.\\nElarianie — urodzeni przewodnicy energii.\\nSylvari — strażnicy dzikiej równowagi.\\nNoctari — badacze mocy ukrytej w cieniu.\\n\\nKRAINA\\nKamienny Krąg jest bezpiecznym schronieniem wędrowców. Zielone Ostępy skrywają pradawne ścieżki, Korona Gór strzeże źródeł Eterium, a Kryształowa Krypta pulsuje nieznaną energią. Złote Pustkowia i Popielne Ziemie kryją ślady dawnych katastrof. Wschodnie Ruiny pozostają zamknięte dla tych, którzy nie poznali ich sekretu.\\n\\nETERIUM\\nEterium jest pierwotną siłą przenikającą świat. Wzmacnia techniki, pozwala przekraczać granice ciała i budzi Przebudzenie Rdzenia — lecz jego moc wymaga dyscypliny."
 else:
  body.text = "Technika Eterium: koszt 20, fala obszarowa, cooldown 4 s.\\nPromień Eterium: koszt 28, zasięg 285, potrójne obrażenia, cooldown 6 s.\\nSzarża: koszt 16, zasięg 310, cooldown 5 s.\\nPrzebudzenie Rdzenia: 16 s."
 box.add_child(body)
 if panel_name == "Rzemiosło":
  _button(box,"WYT WÓRZ OSTRZE ETERIUM",func(): _craft_item("Ostrze Eterium"),370,34)
  _button(box,"WYT WÓRZ PANCERZ ŁOWCY",func(): _craft_item("Pancerz ŁOWCY"),370,34)
  _button(box,"WYT WÓRZ MIKSTURĘ",func(): _craft_item("Mikstura HP"),370,34)
 _button(box,"ZAMKNIJ",func(): panel.hide(),370,38)

func _show_item_detail(item_name: String) -> void:
 _clear_panel()
 var box := VBoxContainer.new()
 box.add_theme_constant_override("separation", 12)
 panel.add_child(box)
 var title := Label.new()
 title.text = item_name.to_upper()
 title.add_theme_font_size_override("font_size", 20)
 title.add_theme_color_override("font_color", Color("#f1d99f"))
 box.add_child(title)
 var description := Label.new()
 description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 if GEAR_STATS.has(item_name):
  var stats: Dictionary = GEAR_STATS[item_name]
  description.text = "Slot: %s\\nAtak: +%d\\nObrona: +%d\\nMaksymalne HP: +%d\\n%s" % [stats["slot"],stats["atk"],stats["def"],stats["hp"],"Aktualnie założone" if equipment.get(str(stats["slot"]),"") == item_name else "Gotowe do założenia"]
 else:
  description.text = "Ilość w plecaku: %d\\n%s" % [int(inventory.get(item_name,0)), "Przywraca 60 HP." if item_name == "Mikstura HP" else "Materiał wykorzystywany w rzemiośle."]
 box.add_child(description)
 if GEAR_STATS.has(item_name) and equipment.get(str(GEAR_STATS[item_name]["slot"]),"") != item_name:
  _button(box,"ZAŁÓŻ PRZEDMIOT",func(): _equip_gear(item_name); _show_panel("Ekwipunek"),320,42)
 elif item_name == "Mikstura HP" and int(inventory.get(item_name,0)) > 0:
  _button(box,"UŻYJ MIKSTURĘ",func(): _potion(); _show_panel("Ekwipunek"),320,42)
 _button(box,"WRÓĆ DO PLECAKA",func(): _show_panel("Ekwipunek"),320,38)

func _craft_item(item_name: String) -> void:
 if item_name != "Mikstura HP" and owned_gear.has(item_name):
  _say("Ten przedmiot już posiadasz.")
  return
 if item_name == "Ostrze Eterium":
  if int(inventory["Skóra bestii"]) < 4 or int(inventory["Odłamek Eterium"]) < 3:
   _say("Brakuje materiałów na Ostrze Eterium.")
   return
  inventory["Skóra bestii"] -= 4
  inventory["Odłamek Eterium"] -= 3
 elif item_name == "Pancerz Łowcy":
  if int(inventory["Skóra bestii"]) < 5 or int(inventory["Odłamek Eterium"]) < 2:
   _say("Brakuje materiałów na Pancerz Łowcy.")
   return
  inventory["Skóra bestii"] -= 5
  inventory["Odłamek Eterium"] -= 2
 elif item_name == "Mikstura HP":
  if int(inventory["Skóra bestii"]) < 2 or int(inventory["Odłamek Eterium"]) < 1:
   _say("Brakuje materiałów na miksturę.")
   return
  inventory["Skóra bestii"] -= 2
  inventory["Odłamek Eterium"] -= 1
  inventory["Mikstura HP"] += 1
  _say("Wytworzono miksturę HP.")
  _show_panel("Rzemiosło")
  return
 if not owned_gear.has(item_name):
  owned_gear.append(item_name)
 _equip_gear(item_name)
 _say("Wytworzono i założono: %s." % item_name)
 _show_panel("Ekwipunek")

func _equip_gear(item_name: String) -> void:
 if not GEAR_STATS.has(item_name):
  return
 var slot := str(GEAR_STATS[item_name]["slot"])
 var old_item := str(equipment.get(slot,""))
 var old_stats: Dictionary = GEAR_STATS.get(old_item,{})
 var new_stats: Dictionary = GEAR_STATS[item_name]
 atk += int(new_stats.get("atk",0)) - int(old_stats.get("atk",0))
 defense += int(new_stats.get("def",0)) - int(old_stats.get("def",0))
 max_hp += int(new_stats.get("hp",0)) - int(old_stats.get("hp",0))
 hp = minf(hp,max_hp)
 equipment[slot] = item_name
 _update_hud()

func _save_game(silent: bool=false) -> void:
 if not started: return
 var saved_loot: Array[Dictionary] = []
 for drop in loot_drops:
  saved_loot.append({"item":str(drop.get("item","")),"pos":[drop["pos"].x,drop["pos"].y],"life":float(drop.get("life",60.0))})
 var boss_state: Dictionary = {}
 for enemy in enemies:
  if bool(enemy.get("is_boss",false)):
   boss_state = {"name":str(enemy["name"]),"pos":[enemy["pos"].x,enemy["pos"].y],"hp":float(enemy["hp"]),"max_hp":float(enemy["max_hp"]),"damage":float(enemy["damage"]),"speed":float(enemy["speed"])}
   break
 var data := {"race":race,"pos":[player_pos.x,player_pos.y],"hp":hp,"ether":ether,"level":level,"xp":xp,"gold":gold,"atk":atk,"defense":defense,"quest":quest,"kills":kills,"inventory":inventory,"equipment":equipment,"owned_gear":owned_gear,"boss_spawned":boss_spawned,"boss_defeated":boss_defeated,"loot_drops":saved_loot,"boss_state":boss_state}
 var file := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
 if file:
  file.store_string(JSON.stringify(data))
  if not silent:
   _say("Zapisano lokalnie.")
 else:
  _say("Nie udało się zapisać postępu.")

func _load_game() -> void:
 if not FileAccess.file_exists(SAVE_PATH):
  _say("Brak zapisu.")
  return
 var file := FileAccess.open(SAVE_PATH,FileAccess.READ)
 var data = JSON.parse_string(file.get_as_text())
 if typeof(data) != TYPE_DICTIONARY:
  _say("Uszkodzony zapis.")
  return
 race = str(data.get("race","Varkari"))
 if not RACES.has(race):
  race = "Varkari"
 var p: Array = data.get("pos",[START_POS.x,START_POS.y])
 player_pos = Vector2(float(p[0]),float(p[1]))
 level = int(data.get("level",1))
 xp = int(data.get("xp",0))
 gold = int(data.get("gold",0))
 atk = int(RACES[race]["atk"])+(level-1)*2
 defense = int(RACES[race]["def"])+(level-1)
 hp = float(data.get("hp",140))
 ether = float(data.get("ether",100))
 quest = int(data.get("quest",0))
 kills = int(data.get("kills",0))
 inventory = data.get("inventory",inventory)
 equipment = data.get("equipment",equipment)
 owned_gear.clear()
 for saved_gear in data.get("owned_gear",[]):
  var gear_name := str(saved_gear)
  if GEAR_STATS.has(gear_name) and not owned_gear.has(gear_name):
   owned_gear.append(gear_name)
 boss_spawned = bool(data.get("boss_spawned",false))
 boss_defeated = bool(data.get("boss_defeated",false))
 loot_drops.clear()
 for saved_drop in data.get("loot_drops",[]):
  if typeof(saved_drop) == TYPE_DICTIONARY:
   var drop_pos: Array = saved_drop.get("pos",[player_pos.x,player_pos.y])
   loot_drops.append({"item":str(saved_drop.get("item","Skóra bestii")),"pos":Vector2(float(drop_pos[0]),float(drop_pos[1])),"life":float(saved_drop.get("life",60.0))})
 max_hp = float(RACES[race]["hp"])+(level-1)*10
 for item_name in equipment.values():
  var gear_stats: Dictionary = GEAR_STATS.get(str(item_name),{})
  max_hp += int(gear_stats.get("hp",0))
  atk += int(gear_stats.get("atk",0))
  defense += int(gear_stats.get("def",0))
 if boss_spawned and not boss_defeated:
  var saved_boss: Dictionary = data.get("boss_state",{})
  var boss_pos := RUINS_POS+Vector2(0,105)
  var boss_hp := 620.0
  var boss_max_hp := 620.0
  if not saved_boss.is_empty():
   var saved_boss_pos: Array = saved_boss.get("pos",[boss_pos.x,boss_pos.y])
   boss_pos = Vector2(float(saved_boss_pos[0]),float(saved_boss_pos[1]))
   boss_hp = float(saved_boss.get("hp",620.0))
   boss_max_hp = float(saved_boss.get("max_hp",620.0))
  var existing_boss := -1
  for i in range(enemies.size()-1,-1,-1):
   if bool(enemies[i].get("is_boss",false)):
    existing_boss = i
    enemies.remove_at(i)
  enemies.append({"name":"Strażnik Rdzenia","pos":boss_pos,"hp":boss_hp,"max_hp":boss_max_hp,"damage":22.0,"speed":58.0,"alive":true,"type":3,"timer":0.0,"respawn":0.0,"is_boss":true})
 max_ether = float(RACES[race]["ep"])+(level-1)*7
 hp = clampf(hp,1.0,max_hp)
 ether = clampf(ether,0.0,max_ether)
 started = true
 panel.hide()
 camera.position = player_pos
 _say("Wczytano zapis.")
 _update_hud()

func _say(message: String) -> void:
 if is_instance_valid(msg): msg.text = message

func _notification(what: int) -> void:
 if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
  if started:
   _save_game(true)

func _update_hud() -> void:
 if not is_instance_valid(status): return
 status.text = "WĘDROWIEC  •  %s  •  POZ. %d  •  ZŁOTO %d" % [race.to_upper(),level,gold]
 if is_instance_valid(hp_bar):
  hp_bar.max_value = max_hp
  hp_bar.value = hp
 if is_instance_valid(ether_bar):
  ether_bar.max_value = max_ether
  ether_bar.value = ether
 var objectives := ["ZADANIE: porozmawiaj z Kronikarzem.","ZADANIE: pokonaj 5 stworzeń (%d/5)." % mini(kills,5),"ZADANIE: wróć do Kronikarza po nagrodę.","ZADANIE: dotrzyj do wschodnich ruin i zbadaj ich centrum.","ROZDZIAŁ I: zbadaj tajemnicę Strażnika Rdzenia.","ZADANIE: pokonaj Strażnika Rdzenia.","ROZDZIAŁ I UKOŃCZONY — Aetherion jest bezpieczne."]
 quest_label.text = objectives[clampi(quest,0,6)]
 _refresh_action_buttons()

func _refresh_action_buttons() -> void:
 if action_buttons.size() < 6:
  return
 action_buttons[0].disabled = attack_cd > 0.0
 action_buttons[1].disabled = skill_cd > 0.0 or ether < 20.0
 action_buttons[1].text = "✦\\nFALA" if skill_cd <= 0.0 else "✦\\n%.1fs" % skill_cd
 action_buttons[2].disabled = bolt_cd > 0.0 or ether < 28.0
 action_buttons[2].text = "◎\\nPROMIEŃ" if bolt_cd <= 0.0 else "◎\\n%.1fs" % bolt_cd
 action_buttons[3].disabled = dash_cd > 0.0 or ether < 16.0
 action_buttons[3].text = "➤\\nSZARŻA" if dash_cd <= 0.0 else "➤\\n%.1fs" % dash_cd
 action_buttons[4].disabled = not transformed and (transform_cd > 0.0 or ether < 28.0)
 action_buttons[4].text = "✧\\n%.0fs" % transform_left if transformed else ("✧\\nFORMA" if transform_cd <= 0.0 else "✧\\n%.0fs" % transform_cd)
 action_buttons[5].disabled = int(inventory.get("Mikstura HP",0)) <= 0 or hp >= max_hp
 action_buttons[5].tooltip_text = "Mikstury HP: %d" % int(inventory.get("Mikstura HP",0))

func _draw() -> void:
 _draw_world()
 _draw_ambient_particles()
 _draw_landmarks()
 if started:
  _draw_npc()
 for enemy in enemies:
  if enemy["alive"]:
   _draw_enemy(enemy)
 for drop in loot_drops:
  _draw_loot(drop)
 for number in damage_numbers:
  _draw_damage_number(number)
 if started:
  _draw_combat_effects()
  _draw_player()

func _draw_world() -> void:
 draw_texture_rect(WORLD_TEXTURE,Rect2(Vector2.ZERO,WORLD_SIZE),false)

func _draw_landmarks() -> void:
 var now := float(Time.get_ticks_msec()) / 1000.0
 var pulse := 0.7 + sin(now * 2.4) * 0.2
 draw_circle(START_POS,116.0,Color(0.35,0.95,0.9,0.07 * pulse))
 draw_circle(RUINS_POS,150.0,Color(0.55,0.85,1.0,0.045 * pulse))
 var font := ThemeDB.fallback_font
 var label_color := Color(0.91,0.94,0.82,0.82)
 draw_string(font,Vector2(210,112),"KAMIENNY KRĄG",HORIZONTAL_ALIGNMENT_LEFT,-1,24,label_color)
 draw_string(font,Vector2(260,610),"ZIELONE OSTĘPY",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color(0.78,0.93,0.72,0.82))
 draw_string(font,Vector2(1360,90),"KORONA GÓR",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color(0.91,0.95,0.97,0.84))
 draw_string(font,Vector2(180,980),"ZŁOTE PUSTKOWIA",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color(0.99,0.87,0.62,0.86))
 draw_string(font,Vector2(1450,1320),"POPIELNE ZIEMIE",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color(1.0,0.72,0.55,0.86))
 draw_string(font,Vector2(1070,205),"KRYPTA KRYSZTAŁÓW",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color(0.68,0.94,1.0,0.88))
 draw_string(font,Vector2(1450,635),"WSCHODNIE RUINY",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color(0.96,0.84,0.67,0.9))
 var marker := RUINS_POS + Vector2(0,-190.0+sin(now*4.0)*8.0)
 if quest >= 3 and quest <= 5:
  draw_line(player_pos,marker,Color(0.36,0.86,1.0,0.18),2.0,true)
  draw_circle(marker,15.0+sin(now*5.0)*3.0,Color(0.3,0.85,1.0,0.22))
  draw_arc(marker,23.0,0.0,TAU,32,Color(0.55,0.94,1.0,0.85),3.0,true)
  draw_string(font,marker+Vector2(-50,-28),"CEL ZADANIA",HORIZONTAL_ALIGNMENT_CENTER,-1,14,Color(0.72,0.96,1.0,0.95))

func _draw_damage_number(number: Dictionary) -> void:
 var life := float(number["life"])
 var alpha := clampf(life/0.3,0.0,1.0)
 var amount := str(number["amount"])
 var empowered := bool(number.get("empowered",false))
 var color := Color(1.0,0.78,0.34,alpha) if empowered else Color(1.0,0.96,0.82,alpha)
 var p: Vector2 = number["pos"]
 draw_string(ThemeDB.fallback_font,p+Vector2(-14,0),amount,HORIZONTAL_ALIGNMENT_CENTER,-1,17 if empowered else 14,color)

func _draw_loot(drop: Dictionary) -> void:
 var p: Vector2 = drop["pos"]
 var shard: bool = str(drop.get("item", "")) == "Odłamek Eterium"
 var glow := 0.72 + sin(float(Time.get_ticks_msec())/170.0)*0.18
 draw_circle(p,10.0,Color(0.1,0.08,0.06,0.45))
 draw_circle(p+Vector2(0,-3),6.0,Color(0.35,0.9,1.0,glow) if shard else Color(0.72,0.9,0.48,glow))
 draw_circle(p+Vector2(-2,-5),2.0,Color("#f3fff2"))
 draw_string(ThemeDB.fallback_font,p+Vector2(-28,-15),"ETER" if shard else "SKÓRA",HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("#baf5f2") if shard else Color("#d9efad"))

func _draw_enemy(enemy: Dictionary) -> void:
 var p: Vector2 = enemy["pos"]
 var kind := int(enemy["type"])
 var is_boss := bool(enemy.get("is_boss",false))
 var sprite_size := 126.0 if is_boss else 80.0
 var chasing := player_pos.distance_to(p) < 300.0
 var attacking := float(enemy.get("attack_anim",0.0)) > 0.0
 var frame := 1 if chasing and int(Time.get_ticks_msec()/145)%2 == 0 else 0
 var phase := float(enemy.get("walk_phase",0.0))
 var bob := sin(phase)*3.0 if chasing else sin(float(Time.get_ticks_msec())/260.0+float(kind))*1.5
 var enemy_facing: Vector2 = enemy.get("facing",Vector2.DOWN)
 var windup_left := float(enemy.get("windup",0.0))
 var lunge := enemy_facing * (7.0 if attacking else 0.0)
 var body_color := Color(1.0,0.55,0.48,1.0) if float(enemy.get("hit_flash",0.0)) > 0.0 else Color.WHITE
 draw_ellipse_shadow(p+Vector2(0,13),sprite_size*0.48,14.0 if is_boss else 8.0)
 if windup_left > 0.0:
  var windup_total := maxf(0.01,float(enemy.get("windup_total",0.52)))
  var warning_progress := clampf(1.0-windup_left/windup_total,0.0,1.0)
  var warning_alpha := 0.42+warning_progress*0.48
  if is_boss:
   draw_circle(p,112.0,Color(1.0,0.18,0.15,0.035+warning_progress*0.045))
   draw_arc(p,112.0,0.0,TAU,56,Color(1.0,0.28,0.2,warning_alpha),4.5,true)
  else:
   var warning_angle := enemy_facing.angle()
   draw_arc(p,43.0,warning_angle-0.82,warning_angle+0.82,24,Color(1.0,0.32,0.2,warning_alpha),4.0,true)
   draw_line(p,p+enemy_facing*48.0,Color(1.0,0.4,0.25,warning_alpha),3.0,true)
 if is_boss:
  var boss_pulse := 0.72 + sin(float(Time.get_ticks_msec())/190.0)*0.16
  draw_circle(p,76.0,Color(0.55,0.16,0.25,0.09*boss_pulse))
  draw_arc(p,72.0,0.0,TAU,48,Color(0.95,0.35,0.32,0.65),4.0,true)
 if attacking:
  var attack_progress := 1.0 - float(enemy.get("attack_anim",0.0))/0.34
  draw_arc(p,37.0 if not is_boss else 66.0,0.0,TAU,28,Color(1.0,0.28,0.22,0.72),3.0,true)
  if is_boss:
   var shock_radius := 42.0 + attack_progress*54.0
   draw_arc(p,shock_radius,0.0,TAU,40,Color(1.0,0.42,0.28,1.0-attack_progress),5.0,true)
 var sprite_rect := Rect2(p.x-sprite_size*0.5+lunge.x,p.y-sprite_size*0.55+bob+lunge.y,sprite_size,sprite_size)
 draw_texture_rect_region(SPRITE_ATLAS,sprite_rect,Rect2((5+kind)*128,frame*128,128,128),body_color,false)
 if float(enemy.get("hit_flash",0.0)) > 0.0:
  var hit_phase := float(enemy.get("hit_flash",0.0)) / 0.22
  for spark_index in range(6):
   var spark_angle := TAU*float(spark_index)/6.0 + float(kind)*0.4
   var spark_origin := p + Vector2.RIGHT.rotated(spark_angle)*(sprite_size*0.27)
   var spark_tip := spark_origin + Vector2.RIGHT.rotated(spark_angle)*(10.0+hit_phase*9.0)
   draw_line(spark_origin,spark_tip,Color(1.0,0.88,0.55,hit_phase),2.5,true)
 var bar_width := 100.0 if is_boss else 38.0
 var bar_y := p.y-sprite_size*0.53-10.0
 draw_rect(Rect2(p.x-bar_width*0.5,bar_y,bar_width,6 if is_boss else 5),Color("#251f28"))
 draw_rect(Rect2(p.x-bar_width*0.5+1,bar_y+1,(bar_width-2)*maxf(0.0,float(enemy["hp"])/float(enemy["max_hp"])),4 if is_boss else 3),Color("#e34d5c") if is_boss else Color("#d94d52"))
 draw_string(ThemeDB.fallback_font,p+Vector2(-bar_width*0.5,bar_y-7),str(enemy["name"]),HORIZONTAL_ALIGNMENT_LEFT,-1,15 if is_boss else 10,Color("#ffe0d5") if is_boss else Color("#f4ead2"))

func draw_ellipse_shadow(center: Vector2, width: float, height: float) -> void:
 var points := PackedVector2Array()
 for point_index in range(28):
  var angle := TAU * float(point_index) / 28.0
  points.append(center + Vector2(cos(angle)*width*0.5,sin(angle)*height*0.5))
 draw_colored_polygon(points,Color(0.015,0.025,0.035,0.34))

func _draw_combat_effects() -> void:
 var now := float(Time.get_ticks_msec()) / 1000.0
 if dash_anim > 0.0:
  var progress := 1.0 - dash_anim / 0.32
  var alpha := 1.0 - progress
  for trail in range(4):
   var point := dash_from.lerp(dash_to,progress-float(trail)*0.12)
   draw_circle(point,18.0-float(trail)*2.5,Color(0.35,0.85,1.0,alpha*0.22))
  draw_line(dash_from,dash_to,Color(0.55,0.95,1.0,alpha*0.65),7.0,true)
 if bolt_anim > 0.0:
  var beam_start := player_pos + player_facing * 26.0
  var progress := 1.0 - bolt_anim / 0.38
  var beam_width := 12.0 + sin(progress * PI) * 9.0
  var beam_color := Color(0.25,0.78,1.0,0.35 + (1.0-progress)*0.55)
  draw_line(beam_start,attack_target,beam_color,beam_width,true)
  draw_line(beam_start,attack_target,Color(0.88,1.0,1.0,0.96),maxf(2.0,beam_width*0.28),true)
  for spark_index in range(7):
   var spark_t := fposmod(progress * 1.8 + float(spark_index) / 7.0,1.0)
   var spark_pos := beam_start.lerp(attack_target,spark_t)
   var spark_angle := now * 13.0 + float(spark_index) * 2.1
   var spark_size := 4.0 + sin(now*19.0+float(spark_index))*2.0
   draw_line(spark_pos-Vector2.RIGHT.rotated(spark_angle)*spark_size,spark_pos+Vector2.RIGHT.rotated(spark_angle)*spark_size,Color(0.75,0.98,1.0,0.9),2.0,true)
  draw_circle(attack_target,18.0*(1.0-progress)+4.0,Color(0.4,0.88,1.0,0.35))
 if attack_anim > 0.0:
  var progress := 1.0 - attack_anim / 0.24
  var sweep := progress * 1.25
  var center := player_pos + Vector2(0,-5)
  var radius := 43.0 + sin(progress * PI) * 9.0
  draw_arc(center,radius,attack_angle-1.05+sweep,attack_angle+1.05+sweep,18,Color(0.95,0.96,1.0,0.95),5.0,true)
  var tip := center + Vector2.RIGHT.rotated(attack_angle+sweep) * radius
  draw_line(center + Vector2.RIGHT.rotated(attack_angle-0.72+sweep)*19.0,tip,Color("#8ce9e4"),3.0,true)
  var spark := attack_target + Vector2(0,-12)
  draw_line(spark+Vector2(-9,-8),spark+Vector2(9,8),Color("#fff0bd"),3.0,true)
  draw_line(spark+Vector2(-9,8),spark+Vector2(9,-8),Color("#8ce9e4"),3.0,true)
 if skill_anim > 0.0:
  var progress := 1.0 - skill_anim / 0.72
  var radius := 35.0 + progress * 145.0
  var alpha := 1.0 - progress
  var pulse := 1.0 + sin(now*24.0)*0.08
  draw_arc(player_pos,radius*pulse,0.0,TAU,48,Color(0.35,0.9,1.0,alpha),5.0,true)
  draw_arc(player_pos,radius*0.78,0.0,TAU,48,Color(0.75,0.98,1.0,alpha*0.65),2.0,true)
  for i in range(8):
   var angle := TAU*float(i)/8.0 + now*1.8
   var inner := player_pos + Vector2.RIGHT.rotated(angle)*(radius*0.72)
   var outer := player_pos + Vector2.RIGHT.rotated(angle)*(radius*1.08)
   draw_line(inner,outer,Color(0.55,0.95,1.0,alpha*0.8),3.0,true)
  draw_circle(player_pos,12.0+progress*9.0,Color(0.5,0.95,1.0,alpha*0.35))

func _draw_player() -> void:
 var moving: bool = bool(held["left"]) or bool(held["right"]) or bool(held["up"]) or bool(held["down"]) or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")
 var bob := sin(walk_phase)*2.0 if moving else 0.0
 var p := player_pos
 var race_index := maxi(0,RACES.keys().find(race))
 draw_ellipse_shadow(p+Vector2(0,15),25,9)
 var frame := 1 if moving and int(Time.get_ticks_msec()/145)%2 == 0 else 0
 var hero_tint := Color(1.0,0.55,0.48,1.0) if player_hit_flash > 0.0 else Color.WHITE
 draw_texture_rect_region(SPRITE_ATLAS,Rect2(p.x-44,p.y-52+bob,88,88),Rect2(race_index*128,frame*128,128,128),hero_tint,false)
 if transformed:
  var aura_time := float(Time.get_ticks_msec()) / 1000.0
  var aura_pulse := 0.78 + sin(aura_time*10.0)*0.18
  draw_arc(p+Vector2(0,3),43.0+sin(aura_time*7.0)*4.0,0.0,TAU,40,Color(1.0,0.55,0.12,0.72),3.0,true)
  draw_arc(p+Vector2(0,3),34.0, aura_time*1.8, aura_time*1.8+PI*1.45,32,Color(1.0,0.83,0.35,0.8),2.0,true)
  for aura_index in range(6):
   var aura_angle := aura_time*2.4 + TAU*float(aura_index)/6.0
   var aura_radius := 37.0 + sin(aura_time*8.0+float(aura_index))*5.0
   var aura_point := p + Vector2.RIGHT.rotated(aura_angle)*aura_radius
   draw_circle(aura_point,3.0*aura_pulse,Color(1.0,0.78,0.32,0.9))
   draw_circle(aura_point,6.0,Color(1.0,0.52,0.12,0.22))
  draw_rect(Rect2(p.x-22,p.y-35+bob,44,4),Color("#ffb34f"))
  draw_rect(Rect2(p.x-18,p.y-34+bob,36,2),Color("#fff0a6"))
  draw_circle(p,29,Color(1.0,0.65,0.2,0.13))
