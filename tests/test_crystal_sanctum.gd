extends SceneTree

const GAME_SCRIPT = preload("res://scripts/game.gd")
const CRYPT_TEXTURE = preload("res://assets/aetherion_crystal_sanctum.svg")
const GUARDIAN_TEXTURE = preload("res://assets/aetherion_crystal_guardian.svg")

var failures := 0

func _initialize() -> void:
 call_deferred("_run_tests")

func _run_tests() -> void:
 var game = GAME_SCRIPT.new()
 root.add_child(game)
 await process_frame
 game._start_game("Terranie")
 game.player_pos = game.CRYPT_ENTRY
 game._update_region(false)
 var overworld_return := game.player_pos
 var world_enemy: Dictionary = game.enemies[0]
 world_enemy["hp"] = 31.0
 game.enemies[0] = world_enemy

 game._location_interact()
 _check(game.in_crystal_sanctum, "portal enters a separate crystal sanctum")
 _check(game.enemies.size() == 5, "sanctum creates four sentries and one guardian")
 _check(game.player_pos.is_equal_approx(game.CRYPT_START), "entry places the player inside the instance")
 _check(CRYPT_TEXTURE != null and GUARDIAN_TEXTURE != null, "dedicated room and guardian SVG assets load")

 var guardian_index := _enemy_index_by_id(game,"crypt_guardian")
 _check(guardian_index >= 0, "unique Geode Matriarch is present")
 var guardian: Dictionary = game.enemies[guardian_index]
 guardian["hp"] = 234.0
 game.enemies[guardian_index] = guardian
 game._save_game(true)
 guardian["hp"] = 1.0
 game.enemies[guardian_index] = guardian
 game._load_game()

 _check(game.in_crystal_sanctum, "save restores the active instance")
 _check(game.enemies[_enemy_index_by_id(game,"crypt_guardian")].get("hp",0.0) == 234.0, "save restores guardian health")
 _check(game.overworld_enemies[0].get("hp",0.0) == 31.0, "overworld enemy state is preserved while inside")
 _check(game.overworld_player_pos.is_equal_approx(overworld_return), "overworld return position is preserved")

 guardian_index = _enemy_index_by_id(game,"crypt_guardian")
 guardian = game.enemies[guardian_index]
 guardian["hp"] = 1.0
 game.enemies[guardian_index] = guardian
 game._kill_enemy(guardian_index)
 _check(game.crypt_guardian_defeated, "defeating the Geode Matriarch unlocks the relic")
 game.player_pos = game.CRYPT_RELIC
 var shards_before := int(game.inventory.get("Odłamek Eterium",0))
 game._location_interact()
 _check(game.crypt_relic_claimed, "relic can be claimed after the guardian falls")
 _check(int(game.inventory.get("Odłamek Eterium",0)) == shards_before + 4, "relic grants four Etherium shards")

 game._save_game(true)
 game.crypt_relic_claimed = false
 game._load_game()
 _check(game.crypt_relic_claimed, "claimed relic state survives a reload")
 game.player_pos = game.CRYPT_EXIT
 game._location_interact()
 _check(not game.in_crystal_sanctum, "exit portal returns to the overworld")
 _check(game.player_pos.is_equal_approx(overworld_return), "exit restores the exact overworld position")
 _check(game.enemies[0].get("hp",0.0) == 31.0, "overworld enemy health remains intact after returning")

 game.queue_free()
 await process_frame
 if FileAccess.file_exists("user://aetherion_save.json"):
  DirAccess.remove_absolute(ProjectSettings.globalize_path("user://aetherion_save.json"))
 if failures == 0:
  print("AETHERION_CRYPT_TESTS: PASS")
  quit(0)
 else:
  push_error("AETHERION_CRYPT_TESTS: FAIL (%d checks)" % failures)
  quit(1)

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
