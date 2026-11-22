extends SceneTree

const GAME_SCRIPT = preload("res://scripts/game.gd")
const SANCTUM_TEXTURE = preload("res://assets/aetherion_frost_sanctum.svg")
const GUARDIAN_TEXTURE = preload("res://assets/aetherion_stormwarden.svg")

var failures := 0

func _initialize() -> void:
 call_deferred("_run_tests")

func _run_tests() -> void:
 var game = GAME_SCRIPT.new()
 root.add_child(game)
 await process_frame

 _test_v6_migration(game)
 game._start_game("Terranie")
 _check(game.enemies.size() == 18, "starting a new game rebuilds all overworld encounters")
 var world_enemy: Dictionary = game.enemies[0]
 world_enemy["hp"] = 29.0
 game.enemies[0] = world_enemy
 game.player_pos = GAME_SCRIPT.FROST_ENTRY
 var overworld_return: Vector2 = game.player_pos
 game._location_interact()

 _check(game.in_frost_sanctum, "mountain portal enters the Storm Crystal Sanctum")
 _check(not game.in_crystal_sanctum and not game.in_verdant_sanctum, "all three instances remain mutually exclusive")
 _check(game.enemies.size() == 5, "sanctum creates four sentries and one unique guardian")
 _check(game.player_pos.is_equal_approx(GAME_SCRIPT.FROST_START), "entry places the player at the saved frost spawn")
 _check(game.player_pos.distance_to(GAME_SCRIPT.FROST_EXIT) > 112.0, "entry is safely separated from the exit portal")
 _check(SANCTUM_TEXTURE != null and GUARDIAN_TEXTURE != null, "dedicated room and guardian SVG assets load")
 _check(str(game.enemies[4].get("spawn_id","")) == "frost_guardian", "Storm Crystal Warden has a stable spawn ID")

 var guardian_index := _enemy_index_by_id(game,"frost_guardian")
 _check(guardian_index >= 0, "unique Storm Crystal Warden is present")
 var guardian: Dictionary = game.enemies[guardian_index]
 guardian["hp"] = 413.0
 game.enemies[guardian_index] = guardian
 game.player_pos = Vector2(720,610)
 game.loot_drops.append({"item":"Odłamek Eterium","pos":Vector2(710,620),"life":42.0})
 game._save_game(true)
 guardian["hp"] = 1.0
 game.enemies[guardian_index] = guardian
 game._load_game()

 _check(game.in_frost_sanctum, "save restores the active frost instance")
 guardian_index = _enemy_index_by_id(game,"frost_guardian")
 _check(guardian_index >= 0 and is_equal_approx(float(game.enemies[guardian_index].get("hp",0.0)),413.0), "v7 restores the Storm Warden health")
 _check(game.player_pos.is_equal_approx(Vector2(720,610)), "v7 restores the player position inside the sanctum")
 _check(game.loot_drops.size() == 1 and str(game.loot_drops[0].get("item","")) == "Odłamek Eterium", "v7 restores sanctum loot drops")
 _check(is_equal_approx(float(game.overworld_enemies[0].get("hp",0.0)),29.0), "overworld enemy state remains isolated while inside")
 _check(game.overworld_player_pos.is_equal_approx(overworld_return), "overworld return position is preserved")

 guardian_index = _enemy_index_by_id(game,"frost_guardian")
 guardian = game.enemies[guardian_index]
 guardian["hp"] = 1.0
 game.enemies[guardian_index] = guardian
 var gold_before_boss: int = game.gold
 game._kill_enemy(guardian_index)
 _check(game.frost_guardian_defeated, "defeating the Warden unlocks the Storm Heart")
 _check(game.gold == gold_before_boss + 180, "boss defeat grants one hundred and eighty gold")

 game.player_pos = GAME_SCRIPT.FROST_RELIC
 var shards_before := int(game.inventory.get("Odłamek Eterium",0))
 var hides_before := int(game.inventory.get("Skóra bestii",0))
 var gold_before_relic: int = game.gold
 game._location_interact()
 _check(game.frost_relic_claimed, "the Storm Heart can be released after the guardian falls")
 _check(int(game.inventory.get("Odłamek Eterium",0)) == shards_before + 3, "relic grants three Etherium shards")
 _check(int(game.inventory.get("Skóra bestii",0)) == hides_before + 2, "relic grants two beast hides")
 _check(game.gold == gold_before_relic + 130, "relic grants one hundred and thirty gold")

 game._save_game(true)
 game.frost_relic_claimed = false
 game._load_game()
 _check(game.frost_relic_claimed, "released relic state survives a reload")
 guardian_index = _enemy_index_by_id(game,"frost_guardian")
 _check(guardian_index >= 0 and not bool(game.enemies[guardian_index].get("alive",true)), "defeated guardian remains defeated after reload")

 game.player_pos = GAME_SCRIPT.FROST_EXIT
 game._location_interact()
 _check(not game.in_frost_sanctum, "exit portal returns to the overworld")
 _check(game.player_pos.is_equal_approx(overworld_return), "exit restores the exact overworld position")
 _check(is_equal_approx(float(game.enemies[0].get("hp",0.0)),29.0), "overworld enemy health remains intact after returning")

 game.queue_free()
 await process_frame
 var save_path := ProjectSettings.globalize_path("user://aetherion_save.json")
 if FileAccess.file_exists("user://aetherion_save.json"):
  DirAccess.remove_absolute(save_path)
 if failures == 0:
  print("AETHERION_FROST_TESTS: PASS")
  quit(0)
 else:
  push_error("AETHERION_FROST_TESTS: FAIL (%d checks)" % failures)
  quit(1)

