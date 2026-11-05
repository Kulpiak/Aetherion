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
var started := false
var rng := RandomNumberGenerator.new()
var camera: Camera2D
var ui: CanvasLayer
var status: Label
var quest_label: Label
var msg: Label
var panel: PanelContainer
var virtual_stick: VirtualStick
var bolt_cd := 0.0
var bolt_anim := 0.0

func _ready() -> void:
 rng.randomize()
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
  enemies.append({"name":ENEMY_NAMES[i%4],"pos":Vector2(rng.randf_range(90,1830),rng.randf_range(90,1350)),"hp":enemy_hp,"max_hp":enemy_hp,"damage":7.0+float(i%4)*2.0,"speed":42.0+float(i%4)*8.0,"alive":true,"type":i%4,"timer":0.0,"respawn":0.0})

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
 _button(bottom,"ATAK",_attack,78,54)
 _button(bottom,"ETER",_skill,78,54)
 _button(bottom,"PROMIEŃ",_skill_bolt,82,54)
 _button(bottom,"FORMA",_transform,78,54)
 _button(bottom,"MIKSTURA",_potion,90,54)
 panel = PanelContainer.new()
 panel.set_anchors_preset(Control.PRESET_CENTER)
 panel.position = Vector2(-205,-145)
 panel.custom_minimum_size = Vector2(410,290)
 root.add_child(panel)
 panel.hide()

func _button(parent: Node, label_text: String, callback: Callable, w: float=132.0, h: float=36.0) -> void:
 var button := Button.new()
 button.text = label_text
 button.custom_minimum_size = Vector2(w,h)
 button.pressed.connect(callback)
 parent.add_child(button)

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
 panel.show()
 var box := VBoxContainer.new()
 panel.add_child(box)
 var title := Label.new()
 title.text = "AETHERION — WYBIERZ RASĘ"
 title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 title.add_theme_font_size_override("font_size",20)
 box.add_child(title)
 for race_name in RACES.keys():
  _button(box,race_name,func(): _start_game(race_name),380,36)

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
    enemy["respawn"] = 0.0
   enemies[i] = enemy
   continue
  var difference: Vector2 = player_pos - enemy["pos"]
  if difference.length() < 300.0 and difference.length() > 36.0:
   enemy["pos"] += difference.normalized() * enemy["speed"] * delta
  elif difference.length() <= 36.0:
   enemy["timer"] += delta
   if enemy["timer"] > 1.3:
    enemy["timer"] = 0.0
    hp -= maxf(2.0,enemy["damage"]-float(defense))
    if hp <= 0.0:
     hp = max_hp
     player_pos = START_POS
     gold = maxi(0,gold-8)
     _say("Odrodzenie przy kręgu. Utracono 8 złota.")
  enemies[i] = enemy
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
 enemy["hp"] -= atk + (8 if transformed else 0)
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
 enemy["hp"] -= atk * 3 + (18 if transformed else 0)
 if enemy["hp"] <= 0.0:
  _kill_enemy(index)
 else:
  enemies[index] = enemy
 _say("PROMIEŃ ETERIUM!")

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

