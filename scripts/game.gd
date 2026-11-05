extends Node2D

const SAVE_PATH := "user://aetherion_save.json"
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
var skill_cd := 0.0
var quest := 0
var kills := 0
var inventory := {"Mikstura HP":3,"Odłamek Eterium":0,"Skóra bestii":0}
var enemies: Array[Dictionary] = []
var started := false
var rng := RandomNumberGenerator.new()
var camera: Camera2D
var ui: CanvasLayer
var status: Label
var quest_label: Label
var msg: Label
var panel: PanelContainer

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
  enemies.append({"name":ENEMY_NAMES[i%4],"pos":Vector2(rng.randf_range(90,1830),rng.randf_range(90,1350)),"hp":enemy_hp,"max_hp":enemy_hp,"damage":7.0+float(i%4)*2.0,"speed":42.0+float(i%4)*8.0,"alive":true,"type":i%4,"timer":0.0})

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
 _button(right,"ZADANIE",_quest_interact)
 _button(right,"ZAPISZ",_save_game)
 _button(right,"WCZYTAJ",_load_game)
 var bottom := HBoxContainer.new()
 bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
 bottom.position = Vector2(8,-70)
 bottom.size = Vector2(944,62)
 bottom.alignment = BoxContainer.ALIGNMENT_CENTER
 root.add_child(bottom)
 _move_button(bottom,"◀","left")
 _move_button(bottom,"▲","up")
 _move_button(bottom,"▼","down")
 _move_button(bottom,"▶","right")
 _button(bottom,"ATAK",_attack,78,54)
 _button(bottom,"TECHNIKA",_skill,94,54)
 _button(bottom,"FORMA",_transform,78,54)
 _button(bottom,"MIKSTURA",_potion,94,54)
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
 attack_cd = maxf(0.0,attack_cd-delta)
 skill_cd = maxf(0.0,skill_cd-delta)
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
  if not enemy["alive"]: continue
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
 _update_hud()
 queue_redraw()

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
 for i in range(enemies.size()):
  var enemy := enemies[i]
  if enemy["alive"] and player_pos.distance_to(enemy["pos"]) < 170.0:
   enemy["hp"] -= atk * 2
   if enemy["hp"] <= 0.0: _kill_enemy(i)
   else: enemies[i] = enemy
 _say("Technika Eterium!")

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
 if rng.randf() < 0.35: inventory["Skóra bestii"] += 1
 if rng.randf() < 0.2: inventory["Odłamek Eterium"] += 1
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
 elif quest >= 4:
  _say("Rozdział I ukończony. Kronikarz przygotowuje kolejną wyprawę.")
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
  body.text = "Mikstura HP: %d\\nSkóra bestii: %d\\nOdłamki Eterium: %d\\nBroń: Ostrze Wędrowca\\nPancerz: Tunika Wędrowca" % [inventory["Mikstura HP"],inventory["Skóra bestii"],inventory["Odłamek Eterium"]]
 else:
  body.text = "Technika Eterium: koszt 20, obrażenia obszarowe, cooldown 4 s.\\nPrzebudzenie Rdzenia: koszt 28, czas 16 s, cooldown 32 s.\\nVarkari: gałęzie Żar / Pryzmat / Instynkt."
 box.add_child(body)
 _button(box,"ZAMKNIJ",func(): panel.hide(),370,38)

func _save_game() -> void:
 if not started: return
 var data := {"race":race,"pos":[player_pos.x,player_pos.y],"hp":hp,"ether":ether,"level":level,"xp":xp,"gold":gold,"atk":atk,"defense":defense,"quest":quest,"kills":kills,"inventory":inventory}
 var file := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
 if file:
  file.store_string(JSON.stringify(data))
  _say("Zapisano lokalnie.")