func _test_v6_migration(game) -> void:
 var legacy_save := {
  "save_version": 6,
  "race": "Terranie",
  "pos": [510.0, 390.0],
  "overworld_pos": [510.0, 390.0],
  "in_crystal_sanctum": false,
  "in_verdant_sanctum": false,
  "level": 2,
  "xp": 12,
  "gold": 77,
  "hp": 118.0,
  "ether": 84.0,
  "inventory": {"Mikstura HP": 2, "Odłamek Eterium": 1, "Skóra bestii": 2},
  "equipment": {"Broń": "Ostrze Wędrowca", "Pancerz": "Tunika Wędrowca"},
  "owned_gear": ["Ostrze Wędrowca", "Tunika Wędrowca"],
  "enemy_states": [],
  "crypt_enemy_states": [],
  "verdant_enemy_states": [],
  "loot_drops": [],
  "crypt_loot_drops": [],
  "verdant_loot_drops": [],
  "discovered_regions": ["Kamienny Krąg", "Korona Gór"]
 }
 _write_save(legacy_save)
 game._load_game()
 _check(game.started, "legacy v6 save opens in the new version")
 _check(not game.in_frost_sanctum, "v6 migration defaults the new location to inactive")
 _check(game.level == 2 and game.gold == 77, "v6 migration preserves character progression")
 _check(game.frost_player_pos.is_equal_approx(GAME_SCRIPT.FROST_START), "v6 migration supplies a safe default frost position")

func _enemy_index_by_id(game, spawn_id: String) -> int:
 for index in range(game.enemies.size()):
  if str(game.enemies[index].get("spawn_id","")) == spawn_id:
   return index
 return -1

func _write_save(data: Dictionary) -> void:
 var file := FileAccess.open("user://aetherion_save.json",FileAccess.WRITE)
 if file == null:
  _check(false,"legacy v6 save can be written")
  return
 file.store_string(JSON.stringify(data))
 file.close()

func _check(condition: bool, label: String) -> void:
 if condition:
  print("PASS: " + label)
 else:
  failures += 1
  push_error("FAIL: " + label)