func _kill_enemy(index: int) -> void:
 var enemy := enemies[index]
 enemy["alive"] = false
 enemies[index] = enemy
 xp += 20
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
  xp += 300
  _say("STRAŻNIK RDZENIA POKONANY! +250 złota, +300 XP.")
 else:
  _say("Pokonano %s! +20 XP, +5 złota." % enemy["name"])
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
 if quest == 5 and bool(enemy.get("is_boss",false)):
  quest = 6
 if quest == 1 and kills >= 5:
  quest = 2
  gold += 35
  xp += 50
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
  xp += 100
  _say("Ruiny zbadane! +75 złota, +100 XP. Rozdział I ukończony!")
  while xp >= level * 100:
   xp -= level * 100
   level += 1
   max_hp += 10
   max_ether += 7
   atk += 2
   defense += 1
   hp = max_hp
   ether = max_ether
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
  enemies.append({"name":"Strażnik Rdzenia","pos":RUINS_POS+Vector2(0,105),"hp":620.0,"max_hp":620.0,"damage":22.0,"speed":58.0,"alive":true,"type":3,"timer":0.0,"respawn":0.0,"is_boss":true})
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
 var bob := sin(float(Time.get_ticks_msec())/420.0)*2.0
 draw_rect(Rect2(p.x-10,p.y-1+bob,20,22),Color("#66543e"))
 draw_rect(Rect2(p.x-8,p.y-14+bob,16,14),Color("#d6b98a"))
 draw_rect(Rect2(p.x-10,p.y-18+bob,20,7),Color("#4b392e"))
 draw_rect(Rect2(p.x-7,p.y-5+bob,14,3),Color("#d5ad58"))
 draw_rect(Rect2(p.x-5,p.y+20+bob,5,7),Color("#382f2a"))
 draw_rect(Rect2(p.x+1,p.y+20+bob,5,7),Color("#382f2a"))
 draw_circle(p+Vector2(0,-28+bob),5,Color("#f3d477"))
 draw_string(ThemeDB.fallback_font,p+Vector2(-50,-36),"KRONIKARZ",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#ffe7a6"))

func _show_panel(panel_name: String) -> void:
 if not started: return
 _clear_panel()
 panel.show()
 var box := VBoxContainer.new()
 panel.add_child(box)
 var title := Label.new()
 title.text = panel_name
 title.add_theme_font_size_override("font_size",22)
 box.add_child(title)
 var body := Label.new()
 body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 if panel_name == "Postać":
  body.text = "Rasa: %s\\nPoziom: %d\\nHP: %d/%d\\nEterium: %d/%d\\nAtak: %d Obrona: %d\\nZłoto: %d" % [race,level,int(hp),int(max_hp),int(ether),int(max_ether),atk,defense,gold]
 elif panel_name == "Ekwipunek":
  body.text = "Mikstury HP: %d\\nSkóra bestii: %d\\nOdłamki Eterium: %d\\nBroń: %s\\nPancerz: %s" % [inventory["Mikstura HP"],inventory["Skóra bestii"],inventory["Odłamek Eterium"],equipment["Broń"],equipment["Pancerz"]]
 elif panel_name == "Rzemiosło":
  body.text = "Wytwarzaj wyposażenie z materiałów z potworów.\\nOstrze Eterium: 4 skóry + 3 odłamki (Atak +7).\\nPancerz Łowcy: 5 skór + 2 odłamki (Obrona +4, HP +30).\\nMikstura HP: 2 skóry + 1 odłamek."
 elif panel_name == "Mapa":
  body.text = "KAMIENNY KRĄG — bezpieczna strefa i Kronikarz.\\nZIELONE OSTĘPY — polowania na stworzenia.\\nWSCHODNIE RUINY — rozdział I i Strażnik Rdzenia.\\nTwoja pozycja: %d, %d" % [int(player_pos.x),int(player_pos.y)]
 else:
  body.text = "Technika Eterium: koszt 20, fala obszarowa, cooldown 4 s.\\nPromień Eterium: koszt 28, zasięg 285, potrójne obrażenia, cooldown 6 s.\\nPrzebudzenie Rdzenia: 16 s.\\nGałęzie rozwoju: Żar / Pryzmat / Instynkt."
 box.add_child(body)
 if panel_name == "Rzemiosło":
  _button(box,"WYT WÓRZ OSTRZE ETERIUM",func(): _craft_item("Ostrze Eterium"),370,34)
  _button(box,"WYT WÓRZ PANCERZ ŁOWCY",func(): _craft_item("Pancerz Łowcy"),370,34)
  _button(box,"WYT WÓRZ MIKSTURĘ",func(): _craft_item("Mikstura HP"),370,34)
 if panel_name == "Ekwipunek":
  for item_name in owned_gear:
   if item_name != equipment.get(str(GEAR_STATS[item_name]["slot"]),""):
    _button(box,"ZAŁÓŻ: "+item_name,func(): _equip_gear(item_name),370,32)
 _button(box,"ZAMKNIJ",func(): panel.hide(),370,38)

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
 status.text = "Wędrowiec | %s | POZ. %d\\nHP %d/%d  ETER %d/%d  ZŁOTO %d" % [race,level,int(hp),int(max_hp),int(ether),int(max_ether),gold]
 var objectives := ["ZADANIE: porozmawiaj z Kronikarzem.","ZADANIE: pokonaj 5 stworzeń (%d/5)." % mini(kills,5),"ZADANIE: wróć do Kronikarza po nagrodę.","ZADANIE: dotrzyj do wschodnich ruin i zbadaj ich centrum.","ROZDZIAŁ I: zbadaj tajemnicę Strażnika Rdzenia.","ZADANIE: pokonaj Strażnika Rdzenia.","ROZDZIAŁ I UKOŃCZONY — Aetherion jest bezpieczne."]
 quest_label.text = objectives[clampi(quest,0,6)]

func _draw() -> void:
 _draw_world()
 _draw_landmarks()
 if started:
  _draw_npc()
 for enemy in enemies:
  if enemy["alive"]:
   _draw_enemy(enemy)
 for drop in loot_drops:
  _draw_loot(drop)
 if started:
  _draw_combat_effects()
  _draw_player()

func _draw_world() -> void:
 draw_texture_rect(WORLD_TEXTURE,Rect2(Vector2.ZERO,WORLD_SIZE),false)

func _draw_landmarks() -> void:
 var pulse := 0.7 + sin(float(Time.get_ticks_msec()) / 420.0) * 0.2
 draw_circle(START_POS,116.0,Color(0.35,0.95,0.9,0.07 * pulse))
 draw_circle(RUINS_POS,150.0,Color(0.55,0.85,1.0,0.045 * pulse))

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
 var chasing := player_pos.distance_to(p) < 300.0
 var frame := 1 if chasing and int(Time.get_ticks_msec()/180)%2 == 0 else 0
 var bob := sin(float(Time.get_ticks_msec())/190.0+float(kind))*2.0
 draw_ellipse_shadow(p+Vector2(0,13),22,8)
 draw_texture_rect_region(SPRITE_ATLAS,Rect2(p.x-22,p.y-23+bob,44,44),Rect2((5+kind)*32,frame*32,32,32),Color.WHITE,false)
 draw_rect(Rect2(p.x-19,p.y-31,38,5),Color("#251f28"))
 draw_rect(Rect2(p.x-18,p.y-30,36.0*maxf(0.0,float(enemy["hp"])/float(enemy["max_hp"])),3),Color("#d94d52"))
 draw_string(ThemeDB.fallback_font,p+Vector2(-38,-36),str(enemy["name"]),HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("#f4ead2"))

func draw_ellipse_shadow(center: Vector2, width: float, height: float) -> void:
 draw_rect(Rect2(center.x-width/2.0,center.y-height/2.0,width,height),Color(0,0,0,0.28))

func _draw_combat_effects() -> void:
 var now := float(Time.get_ticks_msec()) / 1000.0
 if bolt_anim > 0.0:
  var beam_start := player_pos + Vector2(0,-8)
  draw_line(beam_start,attack_target,Color(0.35,0.95,1.0,0.9),9.0,true)
  draw_line(beam_start,attack_target,Color(0.9,1.0,1.0,0.95),3.0,true)
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
 draw_texture_rect_region(SPRITE_ATLAS,Rect2(p.x-24,p.y-27+bob,48,48),Rect2(race_index*32,frame*32,32,32),Color.WHITE,false)
 if transformed:
  draw_rect(Rect2(p.x-19,p.y-31+bob,38,3),Color("#ffb34f"))
  draw_rect(Rect2(p.x-23,p.y-27+bob,46,2),Color("#ffdc82"))
  draw_circle(p,29,Color(1.0,0.65,0.2,0.16))
