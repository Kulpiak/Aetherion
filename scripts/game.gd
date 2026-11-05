extends Node2D

const SAVE_PATH := "user://aetherion_save.json"
const WORLD_SIZE := Vector2(1920, 1440)
const START_POS := Vector2(480, 380)
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
 if player_pos.distance_to(START_POS) > 145.0:
  _say("Kronikarz czeka przy Kamiennym Kręgu.")
  return
 if quest == 0:
  quest = 1
  kills = 0
  _say("Zadanie: pokonaj 5 stworzeń.")
 elif quest == 2:
  quest = 3
  gold += 25
  _say("Nowe zadanie: zbadaj wschodnie ruiny.")
 else:
  _say("Wykonaj aktualne zadanie i wróć.")

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
 var objectives := ["ZADANIE: porozmawiaj z Kronikarzem.","ZADANIE: pokonaj 5 stworzeń (%d/5)." % mini(kills,5),"ZADANIE: wróć do Kronikarza.","ZADANIE: zbadaj wschodnie ruiny."]
 quest_label.text = objectives[clampi(quest,0,3)]

func _draw() -> void:
 var tile_colors := [Color("#315d3d"),Color("#356744"),Color("#585347"),Color("#6e6f77"),Color("#23475b"),Color("#82663e"),Color("#19362a"),Color("#5b7e66")]
 for x in range(0,int(WORLD_SIZE.x),32):
  for y in range(0,int(WORLD_SIZE.y),32):
   var n := int((x/32*7+y/32*11)%8)
   draw_rect(Rect2(x,y,32,32),tile_colors[n])
   if n == 0: draw_rect(Rect2(x+7,y+9,2,2),Color("#65915a"))
 draw_rect(Rect2(430,0,100,WORLD_SIZE.y),Color("#6c6555"))
 draw_circle(START_POS,104,Color("#74777b"))
 draw_circle(START_POS,78,Color("#363e43"))
 for k in range(8):
  var angle := TAU*float(k)/8.0
  draw_circle(START_POS+Vector2(cos(angle),sin(angle))*91,10,Color("#b4b9bb"))
 draw_string(ThemeDB.fallback_font,START_POS+Vector2(-70,-130),"KAMIENNY KRĄG",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("#fff0c4"))
 for enemy in enemies:
  if not enemy["alive"]: continue
  var p: Vector2 = enemy["pos"]
  draw_circle(p,15,ENEMY_COLORS[int(enemy["type"])])
  draw_circle(p+Vector2(-5,-4),3,Color("#f5e6c9"))
  draw_circle(p+Vector2(5,-4),3,Color("#f5e6c9"))
  draw_rect(Rect2(p.x-18,p.y-25,36,4),Color("#351e22"))
  draw_rect(Rect2(p.x-18,p.y-25,36.0*maxf(0.0,float(enemy["hp"])/float(enemy["max_hp"])),4),Color("#dc4b4b"))
  draw_string(ThemeDB.fallback_font,p+Vector2(-35,-30),str(enemy["name"]),HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color.WHITE)
 if started:
  var race_index := RACES.keys().find(race)
  var bob := sin(float(Time.get_ticks_msec())/140.0)*2.0
  var body_color := Color("#e0bd91")
  if race_index == 1: body_color = Color("#a9b6c6")
  elif race_index == 2: body_color = Color("#76c9d5")
  elif race_index == 3: body_color = Color("#83bd83")
  elif race_index == 4: body_color = Color("#8271a8")
  draw_circle(player_pos+Vector2(0,-8+bob),12,body_color)
  draw_rect(Rect2(player_pos.x-9,player_pos.y+2+bob,18,18),Color("#303744"))
  draw_rect(Rect2(player_pos.x-3,player_pos.y+3+bob,6,11),Color("#c84b4b"))
  if transformed: draw_arc(player_pos,29,0,TAU,32,Color("#ffb34f"),4)
