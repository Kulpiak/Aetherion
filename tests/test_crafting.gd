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
	game._start_game("Terranie")
	_check(game.atk == 13 and game.defense == 5, "Terranie start with their base combat stats")

	# Exercise the actual UI callback: the old label passed a differently-cased item ID.
	game.inventory["Skóra bestii"] = 5
	game.inventory["Odłamek Eterium"] = 2
	game._show_panel("Rzemiosło")
	await process_frame
	var armor_button: Button = null
	for node in game.panel.find_children("*", "Button", true, false):
		var button := node as Button
		if button != null and button.text == "WYTWÓRZ PANCERZ ŁOWCY":
			armor_button = button
			break
	_check(armor_button != null, "crafting panel exposes the correctly named Hunter Armor recipe")
	if armor_button != null:
		armor_button.pressed.emit()
		await process_frame
	_check(game.owned_gear.has("Pancerz Łowcy"), "the armor recipe grants the canonical gear item")
	_check(str(game.equipment.get("Pancerz", "")) == "Pancerz Łowcy", "crafted Hunter Armor is equipped")
	_check(game.defense == 9 and game.max_hp == 155.0, "Hunter Armor applies defense and maximum HP bonuses")
	_check(int(game.inventory["Skóra bestii"]) == 0 and int(game.inventory["Odłamek Eterium"]) == 0, "Hunter Armor consumes exactly five hides and two shards")
	_check(FileAccess.file_exists("user://aetherion_save.json"), "crafted equipment is saved immediately")

	game.inventory["Skóra bestii"] = 4
	game.inventory["Odłamek Eterium"] = 3
	game._craft_item("Ostrze Eterium")
	_check(game.owned_gear.has("Ostrze Eterium"), "Etherium Blade is added to owned gear")
	_check(str(game.equipment.get("Broń", "")) == "Ostrze Eterium", "Etherium Blade is equipped after crafting")
	_check(game.atk == 20, "Etherium Blade adds seven attack")
	_check(int(game.inventory["Skóra bestii"]) == 0 and int(game.inventory["Odłamek Eterium"]) == 0, "Etherium Blade consumes exactly four hides and three shards")

	game.inventory["Skóra bestii"] = 2
	game.inventory["Odłamek Eterium"] = 1
	var potions_before := int(game.inventory["Mikstura HP"])
	game._craft_item("Mikstura HP")
	_check(int(game.inventory["Mikstura HP"]) == potions_before + 1, "potion recipe adds one healing potion")
	_check(int(game.inventory["Skóra bestii"]) == 0 and int(game.inventory["Odłamek Eterium"]) == 0, "potion recipe consumes exactly two hides and one shard")

	game.inventory["Skóra bestii"] = 4
	game.inventory["Odłamek Eterium"] = 3
	game._craft_item("Ostrze Eterium")
	_check(int(game.inventory["Skóra bestii"]) == 4 and int(game.inventory["Odłamek Eterium"]) == 3, "duplicate gear crafting does not consume materials")

	game.inventory["Skóra bestii"] = 0
	game.inventory["Odłamek Eterium"] = 0
	var potions_after := int(game.inventory["Mikstura HP"])
	game._craft_item("Mikstura HP")
	_check(int(game.inventory["Mikstura HP"]) == potions_after, "insufficient materials do not create a potion")

	var owned_count_before := game.owned_gear.size()
	game._craft_item("Pancerz ŁOWCY")
	_check(game.owned_gear.size() == owned_count_before, "unknown or incorrectly cased recipe IDs cannot create phantom gear")

	game.inventory["Skóra bestii"] = 11
	game.inventory["Odłamek Eterium"] = 8
	game._save_game(true)
	game.inventory["Skóra bestii"] = 0
	game.inventory["Odłamek Eterium"] = 0
	game.equipment = {"Broń":"Ostrze Wędrowca","Pancerz":"Tunika Wędrowca"}
	game.owned_gear = ["Ostrze Wędrowca","Tunika Wędrowca"]
	game._load_game()
	_check(int(game.inventory["Skóra bestii"]) == 11 and int(game.inventory["Odłamek Eterium"]) == 8, "save/load preserves remaining crafting materials")
	_check(game.owned_gear.has("Ostrze Eterium") and game.owned_gear.has("Pancerz Łowcy"), "save/load preserves both crafted gear items")
	_check(str(game.equipment.get("Broń", "")) == "Ostrze Eterium" and str(game.equipment.get("Pancerz", "")) == "Pancerz Łowcy", "save/load preserves equipped crafted gear")
	_check(game.atk == 20 and game.defense == 9 and game.max_hp == 155.0, "save/load rebuilds derived combat stats from crafted equipment")

	game.queue_free()
	await process_frame
	if FileAccess.file_exists("user://aetherion_save.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://aetherion_save.json"))

	if failures == 0:
		print("AETHERION_CRAFT_TESTS: PASS")
		quit(0)
	else:
		push_error("AETHERION_CRAFT_TESTS: FAIL (%d checks)" % failures)
		quit(1)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)
