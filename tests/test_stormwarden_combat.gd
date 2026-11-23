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
	game._enter_frost_sanctum()
	_test_storm_attack(game)

	game.queue_free()
	await process_frame
	if FileAccess.file_exists("user://aetherion_save.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://aetherion_save.json"))

	if failures == 0:
		print("AETHERION_STORM_COMBAT_TESTS: PASS")
		quit(0)
	else:
		push_error("AETHERION_STORM_COMBAT_TESTS: FAIL (%d checks)" % failures)
		quit(1)

func _test_storm_attack(game) -> void:
	var boss_index := _boss_index(game)
	_check(boss_index >= 0, "Storm Warden exists in the Frost Sanctum")
	if boss_index < 0:
		return

	var boss: Dictionary = game.enemies[boss_index]
	_check(bool(boss.get("is_frost_boss", false)), "the encounter is identified as the unique frost boss")
	_check(is_equal_approx(float(boss.get("storm_radius", 0.0)), GAME_SCRIPT.FROST_STORM_RADIUS), "the boss owns a defined storm blast radius")
	_check(GAME_SCRIPT.FROST_STORM_RANGE > GAME_SCRIPT.FROST_STORM_RADIUS, "the boss can telegraph from outside the blast radius")

	for index in range(game.enemies.size()):
		if index != boss_index:
			var sentry: Dictionary = game.enemies[index]
			sentry["alive"] = false
			sentry["respawn"] = 0.0
			game.enemies[index] = sentry

	var target := Vector2(640.0, 590.0)
	game.player_pos = target
	game.player_invuln = 0.0
	game.dash_anim = 0.0
	boss = game.enemies[boss_index]
	boss["timer"] = 1.31
	boss["windup"] = 0.0
	game.enemies[boss_index] = boss
	game._process(0.01)

	boss = game.enemies[boss_index]
	_check(float(boss.get("windup", 0.0)) > 1.2, "the Storm Warden begins a readable long windup")
	_check(boss.get("windup_target", Vector2.ZERO).is_equal_approx(target), "the danger zone locks onto the player's position when telegraphed")

	game.player_pos = target + Vector2(170.0, 0.0)
	game._process(0.2)
	boss = game.enemies[boss_index]
	_check(boss.get("windup_target", Vector2.ZERO).is_equal_approx(target), "the telegraphed danger zone does not track the player")
	_check(float(boss.get("windup", 0.0)) > 0.0, "the player has time to leave the marked zone")

	boss["windup"] = 0.05
	game.enemies[boss_index] = boss
	game.hp = 100.0
	game.player_invuln = 0.0
	var hp_before_escape: float = float(game.hp)
	game._process(0.06)
	boss = game.enemies[boss_index]
	_check(is_equal_approx(game.hp, hp_before_escape), "leaving the marked radius avoids storm damage")
	_check(boss.get("storm_blast_center", Vector2.ZERO).is_equal_approx(target), "the impact resolves at the locked target position")
	_check(float(boss.get("storm_blast_left", 0.0)) > 0.0, "the impact creates a short-lived visual shockwave")

	game.player_pos = target + Vector2(35.0, 0.0)
	game.hp = 100.0
	game.player_invuln = 0.0
	game.dash_anim = 0.0
	boss = game.enemies[boss_index]
	boss["windup"] = 0.05
	game.enemies[boss_index] = boss
	game._process(0.06)
	_check(is_equal_approx(game.hp, 71.0), "standing inside the storm radius applies damage reduced by defense")

	game.player_pos = target
	game.hp = 100.0
	game.player_invuln = 0.0
	game.dash_anim = 0.2
	game.dash_from = target
	game.dash_to = target
	boss = game.enemies[boss_index]
	boss["windup"] = 0.05
	game.enemies[boss_index] = boss
	game._process(0.06)
	_check(is_equal_approx(game.hp, 100.0), "an active Eterium Dash avoids the storm blast")

	game.dash_anim = 0.0
	game.player_invuln = 0.5
	game.hp = 100.0
	boss = game.enemies[boss_index]
	boss["windup"] = 0.05
	game.enemies[boss_index] = boss
	game._process(0.06)
	_check(is_equal_approx(game.hp, 100.0), "existing post-hit invulnerability prevents a second storm hit")

func _boss_index(game) -> int:
	for index in range(game.enemies.size()):
		if str(game.enemies[index].get("spawn_id", "")) == "frost_guardian":
			return index
	return -1

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)
