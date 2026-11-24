extends SceneTree

const GAME_SCRIPT = preload("res://scripts/game.gd")

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
 game._enter_verdant_sanctum()
 _test_root_snare(game)

 game.queue_free()
 await process_frame
 if FileAccess.file_exists("user://aetherion_save.json"):
  DirAccess.remove_absolute(ProjectSettings.globalize_path("user://aetherion_save.json"))

 if failures == 0:
  print("AETHERION_ROOTWARDEN_COMBAT_TESTS: PASS")
  quit(0)
 else:
  push_error("AETHERION_ROOTWARDEN_COMBAT_TESTS: FAIL (%d checks)" % failures)
  quit(1)

func _test_root_snare(game) -> void:
 var boss_index := _boss_index(game)
 _check(boss_index >= 0, "Root Warden exists in the Verdant Sanctum")
 if boss_index < 0:
  return

 var boss: Dictionary = game.enemies[boss_index]
 _check(bool(boss.get("is_verdant_boss",false)), "the encounter is identified as the unique Verdant boss")
 var root_radius: Vector2 = boss.get("root_radius",Vector2.ZERO)
 _check(root_radius.x > 0.0 and root_radius.y > 0.0, "the boss owns a two-axis root danger field")
 _check(GAME_SCRIPT.VERDANT_ROOT_RANGE > root_radius.x, "the boss can telegraph before the player enters the danger field")

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
 _check(float(boss.get("windup",0.0)) > 1.0, "the Root Warden begins a readable root-snare windup")
 _check(boss.get("root_windup_target",Vector2.ZERO).is_equal_approx(target), "the root field locks onto the player's position")

 game.player_pos = target+Vector2(0.0,90.0)
 game._process(0.2)
 boss = game.enemies[boss_index]
 _check(boss.get("root_windup_target",Vector2.ZERO).is_equal_approx(target), "the marked root field does not track the player")
 _check(float(boss.get("windup",0.0)) > 0.0, "the player has time to escape the marked ellipse")

 boss["windup"] = 0.05
 game.enemies[boss_index] = boss
 game.hp = 100.0
 game.player_invuln = 0.0
 game._process(0.06)
 boss = game.enemies[boss_index]
 _check(is_equal_approx(game.hp,100.0), "leaving the root ellipse avoids damage")
 _check(boss.get("root_burst_center",Vector2.ZERO).is_equal_approx(target), "the root impact resolves at the locked target")
 _check(float(boss.get("root_burst_left",0.0)) > 0.0, "the impact creates a visible root burst")

 game.player_pos = target
 game.hp = 100.0
 game.player_invuln = 0.0
 game.dash_anim = 0.0
 boss = game.enemies[boss_index]
 boss["windup"] = 0.05
 boss["root_windup_target"] = target
 game.enemies[boss_index] = boss
 game._process(0.06)
 _check(is_equal_approx(game.hp,77.0), "standing inside the root ellipse applies defense-reduced damage")

 game.player_pos = target
 game.hp = 100.0
 game.player_invuln = 0.0
 game.dash_anim = 0.2
 game.dash_from = target
 game.dash_to = target
 boss = game.enemies[boss_index]
 boss["windup"] = 0.05
 boss["root_windup_target"] = target
 game.enemies[boss_index] = boss
 game._process(0.06)
 _check(is_equal_approx(game.hp,100.0), "an active Eterium Dash avoids the root burst")

 game.dash_anim = 0.0
 game.player_invuln = 0.5
 game.hp = 100.0
 boss = game.enemies[boss_index]
 boss["windup"] = 0.05
 boss["root_windup_target"] = target
 game.enemies[boss_index] = boss
 game._process(0.06)
 _check(is_equal_approx(game.hp,100.0), "existing hit invulnerability prevents a second root hit")

func _boss_index(game) -> int:
 for index in range(game.enemies.size()):
  if str(game.enemies[index].get("spawn_id","")) == "verdant_guardian":
   return index
 return -1

func _check(condition: bool, label: String) -> void:
 if condition:
  print("PASS: " + label)
 else:
  failures += 1
  push_error("FAIL: " + label)
