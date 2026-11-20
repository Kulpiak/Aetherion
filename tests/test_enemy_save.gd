extends SceneTree

const GAME_SCRIPT = preload("res://scripts/game.gd")

var failures := 0

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	var game = GAME_SCRIPT.new()
	root.add_child(game)
	await process_frame

	_test_legacy_v3_migration(game)
	_test_v6_enemy_round_trip(game)

	game.queue_free()
	await process_frame
	var save_path := ProjectSettings.globalize_path("user://aetherion_save.json")
	if FileAccess.file_exists("user://aetherion_save.json"):
		DirAccess.remove_absolute(save_path)

	if failures == 0:
		print("AETHERION_SAVE_TESTS: PASS")
		quit(0)
	else:
		push_error("AETHERION_SAVE_TESTS: FAIL (%d checks)" % failures)
		quit(1)

func _test_legacy_v3_migration(game) -> void:
	var legacy_save := {
		"save_version": 3,
		"race": "Terranie",
		"pos": [520.0, 410.0],
		"level": 3,
		"xp": 25,
		"gold": 77,
		"kills": 2,
		"quest": 1,
		"hp": 100.0,
		"ether": 80.0,
		"inventory": {"Mikstura HP": 2, "Odłamek Eterium": 1, "Skóra bestii": 3},
		"equipment": {"Broń": "Ostrze Wędrowca", "Pancerz": "Tunika Wędrowca"},
		"owned_gear": ["Ostrze Wędrowca", "Tunika Wędrowca"],
		"boss_spawned": false,
		"boss_defeated": false,
		"loot_drops": [],
		"discovered_regions": ["Kamienny Krąg", "Zielone Ostępy"]
	}
	_write_save(legacy_save)
	game._load_game()

	_check(game.started, "v3 save starts the game")
	_check(game.race == "Terranie", "v3 race is preserved")
	_check(game.level == 3 and game.gold == 77, "v3 progression is preserved")
	_check(game.discovered_regions.has("Zielone Ostępy"), "v3 region discovery is preserved")
	_check(game.enemies.size() == 18, "v3 save retains the 18 default regional encounters")
	var all_default_enemies_alive := true
	for enemy in game.enemies:
		if not bool(enemy.get("alive", false)) or not is_equal_approx(float(enemy.get("hp", 0.0)), float(enemy.get("max_hp", 0.0))):
			all_default_enemies_alive = false
	_check(all_default_enemies_alive, "v3 save without enemy_states safely uses default encounters")

func _test_v4_enemy_round_trip(game) -> void:
	var first: Dictionary = game.enemies[0]
	first["hp"] = 21.5
	first["pos"] = Vector2(720.0, 680.0)
	first["alive"] = true
	game.enemies[0] = first

	var second: Dictionary = game.enemies[1]
	second["hp"] = 0.0
	second["alive"] = false
	second["pos"] = Vector2(930.0, 740.0)
	second["respawn"] = 7.25
	game.enemies[1] = second

	game.boss_spawned = true
	game.boss_defeated = false
	game.enemies.append({
		"name": "Strażnik Rdzenia",
		"pos": Vector2(1600.0, 825.0),
		"hp": 312.0,
		"max_hp": 620.0,
		"damage": 22.0,
		"speed": 58.0,
		"alive": true,
		"type": 3,
		"timer": 0.0,
		"respawn": 0.0,
		"windup": 0.0,
		"windup_total": 0.82,
		"is_boss": true
	})
	game._save_game(true)

	first["hp"] = 1.0
	first["pos"] = Vector2(100.0, 100.0)
	game.enemies[0] = first
	second["alive"] = true
	second["hp"] = float(second["max_hp"])
	second["respawn"] = 0.0
	game.enemies[1] = second
	game.enemies.pop_back()
	game._load_game()

	var restored_first: Dictionary = _enemy_by_id(game, "regional_00")
	var restored_second: Dictionary = _enemy_by_id(game, "regional_01")
	_check(is_equal_approx(float(restored_first.get("hp", 0.0)), 21.5), "v6 restores remaining enemy HP")
	_check(restored_first.get("pos", Vector2.ZERO).is_equal_approx(Vector2(720.0, 680.0)), "v6 restores enemy position by stable spawn ID")
	_check(not bool(restored_second.get("alive", true)), "v6 restores defeated enemy state")
	_check(is_equal_approx(float(restored_second.get("respawn", 0.0)), 7.25), "v6 restores remaining respawn time")
	var boss_count := 0
	var restored_boss_hp := 0.0
	for enemy in game.enemies:
		if bool(enemy.get("is_boss", false)):
			boss_count += 1
			restored_boss_hp = float(enemy.get("hp", 0.0))
	_check(boss_count == 1, "v6 restores exactly one active boss")
	_check(is_equal_approx(restored_boss_hp, 312.0), "v6 preserves boss HP separately from regional enemies")

func _enemy_by_id(game, spawn_id: String) -> Dictionary:
	for enemy in game.enemies:
		if str(enemy.get("spawn_id", "")) == spawn_id:
			return enemy
	return {}

func _write_save(data: Dictionary) -> void:
	var file := FileAccess.open("user://aetherion_save.json", FileAccess.WRITE)
	if file == null:
		_check(false, "test save file can be opened")
		return
	file.store_string(JSON.stringify(data))
	file.close()

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)