func _load_game() -> void:
 if not FileAccess.file_exists(SAVE_PATH):
  _say("Brak zapisu.")
  return
 var file := FileAccess.open(SAVE_PATH,FileAccess.READ)
 var data = JSON.parse_string(file.get_as_text())
 if typeof(data) != TYPE_DICTIONARY:
  _say("Uszkodzony zapis.")
  return
 race = data.get("race","Varkari")
 var p: Array = data.get("pos",[START_POS.x,START_POS.y])
 player_pos = Vector2(float(p[0]),float(p[1]))
 level = int(data.get("level",1))
 xp = int(data.get("xp",0))
 gold = int(data.get("gold",0))
 atk = int(data.get("atk",15))
 defense = int(data.get("defense",4))
 hp = float(data.get("hp",140))
 ether = float(data.get("ether",100))
 quest = int(data.get("quest",0))
 kills = int(data.get("kills",0))
 inventory = data.get("inventory",inventory)
 max_hp = float(RACES[race]["hp"])+(level-1)*10
 max_ether = float(RACES[race]["ep"])+(level-1)*7
 started = true
 panel.hide()
 camera.position = player_pos
 _say("Wczytano zapis.")
 _update_hud()

func _say(message: String) -> void:
 if is_instance_valid(msg): msg.text = message

func _update_hud() -> void:
 if not is_instance_valid(status): return
 status.text = "Wędrowiec | %s | POZ. %d\\nHP %d/%d  ETER %d/%d  ZŁOTO %d" % [race,level,int(hp),int(max_hp),int(ether),int(max_ether),gold]
 var objectives := ["ZADANIE: porozmawiaj z Kronikarzem.","ZADANIE: pokonaj 5 stworzeń (%d/5)." % mini(kills,5),"ZADANIE: wróć do Kronikarza po nagrodę.","ZADANIE: dotrzyj do wschodnich ruin i zbadaj ich centrum.","ROZDZIAŁ I: UKOŃCZONY — dalsza przygoda wkrótce."]
 quest_label.text = objectives[clampi(quest,0,4)]

func _draw() -> void:
 _draw_world()
 _draw_landmarks()
 if started:
  _draw_npc()
 for enemy in enemies:
  if enemy["alive"]:
   _draw_enemy(enemy)
 if started:
  _draw_player()

func _draw_world() -> void:
 var tile_colors := [Color("#284b38"),Color("#2d543d"),Color("#315941"),Color("#355d43"),Color("#294d3b"),Color("#385d43")]
 for x in range(0,int(WORLD_SIZE.x),32):
  for y in range(0,int(WORLD_SIZE.y),32):
   var seed_value := int((x / 32 * 17 + y / 32 * 29 + x * y / 97) % tile_colors.size())
   var tile_color: Color = tile_colors[seed_value]
   draw_rect(Rect2(x,y,32,32),tile_color)
   if seed_value == 0 or seed_value == 3:
    draw_rect(Rect2(x+7+(seed_value%3)*5,y+8,2,2),Color("#52764a"))
    draw_rect(Rect2(x+20,y+22-(seed_value%2)*5,2,2),Color("#1d3c30"))
   if seed_value == 2:
    draw_rect(Rect2(x+13,y+13,3,2),Color("#426849"))
 draw_rect(Rect2(430,0,100,WORLD_SIZE.y),Color("#625d4b"))
 draw_rect(Rect2(446,0,68,WORLD_SIZE.y),Color("#786e56"))
 for y in range(0,int(WORLD_SIZE.y),48):
  draw_rect(Rect2(477,y,5,22),Color("#8c8064"))

