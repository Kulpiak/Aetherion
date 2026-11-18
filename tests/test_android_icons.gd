extends SceneTree

const ICON_SPECS := [
	{
		"section": "application",
		"key": "config/icon",
		"path": "res://assets/aetherion_app_icon.svg",
		"minimum": Vector2i(192, 192)
	},
	{
		"section": "preset.0.options",
		"key": "launcher_icons/main_192x192",
		"path": "res://assets/aetherion_app_icon.svg",
		"minimum": Vector2i(192, 192)
	},
	{
		"section": "preset.0.options",
		"key": "launcher_icons/adaptive_foreground_432x432",
		"path": "res://assets/aetherion_app_icon_foreground.svg",
		"minimum": Vector2i(432, 432)
	},
	{
		"section": "preset.0.options",
		"key": "launcher_icons/adaptive_background_432x432",
		"path": "res://assets/aetherion_app_icon_background.svg",
		"minimum": Vector2i(432, 432)
	},
	{
		"section": "preset.0.options",
		"key": "launcher_icons/adaptive_monochrome_432x432",
		"path": "res://assets/aetherion_app_icon_monochrome.svg",
		"minimum": Vector2i(432, 432)
	}
]

func _initialize() -> void:
	var project_config := ConfigFile.new()
	var project_error := project_config.load("res://project.godot")
	var preset_config := ConfigFile.new()
	var preset_error := preset_config.load("res://export_presets.cfg")
	var failures := 0

	if project_error != OK:
		push_error("Cannot read project.godot")
		failures += 1
	if preset_error != OK:
		push_error("Cannot read export_presets.cfg")
		failures += 1

	for icon_spec in ICON_SPECS:
		var section := str(icon_spec["section"])
		var key := str(icon_spec["key"])
		var path := str(icon_spec["path"])
		var minimum: Vector2i = icon_spec["minimum"]
		var config := project_config if section == "application" else preset_config
		var configured_path := str(config.get_value(section, key, ""))

		if configured_path != path:
			push_error("%s is %s, expected %s" % [key, configured_path, path])
			failures += 1
			continue

		var texture := load(path) as Texture2D
		if texture == null:
			push_error("Icon texture failed to load: " + path)
			failures += 1
			continue

		var dimensions := texture.get_size()
		if dimensions.x < minimum.x or dimensions.y < minimum.y:
			push_error("%s is too small: %s (minimum %s)" % [path, dimensions, minimum])
			failures += 1
			continue

		print("PASS: %s -> %s (%s)" % [key, path, dimensions])

	if failures == 0:
		print("AETHERION_ICON_TESTS: PASS (%d icon settings)" % ICON_SPECS.size())
		quit(0)
	else:
		push_error("AETHERION_ICON_TESTS: FAIL (%d problems)" % failures)
		quit(1)
