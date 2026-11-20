extends SceneTree

const GAME_SCRIPT = preload("res://scripts/game.gd")
const SANCTUM_TEXTURE = preload("res://assets/aetherion_verdant_sanctum.svg")
const GUARDIAN_TEXTURE = preload("res://assets/aetherion_rootwarden.svg")

var failures := 0

func _initialize() -> void:
 call_deferred("_run_tests")

func _run_tests() -> void:
 var game = GAME_SCRIPT.new()
 root.add_child(game)
 await process_frame
 _test_v5_migration(game)

 game._start_game("Terranie")
 _check(game.enemies.size() == 18, "starting a new game rebuilds the overworld encounter array")
 var world_enemy: Dictionary = game.enemies[0]
 world_enemy["hp"] = 29.0
 game.enemies[0] = world_enemy
 game.player_pos = GAME_SCRIPT.VERDANT_ENTRY
 var overworld_return: Vector2 = game.player_pos
 game._location_interact()

 _check(game.in_verdant_sanctum, "forest portal enters a separate Rootweave Sanctum")
 _check(not game.in_crystal_sanctum, "the two instances remain mutually exclusive")
 _check(game.enemies.size() == 5, "sanctum creates four sentries and one unique guardian")
 _check(game.player_pos.is_equal_approx(GAME_SCRIPT.VERDANT_START), "entry restores the saved sanctum position")
 _check(game.player_pos.distance_to(GAME_SCRIPT.VERDANT_EXIT) > 112.0, "entry is safely separated from the exit portal")
 _check(SANCTUM_TEXTURE != null and GUARDIAN_TEXTURE != null, "dedicated forest room and guardian SVG assets load")
 _check(str(game.enemies[4].get("spawn_id","")) == "verdant_guardian", "the Rootweave Guardian has a stable spawn ID")

 var guardian_index := _enemy_index_by_id(game,"verdant_guardian")
 _check(guardian_index >= 0, "unique Rootweave Guardian is present")
 var guardian: Dictionary = game.enemies[guardian_index]
 guardian["hp"] = 317.0
 game.enemies[guardian_index] = guardian
 game._save_game(true)
 guardian["hp"] = 1.0
 game.enemies[guardian_index] = guardian
 game._load_game()

 _check(game.in_verdant_sanctum, "save restores the active forest instance")
 guardian_index = _enemy_index_by_id(game,"verdant_guardian")
 _check(guardian_index >= 0 and is_equal_approx(float(game.enemies[guardian_index].get("hp",0.0)),317.0), "v6 restores the Rootweave Guardian health")
 _check(is_equal_approx(float(game.overworld_enemies[0].get("hp",0.0)),29.0), "world enemy state remains isolated while inside")
 _check(game.overworld_player_pos.is_equal_approx(overworld_return), "overworld return position is preserved")

 guardian_index = _enemy_index_by_id(game,"verdant_guardian")
 guardian = game.enemies[guardian_index]
 guardian["hp"] = 1.0
 game.enemies[guardian_index] = guardian
 game._kill_enemy(guardian_index)
 _check(game.verdant_guardian_defeated, "defeating the guardian unlocks the Heart of the Weave")
 game.player_pos = GAME_SCRIPT.VERDANT_RELIC
 var shards_before := int(game.inventory.get("Odłamek Eterium",0))
 var skins_before := int(game.inventory.get("Skóra bestii",0))
 var gold_before: int = int(game.gold)
 game._location_interact()
 _check(game.verdant_relic_claimed, "the Heart of the Weave can be cleansed after the guardian falls")
 _check(int(game.inventory.get("Odłamek Eterium",0)) == shards_before+2, "relic grants two Etherium shards")
 _check(int(game.inventory.get("Skóra bestii",0)) == skins_before+3, "relic grants three beast hides")
 _check(game.gold == gold_before+110, "relic grants one hundred and ten gold")

 game._save_game(true)
 game.verdant_relic_claimed = false
 game._load_game()
 _check(game.verdant_relic_claimed, "cleansed relic state survives a reload")
 guardian_index = _enemy_index_by_id(game,"verdant_guardian")
 _check(guardian_index >= 0 and not bool(game.enemies[guardian_index].get("alive",true)), "defeated guardian remains defeated after reload")

 game.player_pos = GAME_SCRIPT.VERDANT_EXIT
 game._location_interact()
 _check(not game.in_verdant_sanctum, "exit portal returns to the overworld")
 _check(game.player_pos.is_equal_approx(overworld_return), "exit restores the exact overworld position")
 _check(is_equal_approx(float(game.enemies[0].get("hp",0.0)),29.0), "overworld enemy health remains intact after returning")

 game.queue_free()
 await process_frame
 var save_path := ProjectSettings.globalize_path("user://aetherion_save.json")
 if FileAccess.file_exists("user://aetherion_save.json"):
  DirAccess.remove_absolute(save_path)
 if failures == 0:
  print("AETHERION_VERDANT_TESTS: PASS")
  quit(0)
 else:
  push_error("AETHERION_VERDANT_TESTS: FAIL (%d checks)" % failures)
  quit(1)

func _test_v5_migration(game) -> void:
 var legacy_save := {
  "save_version":5,
  "race":"Varkari",
  "pos":[500.0,400.0],
  "overworld_pos":[500.0,400.0],
  "in_crystal_sanctum":false,
  "crypt_guardian_defeated":false,
  "crypt_relic_claimed":false,
  "level":2,
  "xp":12,
  "gold":61,
  "hp":120.0,
  "ether":85.0,
  "inventory":{"Mikstura HP":2,"Odłamek Eterium":1,"Skóra bestii":2},
  "equipment":{"Broń":"Ostrze Wędrowca","Pancerz":"Tunika Wędrowca"},
  "owned_gear":["Ostrze Wędrowca","Tunika Wędrowca"],
  "enemy_states":[],
  "crypt_enemy_states":[],
  "loot_drops":[],
  "crypt_loot_drops":[],
  "discovered_regions":["Kamienny Krąg","Zielone Ostępy"]
 }
 var file := FileAccess.open("user://aetherion_save.json",FileAccess.WRITE)
 if file == null:
  _check(false,"legacy v5 save can be written")
  return
 file.store_string(JSON.stringify(legacy_save))
 file.close()
 game._load_game()
 _check(game.started,"v5 save starts in the new version")
 _check(not game.in_verdant_sanctum,"v5 migration defaults the new location to inactive")
 _check(game.level == 2 and game.gold == 61,"v5 migration preserves character progression")

func _enemy_index_by_id(game, spawn_id: String) -> int:
 for index in range(game.enemies.size()):
  if str(game.enemies[index].get("spawn_id","")) == spawn_id:
   return index
 return -1

func _check(condition: bool, label: String) -> void:
 if condition:
  print("PASS: " + label)
 else:
  failures += 1
  push_error("FAIL: " + label)