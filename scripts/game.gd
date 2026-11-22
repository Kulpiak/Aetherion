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
const RACE_CREST_ATLAS: Texture2D = preload("res://assets/aetherion_race_crests.svg")
const ETERIUM_GLYPH_ATLAS: Texture2D = preload("res://assets/aetherion_eterium_glyphs.svg")
const WORLD_TEXTURE: Texture2D = preload("res://assets/aetherion_world.svg")
const REGION_LANDMARK_ATLAS: Texture2D = preload("res://assets/aetherion_region_landmarks.svg")
const REGION_CREATURE_ATLAS: Texture2D = preload("res://assets/aetherion_region_creatures.svg")
const PLAYER_DIRECTION_ATLAS: Texture2D = preload("res://assets/aetherion_player_directions.svg")
const CRYSTAL_SANCTUM_TEXTURE: Texture2D = preload("res://assets/aetherion_crystal_sanctum.svg")
const CRYSTAL_GUARDIAN_TEXTURE: Texture2D = preload("res://assets/aetherion_crystal_guardian.svg")
const VERDANT_SANCTUM_TEXTURE: Texture2D = preload("res://assets/aetherion_verdant_sanctum.svg")
const VERDANT_GUARDIAN_TEXTURE: Texture2D = preload("res://assets/aetherion_rootwarden.svg")
const FROST_SANCTUM_TEXTURE: Texture2D = preload("res://assets/aetherion_frost_sanctum.svg")
const FROST_GUARDIAN_TEXTURE: Texture2D = preload("res://assets/aetherion_stormwarden.svg")
const WORLD_SIZE := Vector2(1920, 1440)
const CRYPT_SIZE := Vector2(1280, 800)
const VERDANT_SIZE := Vector2(1280, 800)
const FROST_SIZE := Vector2(1280, 800)
const CRYPT_ENTRY := Vector2(1085, 465)
const CRYPT_START := Vector2(640, 590)
const CRYPT_EXIT := Vector2(640, 720)
const CRYPT_RELIC := Vector2(640, 155)
const VERDANT_ENTRY := Vector2(540, 790)
const VERDANT_START := Vector2(640, 700)
const VERDANT_EXIT := Vector2(1120, 720)
const VERDANT_RELIC := Vector2(640, 145)
const FROST_ENTRY := Vector2(1650, 420)
const FROST_START := Vector2(640, 590)
const FROST_EXIT := Vector2(640, 730)
const FROST_RELIC := Vector2(640, 145)
const START_POS := Vector2(480, 380)
const RUINS_POS := Vector2(1600, 720)
const RACES := {
 "Terranie":{"hp":125,"ep":90,"atk":13,"def":5},
 "Varkari":{"hp":140,"ep":100,"atk":15,"def":4},
 "Elarianie":{"hp":105,"ep":135,"atk":12,"def":3},
 "Sylvari":{"hp":130,"ep":110,"atk":11,"def":6},
 "Noctari":{"hp":112,"ep":120,"atk":14,"def":3}
}
const REGION_NAMES := ["Kamienny Krąg","Zielone Ostępy","Korona Gór","Krypta Kryształów","Złote Pustkowia","Wschodnie Ruiny","Popielne Ziemie","Szlak Eterium"]
const REGION_ENCOUNTERS := [
 {"name":"Kamienny Krąg","bounds":Rect2(180.0,130.0,440.0,390.0),"creatures":[]},
 {"name":"Zielone Ostępy","bounds":Rect2(0.0,510.0,880.0,450.0),"creatures":[
  {"name":"Mchowy Kieł","type":0,"hp":46.0,"damage":8.0,"speed":54.0,"xp":22,"gold":6},
  {"name":"Pnączowy Strażnik","type":1,"hp":70.0,"damage":10.0,"speed":38.0,"xp":28,"gold":8}
 ]},
 {"name":"Korona Gór","bounds":Rect2(1270.0,0.0,650.0,520.0),"creatures":[
  {"name":"Szronowy Raptor","type":2,"hp":82.0,"damage":13.0,"speed":72.0,"xp":34,"gold":10},
  {"name":"Burzowy Odłamek","type":3,"hp":94.0,"damage":15.0,"speed":42.0,"xp":40,"gold":12}
 ]},
 {"name":"Krypta Kryształów","bounds":Rect2(880.0,90.0,390.0,500.0),"creatures":[
  {"name":"Kryształowy Pająk","type":4,"hp":78.0,"damage":14.0,"speed":62.0,"xp":38,"gold":11},
  {"name":"Eterowy Skryba","type":5,"hp":88.0,"damage":16.0,"speed":48.0,"xp":44,"gold":13}
 ]},
 {"name":"Złote Pustkowia","bounds":Rect2(0.0,960.0,850.0,480.0),"creatures":[
  {"name":"Piaskowy Szperacz","type":6,"hp":90.0,"damage":15.0,"speed":66.0,"xp":42,"gold":13},
  {"name":"Strażnik Wydm","type":7,"hp":112.0,"damage":18.0,"speed":40.0,"xp":50,"gold":16}
 ]},
 {"name":"Wschodnie Ruiny","bounds":Rect2(1260.0,520.0,660.0,360.0),"creatures":[
  {"name":"Pęknięty Legionista","type":8,"hp":104.0,"damage":17.0,"speed":48.0,"xp":48,"gold":15},
  {"name":"Runiczny Tropiciel","type":9,"hp":98.0,"damage":19.0,"speed":64.0,"xp":54,"gold":17}
 ]},
 {"name":"Popielne Ziemie","bounds":Rect2(1280.0,880.0,640.0,560.0),"creatures":[
  {"name":"Popielny Łupieżca","type":10,"hp":126.0,"damage":20.0,"speed":61.0,"xp":58,"gold":18},
  {"name":"Żarowy Golem","type":11,"hp":158.0,"damage":23.0,"speed":36.0,"xp":68,"gold":22}
 ]},
 {"name":"Szlak Eterium","bounds":Rect2(850.0,600.0,410.0,840.0),"creatures":[
  {"name":"Eterowy Widmowiec","type":12,"hp":142.0,"damage":22.0,"speed":70.0,"xp":66,"gold":21},
  {"name":"Strażnik Szczeliny","type":13,"hp":180.0,"damage":26.0,"speed":42.0,"xp":80,"gold":26}
 ]}
]
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
var transform_burst := 0.0
var transform_cd := 0.0
var attack_cd := 0.0
var attack_anim := 0.0
var attack_angle := 0.0
var attack_target := Vector2.ZERO
var skill_cd := 0.0
var skill_anim := 0.0
var quest := 0
var kills := 0
var current_region := ""
var discovered_regions: Array[String] = []
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
var region_label: Label
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
var player_invuln := 0.0
var ambient_particles: Array[Dictionary] = []
var ambient_time := 0.0
var in_crystal_sanctum := false
var in_verdant_sanctum := false
var in_frost_sanctum := false
var overworld_player_pos := START_POS
var verdant_player_pos := VERDANT_START
var frost_player_pos := FROST_START
var overworld_enemies: Array[Dictionary] = []
var crypt_enemies: Array[Dictionary] = []
var verdant_enemies: Array[Dictionary] = []
var frost_enemies: Array[Dictionary] = []
var overworld_loot_drops: Array[Dictionary] = []
var crypt_loot_drops: Array[Dictionary] = []
var verdant_loot_drops: Array[Dictionary] = []
var frost_loot_drops: Array[Dictionary] = []
var crypt_guardian_defeated := false
var crypt_relic_claimed := false
var verdant_guardian_defeated := false
var verdant_relic_claimed := false
var frost_guardian_defeated := false
var frost_relic_claimed := false

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
 _apply_camera_bounds()

func _spawn_enemies() -> void:
 enemies.clear()
 for i in range(18):
  var region_index := 1 + (i % (REGION_ENCOUNTERS.size()-1))
  var region_data: Dictionary = REGION_ENCOUNTERS[region_index]
  var creatures: Array = region_data["creatures"]
  if creatures.is_empty():
   continue
  var creature_index := int(i / (REGION_ENCOUNTERS.size()-1)) % creatures.size()
  var creature: Dictionary = creatures[creature_index]
  var bounds: Rect2 = region_data["bounds"]
  var enemy_hp := float(creature["hp"])
  enemies.append({
   "spawn_id":"regional_%02d" % i,
   "name":str(creature["name"]),
   "pos":_random_point_in_bounds(bounds),
   "hp":enemy_hp,
   "max_hp":enemy_hp,
   "damage":float(creature["damage"]),
   "speed":float(creature["speed"]),
   "alive":true,
   "type":int(creature["type"]),
   "region":str(region_data["name"]),
   "spawn_bounds":bounds,
   "xp_reward":int(creature["xp"]),
   "gold_reward":int(creature["gold"]),
   "timer":0.0,
   "respawn":0.0,
   "attack_anim":0.0,
   "windup":0.0,
   "windup_total":0.52,
   "hit_flash":0.0,
   "walk_phase":0.0,
   "facing":Vector2.DOWN
  })

func _random_point_in_bounds(bounds: Rect2, margin: float = 48.0) -> Vector2:
 var safe_margin := minf(margin,minf(bounds.size.x,bounds.size.y)*0.25)
 return Vector2(
  rng.randf_range(bounds.position.x+safe_margin,bounds.position.x+bounds.size.x-safe_margin),
  rng.randf_range(bounds.position.y+safe_margin,bounds.position.y+bounds.size.y-safe_margin)
 )