func _draw_landmarks() -> void:
 # Kamienny Krąg — centralna strefa startowa
 draw_circle(START_POS,112,Color("#1b332d"))
 draw_circle(START_POS,102,Color("#777b78"))
 draw_circle(START_POS,82,Color("#414c4a"))
 draw_circle(START_POS,68,Color("#69716c"))
 draw_circle(START_POS,52,Color("#35413e"))
 for k in range(8):
  var angle := TAU*float(k)/8.0
  var stone_pos := START_POS+Vector2(cos(angle),sin(angle))*91
  draw_rect(Rect2(stone_pos.x-9,stone_pos.y-7,18,14),Color("#a4aaa1"))
  draw_rect(Rect2(stone_pos.x-6,stone_pos.y-9,12,3),Color("#c2c7b9"))
 draw_circle(START_POS,12,Color("#67c6d0"))
 draw_circle(START_POS,6,Color("#b7f2e9"))
 draw_string(ThemeDB.fallback_font,START_POS+Vector2(-72,-130),"KAMIENNY KRĄG",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("#fff0c4"))
 # Wschodnie ruiny — cel pierwszego rozdziału
 draw_rect(Rect2(RUINS_POS.x-100,RUINS_POS.y-70,200,140),Color("#263b37"))
 draw_rect(Rect2(RUINS_POS.x-88,RUINS_POS.y-58,176,116),Color("#756d58"))
 draw_rect(Rect2(RUINS_POS.x-72,RUINS_POS.y-42,144,84),Color("#394b45"))
 for offset in [Vector2(-68,-38),Vector2(52,-38),Vector2(-68,28),Vector2(52,28)]:
  draw_rect(Rect2(RUINS_POS+offset,Vector2(16,16)),Color("#b2a88c"))
  draw_rect(Rect2(RUINS_POS+offset+Vector2(3,3),Vector2(10,10)),Color("#777967"))
 draw_rect(Rect2(RUINS_POS.x-14,RUINS_POS.y-28,28,56),Color("#202f2c"))
 draw_circle(RUINS_POS,15,Color("#58c4d0"))
 draw_circle(RUINS_POS,7,Color("#b3f5e9"))
 draw_string(ThemeDB.fallback_font,RUINS_POS+Vector2(-63,-92),"WSCHODNIE RUINY",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("#f3dfad"))
 # Rozrzucone głazy i drzewa jako czytelne punkty orientacyjne
 for i in range(24):
  var px := float((i*173+91)%int(WORLD_SIZE.x))
  var py := float((i*257+143)%int(WORLD_SIZE.y))
  if Vector2(px,py).distance_to(START_POS) < 150 or Vector2(px,py).distance_to(RUINS_POS) < 150:
   continue
  if i%3 == 0:
   draw_rect(Rect2(px-8,py-3,16,12),Color("#594f42"))
   draw_rect(Rect2(px-5,py-7,10,7),Color("#786b55"))
  else:
   draw_rect(Rect2(px-4,py-5,8,16),Color("#493d31"))
   draw_rect(Rect2(px-13,py-15,26,17),Color("#1b3e2d"))
   draw_rect(Rect2(px-9,py-22,18,12),Color("#285438"))

func _draw_enemy(enemy: Dictionary) -> void:
 var p: Vector2 = enemy["pos"]
 var kind := int(enemy["type"])
 var bob := sin(float(Time.get_ticks_msec())/190.0+float(kind))*2.0
 var colors := [Color("#a96b48"),Color("#8c9b9e"),Color("#684f87"),Color("#777b83")]
 var main_color: Color = colors[kind]
 draw_ellipse_shadow(p+Vector2(0,12),18,7)
 if kind == 0:
  # Dzik Eterowy — masywny korpus, pysk i kły
  draw_rect(Rect2(p.x-14,p.y-9+bob,28,19),main_color)
  draw_rect(Rect2(p.x-10,p.y-15+bob,17,10),main_color.lightened(0.12))
  draw_rect(Rect2(p.x+7,p.y-5+bob,11,9),Color("#d39b70"))
  draw_rect(Rect2(p.x+12,p.y-2+bob,4,5),Color("#f4e2bd"))
  draw_rect(Rect2(p.x-9,p.y+8+bob,5,7),Color("#513d36"))
  draw_rect(Rect2(p.x+6,p.y+8+bob,5,7),Color("#513d36"))
  draw_rect(Rect2(p.x-6,p.y-10+bob,3,3),Color("#fff0bd"))
 elif kind == 1:
  # Strażnik Ruin — kamienny konstrukt
  draw_rect(Rect2(p.x-12,p.y-15+bob,24,27),main_color)
  draw_rect(Rect2(p.x-16,p.y-8+bob,7,15),main_color.darkened(0.2))
  draw_rect(Rect2(p.x+9,p.y-8+bob,7,15),main_color.darkened(0.2))
  draw_rect(Rect2(p.x-8,p.y-20+bob,16,8),main_color.lightened(0.18))
  draw_rect(Rect2(p.x-6,p.y-12+bob,4,3),Color("#73d8df"))
  draw_rect(Rect2(p.x+3,p.y-12+bob,4,3),Color("#73d8df"))
 else:
  # Łowca i golem — sylwetki z pikselowych płyt
  draw_rect(Rect2(p.x-11,p.y-13+bob,22,25),main_color)
  draw_rect(Rect2(p.x-7,p.y-19+bob,14,9),main_color.lightened(0.16))
  draw_rect(Rect2(p.x-14,p.y-5+bob,6,15),main_color.darkened(0.15))
  draw_rect(Rect2(p.x+8,p.y-5+bob,6,15),main_color.darkened(0.15))
  draw_rect(Rect2(p.x-6,p.y-10+bob,3,3),Color("#ffe7a8"))
  draw_rect(Rect2(p.x+3,p.y-10+bob,3,3),Color("#ffe7a8"))
 draw_rect(Rect2(p.x-19,p.y-29,38,5),Color("#251f28"))
 draw_rect(Rect2(p.x-18,p.y-28,36.0*maxf(0.0,float(enemy["hp"])/float(enemy["max_hp"])),3),Color("#d94d52"))
 draw_string(ThemeDB.fallback_font,p+Vector2(-38,-34),str(enemy["name"]),HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("#f4ead2"))

