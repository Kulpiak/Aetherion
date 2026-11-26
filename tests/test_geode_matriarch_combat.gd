extends SceneTree

const GAME_SCRIPT = preload("res://scripts/game.gd")
const GEODE_TEXTURE = preload("res://assets/aetherion_geode_shard.svg")

var failures := 0

func _initialize() -> void:
 call_deferred("_run_tests")

func _run_tests() -> void:
 if FileAccess.file_exists("user://aetherion_save.json"):
  DirAccess.remove_absolute(ProjectSettings.globalize_path("user://aetherion_save.json"))

 var game = GAME_SCRIPT.new()
 root.add_child(game)
 await process_frame
 game.set_process(false)
 game._start_game("Terranie")
 game._enter_crystal_sanctum()
 _test_geode_sequence(game)

 game.queue_free()
 await process_frame
 if FileAccess.file_exists("user://aetherion_save.json"):
  DirAccess.remove_absolute(ProjectSettings.globalize_path("user://aetherion_save.json"))

 if failures == 0:
  print("AETHERION_GEODE_COMBAT_TESTS: PASS")
  quit(0)
 else:
  push_error("AETHERION_GEODE_COMBAT_TESTS: FAIL (%d checks)" % failures)
  quit(1)

func _test_geode_sequence(game) -> void:
 var boss_index := _boss_index(game)
 _check(boss_index >= 0, "Geode Matriarch exists in the Crystal Sanctum")
 if boss_index < 0:
  return

 var boss: Dictionary = game.enemies[boss_index]
 _check(bool(boss.get("is_crypt_boss",false)), "the encounter is identified as the unique Geode boss")
 _check(GEODE_TEXTURE != null, "the dedicated crystal shard SVG loads as a game texture")
 _check(GAME_SCRIPT.CRYPT_GEODE_RANGE > GAME_SCRIPT.CRYPT_GEODE_RADIUS, "the boss telegraphs before the danger zone")
 _check(GAME_SCRIPT.CRYPT_GEODE_WAVE_COUNT == 3, "the crystal split has three sequential waves")

 for index in range(game.enemies.size()):
  if index != boss_index:
   var sentry: Dictionary = game.enemies[index]
   sentry["alive"] = false
   sentry["respawn"] = 0.0
   game.enemies[index] = sentry

 var target := Vector2(640.0,590.0)
 game.player_pos = target
 game.player_invuln = 0.0
 game.dash_anim = 0.0
 boss = game.enemies[boss_index]
 boss["timer"] = 1.31
 boss["windup"] = 0.0
 game.enemies[boss_index] = boss
 game._process(0.01)

 boss = game.enemies[boss_index]
 var locked_targets: Array = boss.get("geode_targets",[])
 _check(bool(boss.get("geode_attack_active",false)), "the Matriarch starts its crystal-split sequence")
 _check(locked_targets.size() == GAME_SCRIPT.CRYPT_GEODE_WAVE_COUNT, "three independent danger points are generated")
 _check(int(boss.get("geode_wave_index",-1)) == 0, "the first crystal is charged before the later waves")
 _check(float(boss.get("geode_wave_left",0.0)) > 0.0, "the first crystal has a readable warning countdown")
 _check(float(boss.get("windup",0.0)) == 0.0, "the Geode attack uses its own sequence instead of the generic boss windup")

 var targets_are_valid := true
 var targets_are_distinct := true
 for index in range(locked_targets.size()):
  var point: Vector2 = locked_targets[index]
  if point.x < GAME_SCRIPT.CRYPT_GEODE_RADIUS or point.x > GAME_SCRIPT.CRYPT_SIZE.x-GAME_SCRIPT.CRYPT_GEODE_RADIUS or point.y < GAME_SCRIPT.CRYPT_GEODE_RADIUS or point.y > GAME_SCRIPT.CRYPT_SIZE.y-GAME_SCRIPT.CRYPT_GEODE_RADIUS:
   targets_are_valid = false
  for other_index in range(index):
   var other_point: Vector2 = locked_targets[other_index]
   if point.distance_to(other_point) <= GAME_SCRIPT.CRYPT_GEODE_RADIUS*2.0:
    targets_are_distinct = false
 _check(targets_are_valid, "all crystal danger points stay inside the sanctum bounds")
 _check(targets_are_distinct, "the three crystal danger zones do not overlap")

 var first_target: Vector2 = locked_targets[0]
 var second_target: Vector2 = locked_targets[1]
 var third_target: Vector2 = locked_targets[2]
 game.player_pos = target + Vector2(150.0,0.0)
 game._process(GAME_SCRIPT.CRYPT_GEODE_WINDUP+0.01)
 boss = game.enemies[boss_index]
 var targets_after_move: Array = boss.get("geode_targets",[])
 _check(targets_after_move[0].is_equal_approx(first_target), "the marked crystal sequence does not track the moving player")
 _check(is_equal_approx(game.hp,125.0), "leaving the first crystal zone avoids its explosion")
 _check(boss.get("geode_blast_center",Vector2.ZERO).is_equal_approx(first_target), "the first explosion resolves at its locked crystal point")
 _check(int(boss.get("geode_wave_index",0)) == 1, "the first explosion advances to the second crystal")
 _check(float(boss.get("geode_wave_left",0.0)) > 0.0, "the second crystal receives a separate warning interval")
 _check(is_equal_approx(float(boss.get("attack_anim",0.0)),GAME_SCRIPT.CRYPT_GEODE_ACTIVE), "the crystal impact uses its full visual burst duration")

 game.player_pos = second_target
 game.hp = 100.0
 game.player_invuln = 0.0
 game._process(GAME_SCRIPT.CRYPT_GEODE_WAVE_INTERVAL+0.01)
 boss = game.enemies[boss_index]
 _check(is_equal_approx(game.hp,80.0), "standing in the second crystal zone applies defense-reduced damage")
 _check(int(boss.get("geode_wave_index",0)) == 2, "the second explosion advances to the third crystal")

 game.player_pos = third_target
 game.hp = 100.0
 game.player_invuln = 0.0
 game._process(GAME_SCRIPT.CRYPT_GEODE_WAVE_INTERVAL+0.01)
 boss = game.enemies[boss_index]
 _check(is_equal_approx(game.hp,80.0), "the final crystal zone also applies damage when not avoided")
 _check(not bool(boss.get("geode_attack_active",true)), "the three-wave sequence ends after the final explosion")
 _check(int(boss.get("geode_wave_index",0)) == GAME_SCRIPT.CRYPT_GEODE_WAVE_COUNT, "all three crystal waves resolve in order")

 var single_target: Array[Vector2] = [target]
 game.player_pos = target
 game.hp = 100.0
 game.player_invuln = 0.0
 game.dash_anim = 0.2
 game.dash_from = target
 game.dash_to = target
 boss = game.enemies[boss_index]
 boss["geode_attack_active"] = true
 boss["geode_targets"] = single_target
 boss["geode_wave_index"] = 0
 boss["geode_wave_left"] = 0.05
 boss["geode_charge_total"] = 0.05
 game.enemies[boss_index] = boss
 game._process(0.06)
 _check(is_equal_approx(game.hp,100.0), "an active Eterium Dash avoids a crystal explosion")

 game.player_pos = target
 game.hp = 100.0
 game.player_invuln = 0.5
 game.dash_anim = 0.0
 boss = game.enemies[boss_index]
 boss["geode_attack_active"] = true
 boss["geode_targets"] = single_target
 boss["geode_wave_index"] = 0
 boss["geode_wave_left"] = 0.05
 boss["geode_charge_total"] = 0.05
 game.enemies[boss_index] = boss
 game._process(0.06)
 _check(is_equal_approx(game.hp,100.0), "existing hit invulnerability prevents a second crystal hit")

func _boss_index(game) -> int:
 for index in range(game.enemies.size()):
  if str(game.enemies[index].get("spawn_id","")) == "crypt_guardian":
   return index
 return -1

func _check(condition: bool, label: String) -> void:
 if condition:
  print("PASS: " + label)
 else:
  failures += 1
  push_error("FAIL: " + label)