func _create_crypt_enemies() -> Array[Dictionary]:
 var bounds := Rect2(210.0,170.0,860.0,450.0)
 var result: Array[Dictionary] = []
 result.append({"spawn_id":"crypt_00","name":"Kryształowy Pająk","pos":Vector2(365,285),"hp":138.0,"max_hp":138.0,"damage":18.0,"speed":62.0,"alive":true,"type":4,"region":"Krypta Kryształów","spawn_bounds":bounds,"xp_reward":54,"gold_reward":18,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.58,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"crypt_01","name":"Eterowy Skryba","pos":Vector2(915,285),"hp":156.0,"max_hp":156.0,"damage":20.0,"speed":48.0,"alive":true,"type":5,"region":"Krypta Kryształów","spawn_bounds":bounds,"xp_reward":62,"gold_reward":20,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.58,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"crypt_02","name":"Kryształowy Pająk","pos":Vector2(365,505),"hp":138.0,"max_hp":138.0,"damage":18.0,"speed":62.0,"alive":true,"type":4,"region":"Krypta Kryształów","spawn_bounds":bounds,"xp_reward":54,"gold_reward":18,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.58,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"crypt_03","name":"Eterowy Skryba","pos":Vector2(915,505),"hp":156.0,"max_hp":156.0,"damage":20.0,"speed":48.0,"alive":true,"type":5,"region":"Krypta Kryształów","spawn_bounds":bounds,"xp_reward":62,"gold_reward":20,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.58,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"crypt_guardian","name":"Matriarcha Geody","pos":Vector2(640,390),"hp":520.0,"max_hp":520.0,"damage":25.0,"speed":42.0,"alive":true,"type":5,"region":"Krypta Kryształów","spawn_bounds":bounds,"xp_reward":0,"gold_reward":0,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":1.05,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true,"is_boss":true,"is_crypt_boss":true})
 return result

func _is_in_instance() -> bool:
 return in_crystal_sanctum or in_verdant_sanctum or in_frost_sanctum

func _active_world_size() -> Vector2:
 if in_crystal_sanctum:
  return CRYPT_SIZE
 if in_verdant_sanctum:
  return VERDANT_SIZE
 if in_frost_sanctum:
  return FROST_SIZE
 return WORLD_SIZE

func _active_spawn_position() -> Vector2:
 if in_crystal_sanctum:
  return CRYPT_START
 if in_verdant_sanctum:
  return VERDANT_START
 if in_frost_sanctum:
  return FROST_START
 return START_POS

func _apply_camera_bounds() -> void:
 if not is_instance_valid(camera):
  return
 var active_size := _active_world_size()
 camera.limit_left = 0
 camera.limit_top = 0
 camera.limit_right = int(active_size.x)
 camera.limit_bottom = int(active_size.y)

func _create_verdant_enemies() -> Array[Dictionary]:
 var bounds := Rect2(190.0, 150.0, 900.0, 500.0)
 var result: Array[Dictionary] = []
 result.append({"spawn_id":"verdant_00","name":"Pnączowy Kieł","pos":Vector2(340,300),"hp":148.0,"max_hp":148.0,"damage":18.0,"speed":58.0,"alive":true,"type":0,"region":"Zielone Ostępy","spawn_bounds":bounds,"xp_reward":58,"gold_reward":18,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.58,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"verdant_01","name":"Mchowy Wartownik","pos":Vector2(930,300),"hp":188.0,"max_hp":188.0,"damage":22.0,"speed":39.0,"alive":true,"type":1,"region":"Zielone Ostępy","spawn_bounds":bounds,"xp_reward":72,"gold_reward":24,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.62,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"verdant_02","name":"Pnączowy Kieł","pos":Vector2(350,500),"hp":148.0,"max_hp":148.0,"damage":18.0,"speed":58.0,"alive":true,"type":0,"region":"Zielone Ostępy","spawn_bounds":bounds,"xp_reward":58,"gold_reward":18,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.58,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"verdant_03","name":"Mchowy Wartownik","pos":Vector2(930,500),"hp":188.0,"max_hp":188.0,"damage":22.0,"speed":39.0,"alive":true,"type":1,"region":"Zielone Ostępy","spawn_bounds":bounds,"xp_reward":72,"gold_reward":24,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.62,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"verdant_guardian","name":"Strażnik Splotu","pos":Vector2(640,385),"hp":760.0,"max_hp":760.0,"damage":28.0,"speed":36.0,"alive":true,"type":1,"region":"Zielone Ostępy","spawn_bounds":bounds,"xp_reward":0,"gold_reward":0,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":1.12,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true,"is_boss":true,"is_verdant_boss":true})
 return result

func _create_frost_enemies() -> Array[Dictionary]:
 var bounds := Rect2(180.0, 150.0, 920.0, 500.0)
 var result: Array[Dictionary] = []
 result.append({"spawn_id":"frost_00","name":"Szronowy Raptor","pos":Vector2(340,300),"hp":172.0,"max_hp":172.0,"damage":22.0,"speed":72.0,"alive":true,"type":2,"region":"Korona Gór","spawn_bounds":bounds,"xp_reward":80,"gold_reward":24,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.58,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"frost_01","name":"Burzowy Odłamek","pos":Vector2(930,300),"hp":198.0,"max_hp":198.0,"damage":26.0,"speed":42.0,"alive":true,"type":3,"region":"Korona Gór","spawn_bounds":bounds,"xp_reward":92,"gold_reward":28,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.62,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"frost_02","name":"Szronowy Raptor","pos":Vector2(350,500),"hp":172.0,"max_hp":172.0,"damage":22.0,"speed":72.0,"alive":true,"type":2,"region":"Korona Gór","spawn_bounds":bounds,"xp_reward":80,"gold_reward":24,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.58,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"frost_03","name":"Burzowy Odłamek","pos":Vector2(930,500),"hp":198.0,"max_hp":198.0,"damage":26.0,"speed":42.0,"alive":true,"type":3,"region":"Korona Gór","spawn_bounds":bounds,"xp_reward":92,"gold_reward":28,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":0.62,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true})
 result.append({"spawn_id":"frost_guardian","name":"Władca Burzowego Kryształu","pos":Vector2(640,390),"hp":840.0,"max_hp":840.0,"damage":34.0,"speed":38.0,"alive":true,"type":3,"region":"Korona Gór","spawn_bounds":bounds,"xp_reward":0,"gold_reward":0,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"windup":0.0,"windup_total":1.18,"hit_flash":0.0,"walk_phase":0.0,"facing":Vector2.DOWN,"instance":true,"is_boss":true,"is_frost_boss":true})
 return result

func _enter_frost_sanctum() -> void:
 if _is_in_instance():
  return
 overworld_player_pos = player_pos
 overworld_enemies = enemies
 overworld_loot_drops = loot_drops
 if frost_enemies.is_empty():
  frost_enemies = _create_frost_enemies()
 enemies = frost_enemies
 loot_drops = frost_loot_drops
 in_frost_sanctum = true
 player_pos = frost_player_pos
 held = {"left":false,"right":false,"up":false,"down":false}
 current_region = ""
 _apply_camera_bounds()
 if is_instance_valid(camera):
  camera.position = player_pos
 _update_region(false)
 _say("SANKTUARIUM BURZOWEGO KRYSZTAŁU • Odszukaj Władcę i uwolnij serce lodowej nawałnicy.")
 _update_hud()
 _save_game(true)

func _leave_frost_sanctum() -> void:
 if not in_frost_sanctum:
  return
 frost_enemies = enemies
 frost_loot_drops = loot_drops
 frost_player_pos = player_pos
 enemies = overworld_enemies
 loot_drops = overworld_loot_drops
 in_frost_sanctum = false
 player_pos = overworld_player_pos
 held = {"left":false,"right":false,"up":false,"down":false}
 current_region = ""
 _apply_camera_bounds()
 if is_instance_valid(camera):
  camera.position = player_pos
 _update_region(false)
 _say("Opuszczono Sanktuarium Burzowego Kryształu.")
 _update_hud()
 _save_game(true)

func _enter_verdant_sanctum() -> void:
 if _is_in_instance():
  return
 overworld_player_pos = player_pos
 overworld_enemies = enemies
 overworld_loot_drops = loot_drops
 if verdant_enemies.is_empty():
  verdant_enemies = _create_verdant_enemies()
 enemies = verdant_enemies
 loot_drops = verdant_loot_drops
 in_verdant_sanctum = true
 player_pos = verdant_player_pos
 held = {"left":false,"right":false,"up":false,"down":false}
 current_region = ""
 _apply_camera_bounds()
 if is_instance_valid(camera):
  camera.position = player_pos
 _update_region(false)
 _say("SANKTUARIUM KORZENI • Odszukaj Strażnika Splotu i uwolnij serce pradawnego drzewa.")
 _update_hud()
 _save_game(true)

func _leave_verdant_sanctum() -> void:
 if not in_verdant_sanctum:
  return
 verdant_enemies = enemies
 verdant_loot_drops = loot_drops
 verdant_player_pos = player_pos
 enemies = overworld_enemies
 loot_drops = overworld_loot_drops
 in_verdant_sanctum = false
 player_pos = overworld_player_pos
 held = {"left":false,"right":false,"up":false,"down":false}
 current_region = ""
 _apply_camera_bounds()
 if is_instance_valid(camera):
  camera.position = player_pos
 _update_region(false)
 _say("Opuszczono Sanktuarium Korzeni.")
 _update_hud()
 _save_game(true)

func _enter_crystal_sanctum() -> void:
 if in_crystal_sanctum:
  return
 overworld_player_pos = player_pos
 overworld_enemies = enemies
 overworld_loot_drops = loot_drops
 if crypt_enemies.is_empty():
  crypt_enemies = _create_crypt_enemies()
 enemies = crypt_enemies
 loot_drops = crypt_loot_drops
 in_crystal_sanctum = true
 player_pos = CRYPT_START
 held = {"left":false,"right":false,"up":false,"down":false}
 current_region = ""
 _apply_camera_bounds()
 if is_instance_valid(camera):
  camera.position = player_pos
 _update_region(false)
 _say("SANKTUARIUM GEODY • Pokonaj Matriarchę i zbadaj pradawny rdzeń.")
 _update_hud()
 _save_game(true)

func _leave_crystal_sanctum() -> void:
 if not in_crystal_sanctum:
  return
 crypt_enemies = enemies
 crypt_loot_drops = loot_drops
 enemies = overworld_enemies
 loot_drops = overworld_loot_drops
 in_crystal_sanctum = false
 player_pos = overworld_player_pos
 held = {"left":false,"right":false,"up":false,"down":false}
 current_region = ""
 _apply_camera_bounds()
 if is_instance_valid(camera):
  camera.position = player_pos
 _update_region(false)
 _say("Opuszczono Sanktuarium Geody.")
 _update_hud()
 _save_game(true)

func _location_interact() -> void:
 if not started:
  return
 if in_crystal_sanctum:
  if player_pos.distance_to(CRYPT_EXIT) <= 112.0:
   _leave_crystal_sanctum()
   return
  if player_pos.distance_to(CRYPT_RELIC) <= 112.0:
   if not crypt_guardian_defeated:
    _say("Rdzeń jest osłonięty. Najpierw pokonaj Matriarchę Geody.")
    return
   if crypt_relic_claimed:
    _say("Geodowy rdzeń został już zabezpieczony.")
    return
   crypt_relic_claimed = true
   inventory["Odłamek Eterium"] = int(inventory.get("Odłamek Eterium",0)) + 4
   gold += 90
   _grant_xp(140)
   _say("ZABEZPIECZONO GEODOWY RDZEŃ! +4 odłamki, +90 złota, +140 XP.")
   _update_hud()
   _save_game(true)
   return
  _say("Podejdź do portalu wyjściowego albo do geodowego rdzenia.")
  return
 if in_verdant_sanctum:
  if player_pos.distance_to(VERDANT_EXIT) <= 112.0:
   _leave_verdant_sanctum()
   return
  if player_pos.distance_to(VERDANT_RELIC) <= 112.0:
   if not verdant_guardian_defeated:
    _say("Serce pradawnego drzewa jest uśpione. Pokonaj najpierw Strażnika Splotu.")
    return
   if verdant_relic_claimed:
    _say("Serce Zielonego Sanktuarium zostało już oczyszczone.")
    return
   verdant_relic_claimed = true
   inventory["Odłamek Eterium"] = int(inventory.get("Odłamek Eterium",0)) + 2
   inventory["Skóra bestii"] = int(inventory.get("Skóra bestii",0)) + 3
   gold += 110
   _grant_xp(170)
   _say("SERCE SANKTUARIUM OCZYSZCZONE! +2 odłamki, +3 skóry, +110 złota, +170 XP.")
   _update_hud()
   _save_game(true)
   return
  _say("Podejdź do portalu wyjściowego albo do Serca Splotu.")
  return
 if in_frost_sanctum:
  if player_pos.distance_to(FROST_EXIT) <= 112.0:
   _leave_frost_sanctum()
   return
  if player_pos.distance_to(FROST_RELIC) <= 112.0:
   if not frost_guardian_defeated:
    _say("Serce burzowego kryształu jest zamrożone. Najpierw pokonaj Władcę.")
    return
   if frost_relic_claimed:
    _say("Serce Burzowego Kryształu zostało już uwolnione.")
    return
   frost_relic_claimed = true
   inventory["Odłamek Eterium"] = int(inventory.get("Odłamek Eterium",0)) + 3
   inventory["Skóra bestii"] = int(inventory.get("Skóra bestii",0)) + 2
   gold += 130
   _grant_xp(210)
   _say("SERCE BURZOWEGO KRYSZTAŁU UWOLNIONE! +3 odłamki, +2 skóry, +130 złota, +210 XP.")
   _update_hud()
   _save_game(true)
   return
  _say("Podejdź do portalu wyjściowego albo do Serca Burzowego Kryształu.")
  return
 if player_pos.distance_to(FROST_ENTRY) <= 120.0:
  _enter_frost_sanctum()
  return
 if player_pos.distance_to(VERDANT_ENTRY) <= 120.0:
  _enter_verdant_sanctum()
  return
 if player_pos.distance_to(CRYPT_ENTRY) <= 120.0:
  _enter_crystal_sanctum()
  return
 _say("Portale znajdują się w Zielonych Ostępach, Koronie Gór i przy wejściu do Krypty Kryształów.")

func _serialize_loot_drops(source_drops: Array) -> Array[Dictionary]:
 var saved: Array[Dictionary] = []
 for drop in source_drops:
  var drop_pos: Vector2 = drop.get("pos",Vector2.ZERO)
  saved.append({"item":str(drop.get("item","")),"pos":[drop_pos.x,drop_pos.y],"life":float(drop.get("life",60.0))})
 return saved

func _deserialize_loot_drops(saved_drops, bounds_size: Vector2) -> Array[Dictionary]:
 var restored: Array[Dictionary] = []
 if typeof(saved_drops) != TYPE_ARRAY:
  return restored
 for saved_drop in saved_drops:
  if typeof(saved_drop) != TYPE_DICTIONARY:
   continue
  var item_name := str(saved_drop.get("item",""))
  var position_data = saved_drop.get("pos",[])
  if not inventory.has(item_name) or item_name == "Mikstura HP" or typeof(position_data) != TYPE_ARRAY or position_data.size() < 2:
   continue
  var drop_pos := Vector2(clampf(float(position_data[0]),24.0,bounds_size.x-24.0),clampf(float(position_data[1]),24.0,bounds_size.y-24.0))
  restored.append({"item":item_name,"pos":drop_pos,"life":clampf(float(saved_drop.get("life",60.0)),0.1,60.0)})
 return restored

func _parse_saved_position(position_data, bounds_size: Vector2, fallback: Vector2) -> Vector2:
 if typeof(position_data) != TYPE_ARRAY or position_data.size() < 2:
  return fallback
 return Vector2(clampf(float(position_data[0]),24.0,bounds_size.x-24.0),clampf(float(position_data[1]),24.0,bounds_size.y-24.0))

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
 region_label = Label.new()
 region_label.add_theme_font_size_override("font_size",13)
 region_label.add_theme_color_override("font_color",Color("#9fd8dc"))
 left.add_child(region_label)
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
 _button(right,"LOKACJA",_location_interact)
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
  var identity_row := HBoxContainer.new()
  identity_row.alignment = BoxContainer.ALIGNMENT_CENTER
  identity_row.add_theme_constant_override("separation", 7)
  content.add_child(identity_row)
  var crest := TextureRect.new()
  var crest_region := AtlasTexture.new()
  crest_region.atlas = RACE_CREST_ATLAS
  crest_region.region = Rect2(index * 128, 0, 128, 128)
  crest.texture = crest_region
  crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  crest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  crest.custom_minimum_size = Vector2(38, 38)
  identity_row.add_child(crest)
  var name_label := Label.new()
  name_label.text = race_name.to_upper()
  name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  name_label.add_theme_font_size_override("font_size",17)
  name_label.add_theme_color_override("font_color",Color("#f2dfb5"))
  identity_row.add_child(name_label)
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
 in_crystal_sanctum = false
 in_verdant_sanctum = false
 in_frost_sanctum = false
 _spawn_enemies()
 overworld_enemies = []
 crypt_enemies = _create_crypt_enemies()
 verdant_enemies = _create_verdant_enemies()
 frost_enemies = _create_frost_enemies()
 overworld_loot_drops = []
 crypt_loot_drops = []
 verdant_loot_drops = []
 frost_loot_drops = []
 loot_drops = []
 crypt_guardian_defeated = false
 crypt_relic_claimed = false
 verdant_guardian_defeated = false
 verdant_relic_claimed = false
 frost_guardian_defeated = false
 frost_relic_claimed = false
 overworld_player_pos = START_POS
 verdant_player_pos = VERDANT_START
 frost_player_pos = FROST_START
 player_pos = START_POS
 _apply_camera_bounds()
 race = selected_race
 var stats: Dictionary = RACES[race]
 max_hp = stats["hp"]
 hp = max_hp
 max_ether = stats["ep"]
 ether = max_ether
 atk = stats["atk"]
 defense = stats["def"]
 started = true
 discovered_regions.clear()
 current_region = ""
 _update_region(false)
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
 player_invuln = maxf(0.0,player_invuln-delta)
 dash_anim = maxf(0.0,dash_anim-delta)
 if dash_anim > 0.0:
  player_pos = dash_from.lerp(dash_to,1.0-dash_anim/0.32)
 transform_cd = maxf(0.0,transform_cd-delta)
 transform_burst = maxf(0.0,transform_burst-delta)
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
 var active_size := _active_world_size()
 player_pos.x = clampf(player_pos.x,24.0,active_size.x-24.0)
 player_pos.y = clampf(player_pos.y,24.0,active_size.y-24.0)
 _update_region(true)
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
    var spawn_bounds: Rect2 = enemy.get("spawn_bounds",Rect2(90.0,90.0,1740.0,1260.0))
    enemy["pos"] = _random_point_in_bounds(spawn_bounds)
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
    if dash_anim > 0.0:
     _say("Uniknięto ataku dzięki Szarży!")
    elif player_invuln <= 0.0:
     player_hit_flash = 0.18
     player_invuln = 0.62
     hp -= maxf(2.0,enemy["damage"]-float(defense))
     if hp <= 0.0:
      hp = max_hp
      player_pos = _active_spawn_position()
      gold = maxi(0,gold-8)
      _say("Odrodzenie przy kręgu. Utracono 8 złota.")
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
  var tint := _ambient_tint_for_position(Vector2(x,y))
  ambient_particles.append({
   "pos":Vector2(x,y),
   "velocity":Vector2(rng.randf_range(-5.0,5.0),rng.randf_range(-13.0,-3.0)),
   "size":rng.randf_range(1.0,2.8),
   "phase":rng.randf_range(0.0,TAU),
   "tint":tint
  })

func _ambient_tint_for_position(position: Vector2) -> Color:
 if Rect2(180.0,130.0,440.0,390.0).has_point(position):
  return Color("#f1d08b")
 if Rect2(0.0,510.0,880.0,450.0).has_point(position):
  return Color("#a7e8a4")
 if Rect2(1270.0,0.0,650.0,520.0).has_point(position):
  return Color("#c8efff")
 if Rect2(880.0,90.0,390.0,500.0).has_point(position):
  return Color("#83e9f4")
 if Rect2(0.0,960.0,850.0,480.0).has_point(position):
  return Color("#ffd58a")
 if Rect2(1260.0,520.0,660.0,360.0).has_point(position):
  return Color("#d9c5a0")
 if Rect2(1280.0,880.0,640.0,560.0).has_point(position):
  return Color("#ff9c70")
 return Color("#a5f4eb")

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

func _region_for_position(position: Vector2) -> String:
 for index in range(REGION_ENCOUNTERS.size()-1):
  var region_data: Dictionary = REGION_ENCOUNTERS[index]
  var bounds: Rect2 = region_data["bounds"]
  if bounds.has_point(position):
   return str(region_data["name"])
 return "Szlak Eterium"

func _update_location_label() -> void:
 if not is_instance_valid(region_label):
  return
 if in_crystal_sanctum:
  region_label.text = "LOKACJA • SANKTUARIUM GEODY"
 elif in_verdant_sanctum:
  region_label.text = "LOKACJA • SANKTUARIUM KORZENI"
 elif in_frost_sanctum:
  region_label.text = "LOKACJA • SANKTUARIUM BURZOWEGO KRYSZTAŁU"
 else:
  region_label.text = "REGION • " + current_region.to_upper()

func _update_region(award_discovery: bool = true) -> void:
 var next_region := "Krypta Kryształów" if in_crystal_sanctum else ("Zielone Ostępy" if in_verdant_sanctum else ("Korona Gór" if in_frost_sanctum else _region_for_position(player_pos)))
 if next_region == current_region:
  _update_location_label()
  return
 current_region = next_region
 _update_location_label()
 if discovered_regions.has(current_region):
  return
 discovered_regions.append(current_region)
 if award_discovery and current_region != "Kamienny Krąg":
  gold += 10
  _grant_xp(25)
  _say("ODKRYTO: %s  •  +25 XP  •  +10 ZŁOTA" % current_region.to_upper())
 else:
  _say("ODKRYTO REGION: %s" % current_region)
 _update_hud()

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
 var active_size := _active_world_size()
 dash_to.x = clampf(dash_to.x,24.0,active_size.x-24.0)
 dash_to.y = clampf(dash_to.y,24.0,active_size.y-24.0)
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
 transform_burst = 1.0
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
 var is_crypt_boss := bool(enemy.get("is_crypt_boss",false))
 var is_verdant_boss := bool(enemy.get("is_verdant_boss",false))
 var xp_reward := int(enemy.get("xp_reward",20))
 var gold_reward := int(enemy.get("gold_reward",5))
 _grant_xp(xp_reward)
 gold += gold_reward
 kills += 1
 if rng.randf() < 0.35:
  loot_drops.append({"item":"Skóra bestii","pos":enemy["pos"]+Vector2(rng.randf_range(-16,16),rng.randf_range(-16,16)),"life":60.0})
 if rng.randf() < 0.2:
  loot_drops.append({"item":"Odłamek Eterium","pos":enemy["pos"]+Vector2(rng.randf_range(-16,16),rng.randf_range(-16,16)),"life":60.0})
 if is_crypt_boss:
  crypt_guardian_defeated = true
  gold += 120
  _grant_xp(180)
  _say("MATRIARCHA GEODY POKONANA! Rdzeń sanktuarium jest odsłonięty.")
 elif is_verdant_boss:
  verdant_guardian_defeated = true
  gold += 150
  _grant_xp(220)
  _say("STRAŻNIK SPLOTU POKONANY! Serce pradawnego drzewa odzyskuje blask.")
 elif bool(enemy.get("is_frost_boss",false)):
  frost_guardian_defeated = true
  gold += 180
  _grant_xp(260)
  _say("WŁADCA BURZOWEGO KRYSZTAŁU POKONANY! Lodowe serce nawałnicy jest odsłonięte.")
 elif bool(enemy.get("is_boss",false)):
  boss_defeated = true
  quest = 6
  gold += 250
  _grant_xp(300)
  _say("STRAŻNIK RDZENIA POKONANY! +250 złota, +300 XP.")
 else:
  _say("Pokonano %s! +%d XP, +%d złota." % [enemy["name"],xp_reward,gold_reward])
 if quest == 5 and bool(enemy.get("is_boss",false)) and not is_crypt_boss and not is_verdant_boss and not bool(enemy.get("is_frost_boss",false)):
  quest = 6
 if quest == 1 and kills >= 5:
  quest = 2
  gold += 35
  _grant_xp(50)
  _say("Zadanie wykonane. Wróć do Kronikarza.")
 _save_game(true)

func _quest_interact() -> void:
 if not started: return
 if _is_in_instance():
  _say("W osobnej lokacji użyj przycisku LOKACJA przy portalu lub relikcie.")
  return
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
  map_view.texture = CRYSTAL_SANCTUM_TEXTURE if in_crystal_sanctum else (VERDANT_SANCTUM_TEXTURE if in_verdant_sanctum else (FROST_SANCTUM_TEXTURE if in_frost_sanctum else WORLD_TEXTURE))
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
  var discovered_text := ""
  for region_name in REGION_NAMES:
   discovered_text += ("✓ " if discovered_regions.has(region_name) else "· ") + region_name + "   "
  var location_text := "Sanktuarium Geody — osobna lokacja" if in_crystal_sanctum else ("Sanktuarium Korzeni — osobna lokacja" if in_verdant_sanctum else ("Sanktuarium Burzowego Kryształu — osobna lokacja" if in_frost_sanctum else "Świat otwarty"))
  body.text = "%s\\n%s\\nAktualny region: %s\\nOdkryte regiony: %d/%d\\n%s\\nPozycja: %d, %d" % [objective_text,location_text,current_region,discovered_regions.size(),REGION_NAMES.size(),discovered_text,int(player_pos.x),int(player_pos.y)]
 elif panel_name == "Kodeks":
  body.text = "AETHERION — KRONIKI ETERIUM\n\nPIĘĆ RODÓW\nTerranie — wszechstronni i wytrwali.\nVarkari — silni wojownicy o niezłomnej woli.\nElarianie — urodzeni przewodnicy energii.\nSylvari — strażnicy dzikiej równowagi.\nNoctari — badacze mocy ukrytej w cieniu.\n\nFAUNA REGIONÓW\nZielone Ostępy: Mchowy Kieł, Pnączowy Strażnik.\nKorona Gór: Szronowy Raptor, Burzowy Odłamek.\nKrypta Kryształów: Kryształowy Pająk, Eterowy Skryba.\nZłote Pustkowia: Piaskowy Szperacz, Strażnik Wydm.\nWschodnie Ruiny: Pęknięty Legionista, Runiczny Tropiciel.\nPopielne Ziemie: Popielny Łupieżca, Żarowy Golem.\nSzlak Eterium: Eterowy Widmowiec, Strażnik Szczeliny.\n\nOSOBNE LOKACJE\nSanktuarium Geody: Matriarcha Geody strzeże Geodowego Rdzenia.\nSanktuarium Korzeni: Strażnik Splotu broni serca pradawnego drzewa.\nSanktuarium Burzowego Kryształu: Władca Burzowego Kryształu strzeże lodowego serca nawałnicy.\n\nETERIUM\nEterium jest pierwotną siłą przenikającą świat. Wzmacnia techniki, pozwala przekraczać granice ciała i budzi Przebudzenie Rdzenia — lecz jego moc wymaga dyscypliny."
 else:
  body.text = "Technika Eterium: koszt 20, fala obszarowa, cooldown 4 s.\\nPromień Eterium: koszt 28, zasięg 285, potrójne obrażenia, cooldown 6 s.\\nSzarża: koszt 16, zasięg 310, cooldown 5 s.\\nPrzebudzenie Rdzenia: 16 s."
 box.add_child(body)
 if panel_name == "Rzemiosło":
  _button(box,"WYTWÓRZ OSTRZE ETERIUM",func(): _craft_item("Ostrze Eterium"),370,34)
  _button(box,"WYTWÓRZ PANCERZ ŁOWCY",func(): _craft_item("Pancerz Łowcy"),370,34)
  _button(box,"WYTWÓRZ MIKSTURĘ",func(): _craft_item("Mikstura HP"),370,34)
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
 if item_name != "Mikstura HP" and not GEAR_STATS.has(item_name):
  _say("Nieznana receptura.")
  return
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
  _save_game(true)
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
 _save_game(true)

func _serialize_enemy_states(source_enemies: Array = []) -> Array[Dictionary]:
 var states: Array[Dictionary] = []
 var selected_enemies: Array = enemies if source_enemies.is_empty() else source_enemies
 for enemy in selected_enemies:
  if bool(enemy.get("is_boss",false)) and not bool(enemy.get("is_crypt_boss",false)) and not bool(enemy.get("is_verdant_boss",false)) and not bool(enemy.get("is_frost_boss",false)):
   continue
  var enemy_pos: Vector2 = enemy["pos"]
  states.append({
   "spawn_id":str(enemy.get("spawn_id","")),
   "alive":bool(enemy.get("alive",true)),
   "hp":float(enemy.get("hp",enemy.get("max_hp",1.0))),
   "pos":[enemy_pos.x,enemy_pos.y],
   "respawn":float(enemy.get("respawn",0.0))
  })
 return states

func _restore_enemy_states(saved_states, bounds_size: Vector2 = WORLD_SIZE) -> void:
 if typeof(saved_states) != TYPE_ARRAY:
  return
 var states_by_id: Dictionary = {}
 for saved_state in saved_states:
  if typeof(saved_state) != TYPE_DICTIONARY:
   continue
  var spawn_id := str(saved_state.get("spawn_id",""))
  if not spawn_id.is_empty():
   states_by_id[spawn_id] = saved_state
 for index in range(enemies.size()):
  var enemy: Dictionary = enemies[index]
  if bool(enemy.get("is_boss",false)) and not bool(enemy.get("is_crypt_boss",false)) and not bool(enemy.get("is_verdant_boss",false)) and not bool(enemy.get("is_frost_boss",false)):
   continue
  var spawn_id := str(enemy.get("spawn_id",""))
  if not states_by_id.has(spawn_id):
   continue
  var saved_state: Dictionary = states_by_id[spawn_id]
  var saved_position = saved_state.get("pos",[])
  if typeof(saved_position) == TYPE_ARRAY and saved_position.size() >= 2:
   enemy["pos"] = Vector2(
    clampf(float(saved_position[0]),24.0,bounds_size.x-24.0),
    clampf(float(saved_position[1]),24.0,bounds_size.y-24.0)
   )
  var is_alive := bool(saved_state.get("alive",true))
  enemy["alive"] = is_alive
  enemy["hp"] = clampf(float(saved_state.get("hp",enemy["max_hp"])),1.0,float(enemy["max_hp"])) if is_alive else 0.0
  enemy["respawn"] = clampf(float(saved_state.get("respawn",0.0)),0.0,18.0) if not is_alive else 0.0
  enemy["timer"] = 0.0
  enemy["windup"] = 0.0
  enemy["attack_anim"] = 0.0
  enemy["hit_flash"] = 0.0
  enemy["walk_phase"] = 0.0
  enemy["facing"] = Vector2.DOWN
  enemies[index] = enemy

func _save_game(silent: bool=false) -> void:
 if not started:
  return
 if in_verdant_sanctum:
  verdant_player_pos = player_pos
 if in_frost_sanctum:
  frost_player_pos = player_pos
 var in_instance := _is_in_instance()
 var world_enemy_source: Array[Dictionary] = overworld_enemies if in_instance else enemies
 var crypt_enemy_source: Array[Dictionary] = enemies if in_crystal_sanctum else crypt_enemies
 var verdant_enemy_source: Array[Dictionary] = enemies if in_verdant_sanctum else verdant_enemies
 var frost_enemy_source: Array[Dictionary] = enemies if in_frost_sanctum else frost_enemies
 var world_loot_source: Array[Dictionary] = overworld_loot_drops if in_instance else loot_drops
 var crypt_loot_source: Array[Dictionary] = loot_drops if in_crystal_sanctum else crypt_loot_drops
 var verdant_loot_source: Array[Dictionary] = loot_drops if in_verdant_sanctum else verdant_loot_drops
 var frost_loot_source: Array[Dictionary] = loot_drops if in_frost_sanctum else frost_loot_drops
 var boss_state: Dictionary = {}
 for enemy in world_enemy_source:
  if bool(enemy.get("is_boss",false)) and not bool(enemy.get("is_crypt_boss",false)) and not bool(enemy.get("is_verdant_boss",false)) and not bool(enemy.get("is_frost_boss",false)):
   var boss_pos: Vector2 = enemy["pos"]
   boss_state = {"name":str(enemy["name"]),"pos":[boss_pos.x,boss_pos.y],"hp":float(enemy["hp"]),"max_hp":float(enemy["max_hp"]),"damage":float(enemy["damage"]),"speed":float(enemy["speed"])}
   break
 var saved_overworld_pos: Vector2 = overworld_player_pos if in_instance else player_pos
 var saved_verdant_pos: Vector2 = player_pos if in_verdant_sanctum else verdant_player_pos
 var saved_frost_pos: Vector2 = player_pos if in_frost_sanctum else frost_player_pos
 var data := {
  "save_version":7,
  "race":race,
  "pos":[player_pos.x,player_pos.y],
  "overworld_pos":[saved_overworld_pos.x,saved_overworld_pos.y],
  "verdant_pos":[saved_verdant_pos.x,saved_verdant_pos.y],
  "frost_pos":[saved_frost_pos.x,saved_frost_pos.y],
  "in_crystal_sanctum":in_crystal_sanctum,
  "in_verdant_sanctum":in_verdant_sanctum,
  "in_frost_sanctum":in_frost_sanctum,
  "crypt_guardian_defeated":crypt_guardian_defeated,
  "crypt_relic_claimed":crypt_relic_claimed,
  "verdant_guardian_defeated":verdant_guardian_defeated,
  "verdant_relic_claimed":verdant_relic_claimed,
  "frost_guardian_defeated":frost_guardian_defeated,
  "frost_relic_claimed":frost_relic_claimed,
  "hp":hp,
  "ether":ether,
  "level":level,
  "xp":xp,
  "gold":gold,
  "atk":atk,
  "defense":defense,
  "quest":quest,
  "kills":kills,
  "inventory":inventory,
  "equipment":equipment,
  "owned_gear":owned_gear,
  "boss_spawned":boss_spawned,
  "boss_defeated":boss_defeated,
  "loot_drops":_serialize_loot_drops(world_loot_source),
  "crypt_loot_drops":_serialize_loot_drops(crypt_loot_source),
  "verdant_loot_drops":_serialize_loot_drops(verdant_loot_source),
  "frost_loot_drops":_serialize_loot_drops(frost_loot_source),
  "boss_state":boss_state,
  "discovered_regions":discovered_regions,
  "enemy_states":_serialize_enemy_states(world_enemy_source),
  "crypt_enemy_states":_serialize_enemy_states(crypt_enemy_source),
  "verdant_enemy_states":_serialize_enemy_states(verdant_enemy_source),
  "frost_enemy_states":_serialize_enemy_states(frost_enemy_source)
 }
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
 if file == null:
  _say("Nie można otworzyć zapisu.")
  return
 var data = JSON.parse_string(file.get_as_text())
 if typeof(data) != TYPE_DICTIONARY:
  _say("Uszkodzony zapis.")
  return
 var save_version := int(data.get("save_version",1))
 if save_version < 1 or save_version > 7:
  _say("Zapis pochodzi z nieobsługiwanej wersji gry.")
  return
 _spawn_enemies()
 race = str(data.get("race","Varkari"))
 if not RACES.has(race):
  race = "Varkari"
 level = clampi(int(data.get("level",1)),1,999)
 xp = clampi(int(data.get("xp",0)),0,level*100-1)
 gold = clampi(int(data.get("gold",0)),0,999999999)
 kills = clampi(int(data.get("kills",0)),0,999999999)
 quest = clampi(int(data.get("quest",0)),0,6)
 in_crystal_sanctum = bool(data.get("in_crystal_sanctum",false))
 in_verdant_sanctum = bool(data.get("in_verdant_sanctum",false)) and not in_crystal_sanctum
 in_frost_sanctum = bool(data.get("in_frost_sanctum",false)) and not in_crystal_sanctum and not in_verdant_sanctum
 crypt_guardian_defeated = bool(data.get("crypt_guardian_defeated",false))
 crypt_relic_claimed = bool(data.get("crypt_relic_claimed",false))
 verdant_guardian_defeated = bool(data.get("verdant_guardian_defeated",false))
 verdant_relic_claimed = bool(data.get("verdant_relic_claimed",false))
 frost_guardian_defeated = bool(data.get("frost_guardian_defeated",false))
 frost_relic_claimed = bool(data.get("frost_relic_claimed",false))
 discovered_regions.clear()
 var saved_regions = data.get("discovered_regions",[])
 if typeof(saved_regions) == TYPE_ARRAY:
  for saved_region in saved_regions:
   var region_name := str(saved_region)
   if REGION_NAMES.has(region_name) and not discovered_regions.has(region_name):
    discovered_regions.append(region_name)
 if not discovered_regions.has("Kamienny Krąg"):
  discovered_regions.append("Kamienny Krąg")
 overworld_player_pos = _parse_saved_position(data.get("overworld_pos",data.get("pos",[])),WORLD_SIZE,START_POS)
 verdant_player_pos = _parse_saved_position(data.get("verdant_pos",[]),VERDANT_SIZE,VERDANT_START)
 frost_player_pos = _parse_saved_position(data.get("frost_pos",[]),FROST_SIZE,FROST_START)
 var active_size := _active_world_size()
 player_pos = _parse_saved_position(data.get("pos",[]),active_size,_active_spawn_position())
 if in_verdant_sanctum:
  verdant_player_pos = player_pos
 if in_frost_sanctum:
  frost_player_pos = player_pos
 inventory = {"Mikstura HP":3,"Odłamek Eterium":0,"Skóra bestii":0}
 var saved_inventory = data.get("inventory",{})
 if typeof(saved_inventory) == TYPE_DICTIONARY:
  for item_name in inventory.keys():
   if saved_inventory.has(item_name):
    inventory[item_name] = clampi(int(saved_inventory[item_name]),0,999999)
 equipment = {"Broń":"Ostrze Wędrowca","Pancerz":"Tunika Wędrowca"}
 var saved_equipment = data.get("equipment",{})
 if typeof(saved_equipment) == TYPE_DICTIONARY:
  for slot_name in equipment.keys():
   var candidate := str(saved_equipment.get(slot_name,equipment[slot_name]))
   if GEAR_STATS.has(candidate) and str(GEAR_STATS[candidate].get("slot","")) == str(slot_name):
    equipment[slot_name] = candidate
 owned_gear.clear()
 owned_gear.append("Ostrze Wędrowca")
 owned_gear.append("Tunika Wędrowca")
 var saved_owned_gear = data.get("owned_gear",[])
 if typeof(saved_owned_gear) == TYPE_ARRAY:
  for saved_gear in saved_owned_gear:
   var gear_name := str(saved_gear)
   if GEAR_STATS.has(gear_name) and not owned_gear.has(gear_name):
    owned_gear.append(gear_name)
 for equipped_item in equipment.values():
  var equipped_name := str(equipped_item)
  if not owned_gear.has(equipped_name):
   owned_gear.append(equipped_name)
 var race_stats: Dictionary = RACES[race]
 atk = int(race_stats["atk"])+(level-1)*2
 defense = int(race_stats["def"])+(level-1)
 max_hp = float(race_stats["hp"])+(level-1)*10
 max_ether = float(race_stats["ep"])+(level-1)*7
 for item_name in equipment.values():
  var gear_stats: Dictionary = GEAR_STATS.get(str(item_name),{})
  max_hp += int(gear_stats.get("hp",0))
  atk += int(gear_stats.get("atk",0))
  defense += int(gear_stats.get("def",0))
 hp = clampf(float(data.get("hp",max_hp)),1.0,max_hp)
 ether = clampf(float(data.get("ether",max_ether)),0.0,max_ether)
 boss_spawned = bool(data.get("boss_spawned",false))
 boss_defeated = bool(data.get("boss_defeated",false))
 if boss_defeated:
  quest = 6
 var restored_world_loot := _deserialize_loot_drops(data.get("loot_drops",[]),WORLD_SIZE)
 var restored_crypt_loot := _deserialize_loot_drops(data.get("crypt_loot_drops",[]),CRYPT_SIZE)
 var restored_verdant_loot := _deserialize_loot_drops(data.get("verdant_loot_drops",[]),VERDANT_SIZE)
 var restored_frost_loot := _deserialize_loot_drops(data.get("frost_loot_drops",[]),FROST_SIZE)
 _restore_enemy_states(data.get("enemy_states",[]),WORLD_SIZE)
 if boss_spawned and not boss_defeated:
  var saved_boss = data.get("boss_state",{})
  if typeof(saved_boss) != TYPE_DICTIONARY:
   saved_boss = {}
  var boss_pos := RUINS_POS+Vector2(0,105)
  var boss_position_data = saved_boss.get("pos",[])
  if typeof(boss_position_data) == TYPE_ARRAY and boss_position_data.size() >= 2:
   boss_pos = Vector2(
    clampf(float(boss_position_data[0]),24.0,WORLD_SIZE.x-24.0),
    clampf(float(boss_position_data[1]),24.0,WORLD_SIZE.y-24.0)
   )
  var boss_max_hp := maxf(1.0,float(saved_boss.get("max_hp",620.0)))
  var boss_hp := clampf(float(saved_boss.get("hp",boss_max_hp)),1.0,boss_max_hp)
  enemies.append({"name":"Strażnik Rdzenia","pos":boss_pos,"hp":boss_hp,"max_hp":boss_max_hp,"damage":22.0,"speed":58.0,"alive":true,"type":3,"timer":0.0,"respawn":0.0,"attack_anim":0.0,"hit_flash":0.0,"windup":0.0,"windup_total":0.82,"walk_phase":0.0,"facing":Vector2.DOWN,"is_boss":true})
 var restored_world_enemies: Array[Dictionary] = enemies
 enemies = _create_crypt_enemies()
 _restore_enemy_states(data.get("crypt_enemy_states",[]),CRYPT_SIZE)
 var restored_crypt_enemies: Array[Dictionary] = enemies
 enemies = _create_verdant_enemies()
 _restore_enemy_states(data.get("verdant_enemy_states",[]),VERDANT_SIZE)
 var restored_verdant_enemies: Array[Dictionary] = enemies
 enemies = _create_frost_enemies()
 _restore_enemy_states(data.get("frost_enemy_states",[]),FROST_SIZE)
 var restored_frost_enemies: Array[Dictionary] = enemies
 overworld_enemies = restored_world_enemies
 crypt_enemies = restored_crypt_enemies
 verdant_enemies = restored_verdant_enemies
 frost_enemies = restored_frost_enemies
 overworld_loot_drops = restored_world_loot
 crypt_loot_drops = restored_crypt_loot
 verdant_loot_drops = restored_verdant_loot
 frost_loot_drops = restored_frost_loot
 if in_crystal_sanctum:
  enemies = crypt_enemies
  loot_drops = crypt_loot_drops
 elif in_verdant_sanctum:
  enemies = verdant_enemies
  loot_drops = verdant_loot_drops
 elif in_frost_sanctum:
  enemies = frost_enemies
  loot_drops = frost_loot_drops
 else:
  enemies = overworld_enemies
  loot_drops = overworld_loot_drops
 transformed = false
 transform_left = 0.0
 player_invuln = 0.0
 dash_anim = 0.0
 damage_numbers.clear()
 started = true
 current_region = ""
 _apply_camera_bounds()
 _update_region(false)
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
 if is_instance_valid(region_label):
  _update_location_label()
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
 if not _is_in_instance():
  _draw_ambient_particles()
 _draw_landmarks()
 if started and not _is_in_instance():
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
 if in_crystal_sanctum:
  draw_texture_rect(CRYSTAL_SANCTUM_TEXTURE,Rect2(Vector2.ZERO,CRYPT_SIZE),false)
 elif in_verdant_sanctum:
  draw_texture_rect(VERDANT_SANCTUM_TEXTURE,Rect2(Vector2.ZERO,VERDANT_SIZE),false)
 elif in_frost_sanctum:
  draw_texture_rect(FROST_SANCTUM_TEXTURE,Rect2(Vector2.ZERO,FROST_SIZE),false)
 else:
  draw_texture_rect(WORLD_TEXTURE,Rect2(Vector2.ZERO,WORLD_SIZE),false)

func _draw_landmarks() -> void:
 var now := float(Time.get_ticks_msec()) / 1000.0
 if in_crystal_sanctum:
  _draw_crypt_landmarks(now)
  return
 if in_verdant_sanctum:
  _draw_verdant_landmarks(now)
  return
 if in_frost_sanctum:
  _draw_frost_landmarks(now)
  return
 var pulse := 0.7 + sin(now * 2.4) * 0.2
 _draw_region_landmarks(now)
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
 draw_circle(CRYPT_ENTRY,43.0,Color(0.25,0.92,1.0,0.08+sin(now*3.0)*0.025))
 draw_arc(CRYPT_ENTRY,39.0,now*0.35,now*0.35+TAU,48,Color(0.55,0.95,1.0,0.88),4.0,true)
 draw_arc(CRYPT_ENTRY,29.0,-now*0.52,-now*0.52+PI*1.45,36,Color(0.82,0.98,1.0,0.75),2.0,true)
 draw_string(font,CRYPT_ENTRY+Vector2(-78,66),"SANKTUARIUM",HORIZONTAL_ALIGNMENT_CENTER,-1,13,Color("#a7f4f0"))
 var root_pulse := 0.7 + sin(now*2.8+0.7)*0.22
 draw_circle(VERDANT_ENTRY,39.0,Color(0.34,0.88,0.49,0.09*root_pulse))
 draw_arc(VERDANT_ENTRY,35.0,-now*0.3,-now*0.3+TAU,48,Color("#9cdda0"),3.5,true)
 draw_arc(VERDANT_ENTRY,25.0,now*0.52,now*0.52+PI*1.55,36,Color("#d5f4b2"),2.0,true)
 draw_string(font,VERDANT_ENTRY+Vector2(-82,58),"SANKTUARIUM KORZENI",HORIZONTAL_ALIGNMENT_CENTER,-1,12,Color("#c7edb0"))
 var frost_pulse := 0.72 + sin(now*2.5+1.2)*0.2
 draw_circle(FROST_ENTRY,42.0,Color(0.35,0.82,1.0,0.09*frost_pulse))
 draw_arc(FROST_ENTRY,38.0,now*0.38,now*0.38+TAU,48,Color("#8be7ff"),3.8,true)
 draw_arc(FROST_ENTRY,27.0,-now*0.54,-now*0.54+PI*1.55,36,Color("#d6fbff"),2.0,true)
 draw_string(font,FROST_ENTRY+Vector2(-108,66),"SANKTUARIUM BURZ",HORIZONTAL_ALIGNMENT_CENTER,-1,12,Color("#bcefff"))
 var marker := RUINS_POS + Vector2(0,-190.0+sin(now*4.0)*8.0)
 if quest >= 3 and quest <= 5:
  draw_line(player_pos,marker,Color(0.36,0.86,1.0,0.18),2.0,true)
  draw_circle(marker,15.0+sin(now*5.0)*3.0,Color(0.3,0.85,1.0,0.22))
  draw_arc(marker,23.0,0.0,TAU,32,Color(0.55,0.94,1.0,0.85),3.0,true)
  draw_string(font,marker+Vector2(-50,-28),"CEL ZADANIA",HORIZONTAL_ALIGNMENT_CENTER,-1,14,Color(0.72,0.96,1.0,0.95))

func _draw_crypt_landmarks(now: float) -> void:
 var pulse := 0.72 + sin(now*2.6)*0.18
 draw_ellipse_shadow(CRYPT_RELIC+Vector2(0,62),160.0,30.0)
 draw_circle(CRYPT_RELIC,86.0,Color(0.22,0.86,0.94,0.08*pulse))
 draw_arc(CRYPT_RELIC,69.0,now*0.22,now*0.22+TAU,56,Color(0.48,0.92,1.0,0.66*pulse),3.0,true)
 draw_colored_polygon(PackedVector2Array([
  CRYPT_RELIC+Vector2(0,-58),CRYPT_RELIC+Vector2(34,-9),CRYPT_RELIC+Vector2(25,43),
  CRYPT_RELIC+Vector2(0,59),CRYPT_RELIC+Vector2(-28,35),CRYPT_RELIC+Vector2(-38,-12)
 ]),Color("#5de0df") if crypt_guardian_defeated else Color("#668eac"))
 draw_colored_polygon(PackedVector2Array([
  CRYPT_RELIC+Vector2(0,-58),CRYPT_RELIC+Vector2(0,43),CRYPT_RELIC+Vector2(-28,35),CRYPT_RELIC+Vector2(-38,-12)
 ]),Color(0.76,0.98,1.0,0.78))
 draw_line(CRYPT_RELIC+Vector2(0,-43),CRYPT_RELIC+Vector2(0,43),Color("#e5ffff"),2.0,true)
 draw_string(ThemeDB.fallback_font,CRYPT_RELIC+Vector2(-82,-78),"GEODOWY RDZEŃ",HORIZONTAL_ALIGNMENT_CENTER,-1,16,Color("#b8f8f4"))
 var exit_pulse := 0.68 + sin(now*3.2+1.0)*0.2
 draw_circle(CRYPT_EXIT,52.0,Color(0.28,0.85,0.92,0.08*exit_pulse))
 draw_arc(CRYPT_EXIT,43.0,now*0.42,now*0.42+TAU,48,Color(0.46,0.91,0.96,0.9),4.0,true)
 draw_arc(CRYPT_EXIT,31.0,-now*0.58,-now*0.58+PI*1.6,36,Color(0.85,0.98,1.0,0.72),2.0,true)
 draw_string(ThemeDB.fallback_font,CRYPT_EXIT+Vector2(-58,66),"POWRÓT",HORIZONTAL_ALIGNMENT_CENTER,-1,13,Color("#a7f4f0"))


func _draw_verdant_landmarks(now: float) -> void:
 var pulse := 0.72 + sin(now*2.2)*0.18
 draw_ellipse_shadow(VERDANT_RELIC+Vector2(0,72),190.0,34.0)
 draw_circle(VERDANT_RELIC,102.0,Color(0.28,0.86,0.47,0.08*pulse))
 draw_arc(VERDANT_RELIC,82.0,now*0.18,now*0.18+TAU,64,Color(0.48,0.91,0.56,0.68*pulse),3.5,true)
 draw_arc(VERDANT_RELIC,61.0,-now*0.28,-now*0.28+PI*1.55,48,Color(0.76,0.96,0.61,0.72),2.0,true)
 draw_colored_polygon(PackedVector2Array([
  VERDANT_RELIC+Vector2(0,-68),VERDANT_RELIC+Vector2(26,-26),VERDANT_RELIC+Vector2(21,28),
  VERDANT_RELIC+Vector2(0,58),VERDANT_RELIC+Vector2(-22,31),VERDANT_RELIC+Vector2(-28,-23)
 ]),Color("#79c77a") if verdant_guardian_defeated else Color("#486b55"))
 draw_colored_polygon(PackedVector2Array([
  VERDANT_RELIC+Vector2(0,-68),VERDANT_RELIC+Vector2(0,46),VERDANT_RELIC+Vector2(-22,31),VERDANT_RELIC+Vector2(-28,-23)
 ]),Color(0.76,0.96,0.7,0.8))
 draw_line(VERDANT_RELIC+Vector2(0,-48),VERDANT_RELIC+Vector2(0,45),Color("#e4ffd0"),2.0,true)
 draw_string(ThemeDB.fallback_font,VERDANT_RELIC+Vector2(-94,-86),"SERCE SPLOTU",HORIZONTAL_ALIGNMENT_CENTER,-1,16,Color("#d6f3c2"))
 for root_index in range(6):
  var angle := TAU*float(root_index)/6.0+now*0.08
  var root_start := VERDANT_RELIC+Vector2.RIGHT.rotated(angle)*76.0
  var root_end := VERDANT_RELIC+Vector2.RIGHT.rotated(angle+0.16)*122.0
  draw_line(root_start,root_end,Color(0.36,0.67,0.38,0.7),7.0,true)
  draw_line(root_start,root_end,Color(0.72,0.86,0.52,0.58),2.0,true)
 var exit_pulse := 0.68 + sin(now*3.0+1.0)*0.2
 draw_circle(VERDANT_EXIT,52.0,Color(0.32,0.82,0.43,0.08*exit_pulse))
 draw_arc(VERDANT_EXIT,43.0,now*0.34,now*0.34+TAU,48,Color(0.57,0.91,0.56,0.9),4.0,true)
 draw_arc(VERDANT_EXIT,30.0,-now*0.48,-now*0.48+PI*1.6,36,Color(0.83,0.97,0.7,0.74),2.0,true)
 draw_string(ThemeDB.fallback_font,VERDANT_EXIT+Vector2(-58,66),"POWRÓT",HORIZONTAL_ALIGNMENT_CENTER,-1,13,Color("#d2efbd"))

func _draw_frost_landmarks(now: float) -> void:
 var pulse := 0.74 + sin(now*2.4)*0.18
 draw_ellipse_shadow(FROST_RELIC+Vector2(0,70),190.0,34.0)
 draw_circle(FROST_RELIC,104.0,Color(0.28,0.78,1.0,0.1*pulse))
 draw_arc(FROST_RELIC,86.0,now*0.2,now*0.2+TAU,64,Color("#8be8ff"),3.5,true)
 draw_arc(FROST_RELIC,62.0,-now*0.31,-now*0.31+PI*1.55,48,Color("#e0fcff"),2.2,true)
 draw_colored_polygon(PackedVector2Array([
  FROST_RELIC+Vector2(0,-70),FROST_RELIC+Vector2(28,-25),FROST_RELIC+Vector2(22,32),
  FROST_RELIC+Vector2(0,62),FROST_RELIC+Vector2(-24,34),FROST_RELIC+Vector2(-30,-24)
 ]),Color("#7ce7f8") if frost_guardian_defeated else Color("#4b7898"))
 draw_colored_polygon(PackedVector2Array([
  FROST_RELIC+Vector2(0,-70),FROST_RELIC+Vector2(0,48),FROST_RELIC+Vector2(-24,34),FROST_RELIC+Vector2(-30,-24)
 ]),Color(0.84,0.98,1.0,0.82))
 draw_line(FROST_RELIC+Vector2(0,-50),FROST_RELIC+Vector2(0,48),Color("#f0ffff"),2.2,true)
 draw_string(ThemeDB.fallback_font,FROST_RELIC+Vector2(-112,-88),"SERCE BURZOWEGO KRYSZTAŁU",HORIZONTAL_ALIGNMENT_CENTER,-1,15,Color("#d4f8ff"))
 for shard_index in range(8):
  var angle := TAU*float(shard_index)/8.0-now*0.1
  var shard_start := FROST_RELIC+Vector2.RIGHT.rotated(angle)*88.0
  var shard_end := FROST_RELIC+Vector2.RIGHT.rotated(angle+0.08)*126.0
  draw_line(shard_start,shard_end,Color(0.54,0.85,1.0,0.72),5.0,true)
  draw_line(shard_start,shard_end,Color(0.9,0.99,1.0,0.75),1.5,true)
 var exit_pulse := 0.7 + sin(now*3.1+0.8)*0.18
 draw_circle(FROST_EXIT,54.0,Color(0.32,0.8,1.0,0.1*exit_pulse))
 draw_arc(FROST_EXIT,44.0,now*0.38,now*0.38+TAU,48,Color("#8be7ff"),4.0,true)
 draw_arc(FROST_EXIT,31.0,-now*0.52,-now*0.52+PI*1.6,36,Color("#e0fbff"),2.0,true)
 draw_string(ThemeDB.fallback_font,FROST_EXIT+Vector2(-58,66),"POWRÓT",HORIZONTAL_ALIGNMENT_CENTER,-1,13,Color("#c8f4ff"))

func _draw_region_landmarks(now: float) -> void:
 var positions := [
  Vector2(545,460),Vector2(540,790),Vector2(1650,300),Vector2(1085,465),
  Vector2(625,1265),Vector2(1780,800),Vector2(1790,1270),Vector2(1010,930)
 ]
 var tints := [
  Color("#f1d08b"),Color("#a7e8a4"),Color("#c8efff"),Color("#83e9f4"),
  Color("#ffd58a"),Color("#d9c5a0"),Color("#ff9c70"),Color("#a5f4eb")
 ]
 var landmark_size := 132.0
 for index in range(positions.size()):
  var landmark_pos: Vector2 = positions[index]
  var discovered := discovered_regions.has(REGION_NAMES[index])
  var tint: Color = tints[index]
  var pulse := 0.72 + sin(now*1.6+float(index)*0.8)*0.12
  draw_ellipse_shadow(landmark_pos+Vector2(0,48),96.0,22.0)
  draw_circle(landmark_pos,76.0,Color(tint.r,tint.g,tint.b,0.075 if discovered else 0.028))
  var icon_tint := Color.WHITE if discovered else Color(0.78,0.86,0.9,0.88)
  draw_texture_rect_region(
   REGION_LANDMARK_ATLAS,
   Rect2(landmark_pos-Vector2.ONE*(landmark_size*0.5),Vector2.ONE*landmark_size),
   Rect2(index*192,0,192,192),
   icon_tint,
   false
  )
  if discovered:
   draw_arc(landmark_pos+Vector2(0,12),73.0,now*0.12+float(index),now*0.12+float(index)+PI*1.55,36,Color(tint.r,tint.g,tint.b,pulse*0.58),2.2,true)

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
 var is_frost_boss := bool(enemy.get("is_frost_boss",false))
 var sprite_size := 126.0 if is_boss else 80.0
 var now := float(Time.get_ticks_msec()) / 1000.0
 var distance_to_player := player_pos.distance_to(p)
 var attack_range := 112.0 if is_boss else 48.0
 var chasing := distance_to_player < 300.0
 var windup_left := float(enemy.get("windup",0.0))
 var windup_total := maxf(0.01,float(enemy.get("windup_total",0.52)))
 var warning_progress := clampf(1.0-windup_left/windup_total,0.0,1.0) if windup_left > 0.0 else 0.0
 var is_moving := chasing and distance_to_player > attack_range and windup_left <= 0.0
 var attacking := float(enemy.get("attack_anim",0.0)) > 0.0
 var phase := float(enemy.get("walk_phase",0.0))
 var stride := sin(phase*2.0)
 var hoverer := kind == 3 or kind == 5 or kind == 12 or kind == 13
 var idle_bob := sin(now*(2.7 if hoverer else 1.8)+float(kind)*0.73)
 var bob := (stride*2.6+absf(stride)*1.5) if is_moving else idle_bob*(3.2 if hoverer else 1.25)
 var frame := int(floor(phase*1.3)) % 2 if is_moving else 0
 var enemy_facing: Vector2 = enemy.get("facing",Vector2.DOWN)
 var lunge := enemy_facing * (7.0 if attacking else 0.0)
 var recoil := -enemy_facing * warning_progress * (8.0 if is_boss else 4.0)
 var body_color := Color(1.0,0.55,0.48,1.0) if float(enemy.get("hit_flash",0.0)) > 0.0 else Color.WHITE
 draw_ellipse_shadow(p+Vector2(0,13),sprite_size*0.48*(1.0+absf(stride)*0.025),14.0 if is_boss else 8.0)
 if windup_left > 0.0:
  var glyph_rotation := now * 0.32
  var warning_tint := Color("#82e4ff") if is_frost_boss else (Color("#a8e99c") if bool(enemy.get("is_verdant_boss",false)) else Color(1.0,0.32,0.2,0.55))
  _draw_eterium_glyph(p,0,290.0 if is_boss else 118.0,glyph_rotation,warning_tint)
  var warning_alpha := 0.42+warning_progress*0.48
  if is_boss:
   var warning_circle := Color("#82e4ff") if is_frost_boss else Color(1.0,0.28,0.2,1.0)
   draw_circle(p,112.0,Color(warning_circle.r,warning_circle.g,warning_circle.b,0.035+warning_progress*0.045))
   draw_arc(p,112.0,0.0,TAU,56,Color(warning_circle.r,warning_circle.g,warning_circle.b,warning_alpha),4.5,true)
  else:
   var warning_angle := enemy_facing.angle()
   draw_arc(p,43.0,warning_angle-0.82,warning_angle+0.82,24,Color(1.0,0.32,0.2,warning_alpha),4.0,true)
   draw_line(p,p+enemy_facing*48.0,Color(1.0,0.4,0.25,warning_alpha),3.0,true)
 if is_boss:
  var boss_pulse := 0.72 + sin(now/0.19)*0.16
  var boss_ring := Color("#82dfff") if is_frost_boss else (Color("#9cdd8e") if bool(enemy.get("is_verdant_boss",false)) else Color("#ef7165"))
  draw_circle(p,76.0,Color(boss_ring.r,boss_ring.g,boss_ring.b,0.09*boss_pulse))
  draw_arc(p,72.0,now*0.12,now*0.12+TAU,48,Color(boss_ring.r,boss_ring.g,boss_ring.b,0.55+boss_pulse*0.12),4.0,true)
 if attacking:
  var attack_progress := 1.0 - float(enemy.get("attack_anim",0.0))/0.34
  var attack_tint := Color("#82e4ff") if is_frost_boss else Color(1.0,0.28,0.22,1.0)
  draw_arc(p,37.0 if not is_boss else 66.0,0.0,TAU,28,Color(attack_tint.r,attack_tint.g,attack_tint.b,0.72),3.0,true)
  if is_boss:
   var shock_radius := 42.0 + attack_progress*54.0
   draw_arc(p,shock_radius,0.0,TAU,40,Color(attack_tint.r,attack_tint.g,attack_tint.b,1.0-attack_progress),5.0,true)
 # Regional creatures keep their original silhouette, but now turn toward the target,
 # lean into vertical movement, and use a per-creature gait instead of a global timer.
 var flip_x := -1.0 if enemy_facing.x < -0.12 else 1.0
 var gait := absf(stride) if is_moving else 0.0
 var sprite_scale := Vector2(flip_x*(1.0+gait*0.035),1.0-gait*0.045)
 var sprite_rotation := clampf(enemy_facing.y*0.055+(0.06 if attacking else -warning_progress*0.035),-0.09,0.09)
 var sprite_center := p+lunge+recoil+Vector2(0,bob)
 draw_set_transform(sprite_center,sprite_rotation,sprite_scale)
 var sprite_rect := Rect2(-sprite_size*0.5,-sprite_size*0.55,sprite_size,sprite_size)
 if bool(enemy.get("is_crypt_boss",false)):
  draw_texture_rect(CRYSTAL_GUARDIAN_TEXTURE,sprite_rect,false,body_color)
 elif bool(enemy.get("is_verdant_boss",false)):
  draw_texture_rect(VERDANT_GUARDIAN_TEXTURE,sprite_rect,false,body_color)
 elif bool(enemy.get("is_frost_boss",false)):
  draw_texture_rect(FROST_GUARDIAN_TEXTURE,sprite_rect,false,body_color)
 elif is_boss:
  draw_texture_rect_region(SPRITE_ATLAS,sprite_rect,Rect2((5+kind)*128,frame*128,128,128),body_color,false)
 else:
  draw_texture_rect_region(REGION_CREATURE_ATLAS,sprite_rect,Rect2(kind*128,0,128,128),body_color,false)
 draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
 if is_moving:
  var dust_color := Color(0.63,0.78,0.69,0.18) if kind < 2 else Color(0.61,0.79,0.91,0.16)
  for dust_index in range(2):
   var dust_pos := p-enemy_facing*(18.0+float(dust_index)*9.0)+Vector2(0,8.0+float(dust_index)*3.0)
   draw_circle(dust_pos,3.0-float(dust_index)*0.7,dust_color)
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
 var hp_bar_color := Color("#57cce8") if is_frost_boss else (Color("#e34d5c") if is_boss else Color("#d94d52"))
 draw_rect(Rect2(p.x-bar_width*0.5+1,bar_y+1,(bar_width-2)*maxf(0.0,float(enemy["hp"])/float(enemy["max_hp"])),4 if is_boss else 3),hp_bar_color)
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
  _draw_eterium_glyph(attack_target,2,82.0+progress*54.0,now*1.8,Color(0.48,0.9,1.0,1.0-progress*0.35))
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
  _draw_eterium_glyph(attack_target,1,62.0+sin(progress*PI)*24.0,attack_angle+sweep,Color(0.72,0.97,1.0,1.0-progress*0.35))
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
  _draw_eterium_glyph(player_pos,0,maxf(92.0,radius*1.95),-now*0.72,Color(0.42,0.9,1.0,alpha*0.78))
  var pulse := 1.0 + sin(now*24.0)*0.08
  draw_arc(player_pos,radius*pulse,0.0,TAU,48,Color(0.35,0.9,1.0,alpha),5.0,true)
  draw_arc(player_pos,radius*0.78,0.0,TAU,48,Color(0.75,0.98,1.0,alpha*0.65),2.0,true)
  for i in range(8):
   var angle := TAU*float(i)/8.0 + now*1.8
   var inner := player_pos + Vector2.RIGHT.rotated(angle)*(radius*0.72)
   var outer := player_pos + Vector2.RIGHT.rotated(angle)*(radius*1.08)
   draw_line(inner,outer,Color(0.55,0.95,1.0,alpha*0.8),3.0,true)
  draw_circle(player_pos,12.0+progress*9.0,Color(0.5,0.95,1.0,alpha*0.35))

func _draw_eterium_glyph(center: Vector2, glyph_index: int, size: float, rotation: float, tint: Color) -> void:
 var safe_index := clampi(glyph_index,0,3)
 draw_set_transform(center,rotation,Vector2.ONE*(size/128.0))
 draw_texture_rect_region(ETERIUM_GLYPH_ATLAS,Rect2(-64.0,-64.0,128.0,128.0),Rect2(safe_index*128,0,128,128),tint,false)
 draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_player() -> void:
 var moving: bool = bool(held["left"]) or bool(held["right"]) or bool(held["up"]) or bool(held["down"]) or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")
 var bob := sin(walk_phase)*2.0 if moving else 0.0
 var p := player_pos
 var race_index := maxi(0,RACES.keys().find(race))
 draw_ellipse_shadow(p+Vector2(0,15),25,9)
 var glyph_time := float(Time.get_ticks_msec()) / 1000.0
 if transformed:
  _draw_eterium_glyph(p+Vector2(0,5),3,116.0,glyph_time*0.48,Color(1.0,0.73,0.3,0.56))
 var frame := 1 if moving and int(Time.get_ticks_msec()/145)%2 == 0 else 0
 var invuln_flash := player_invuln > 0.0 and int(Time.get_ticks_msec()/90)%2 == 0
 var hero_tint := Color(1.0,0.55,0.48,1.0) if player_hit_flash > 0.0 else (Color(0.55,0.9,1.0,0.58) if invuln_flash else Color.WHITE)
 var sprite_texture: Texture2D = SPRITE_ATLAS
 var sprite_region := Rect2(race_index*128,frame*128,128,128)
 var sprite_scale := Vector2.ONE
 if absf(player_facing.y) >= absf(player_facing.x) and player_facing.y < 0.0:
  sprite_texture = PLAYER_DIRECTION_ATLAS
  sprite_region = Rect2(race_index*128,frame*128,128,128)
 elif absf(player_facing.x) > absf(player_facing.y):
  sprite_texture = PLAYER_DIRECTION_ATLAS
  sprite_region = Rect2(race_index*128,(2+frame)*128,128,128)
  if player_facing.x < 0.0:
   sprite_scale.x = -1.0
 draw_set_transform(p,0.0,sprite_scale)
 draw_texture_rect_region(sprite_texture,Rect2(-44,-52+bob,88,88),sprite_region,hero_tint,false)
 draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
 if transform_burst > 0.0:
  var burst_progress := 1.0-transform_burst
  _draw_eterium_glyph(p,2,132.0+burst_progress*150.0,glyph_time*1.1,Color(1.0,0.82,0.43,transform_burst*0.86))
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