func draw_ellipse_shadow(center: Vector2, width: float, height: float) -> void:
 draw_rect(Rect2(center.x-width/2.0,center.y-height/2.0,width,height),Color(0,0,0,0.28))

func _draw_player() -> void:
 var bob := sin(walk_phase)*2.0 if (held["left"] or held["right"] or held["up"] or held["down"]) else 0.0
 var p := player_pos
 var race_index := RACES.keys().find(race)
 var skin := Color("#e0bd91")
 var armor := Color("#34485a")
 var accent := Color("#c84b55")
 if race_index == 1:
  skin = Color("#a9b6c6")
  armor = Color("#39465c")
  accent = Color("#e3a44d")
 elif race_index == 2:
  skin = Color("#76c9d5")
  armor = Color("#315b70")
  accent = Color("#8ce9e4")
 elif race_index == 3:
  skin = Color("#83bd83")
  armor = Color("#365b42")
  accent = Color("#d4d17a")
 elif race_index == 4:
  skin = Color("#8271a8")
  armor = Color("#38334e")
  accent = Color("#b58be8")
 draw_ellipse_shadow(p+Vector2(0,14),22,8)
 # Płaszcz, tors i pas — pixel-art bez gładkich kół
 draw_rect(Rect2(p.x-9,p.y-1+bob,18,17),armor)
 draw_rect(Rect2(p.x-12,p.y+4+bob,5,12),armor.darkened(0.18))
 draw_rect(Rect2(p.x+7,p.y+4+bob,5,12),armor.darkened(0.18))
 draw_rect(Rect2(p.x-8,p.y+15+bob,6,7),Color("#292f3a"))
 draw_rect(Rect2(p.x+2,p.y+15+bob,6,7),Color("#292f3a"))
 draw_rect(Rect2(p.x-9,p.y+8+bob,18,3),accent)
 draw_rect(Rect2(p.x-6,p.y-12+bob,12,12),skin)
 draw_rect(Rect2(p.x-8,p.y-15+bob,16,5),skin.darkened(0.1))
 draw_rect(Rect2(p.x-6,p.y-7+bob,3,2),Color("#20242c"))
 draw_rect(Rect2(p.x+3,p.y-7+bob,3,2),Color("#20242c"))
 # Kierunkowe detale twarzy
 if player_facing.x < -0.2:
  draw_rect(Rect2(p.x-10,p.y-7+bob,3,3),Color("#f1d7b5"))
 elif player_facing.x > 0.2:
  draw_rect(Rect2(p.x+7,p.y-7+bob,3,3),Color("#f1d7b5"))
 if transformed:
  draw_rect(Rect2(p.x-16,p.y-22+bob,32,3),Color("#ffb34f"))
  draw_rect(Rect2(p.x-20,p.y-18+bob,40,2),Color("#ffdc82"))
  draw_circle(p,27,Color(1.0,0.65,0.2,0.16))
