extends SceneTree

const GAME_SCRIPT = preload("res://scripts/game.gd")
const RACE_CREST_TEXTURE = preload("res://assets/aetherion_race_crests.svg")
const RACE_NAMES := ["Terranie","Varkari","Elarianie","Sylvari","Noctari"]
const EXPECTED_MOTES := [4,2,8,5,3]

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

 _check(RACE_CREST_TEXTURE != null, "the five-race crest atlas loads")
 _check(RACE_CREST_TEXTURE.get_width() == 640, "the crest atlas contains five 128-pixel columns")
 _check(RACE_CREST_TEXTURE.get_height() == 128, "the crest atlas has the expected single-row layout")

 var previous_primary := Color.TRANSPARENT
 var previous_accent := Color.TRANSPARENT
 for race_index in range(RACE_NAMES.size()):
  var race_name := str(RACE_NAMES[race_index])
  game.transformed = false
  game.transform_left = 0.0
  game.transform_cd = 0.0
  game._start_game(race_name)
  game.ether = game.max_ether
  game._transform()

  var primary: Color = game._awakening_primary_color(race_index)
  var accent: Color = game._awakening_accent_color(race_index)
  var crest_region: Rect2 = game._race_crest_region(race_index)

  _check(game.race == race_name, "%s keeps its own selected identity" % race_name)
  _check(game.transformed, "%s can activate Core Awakening" % race_name)
  _check(is_equal_approx(game.transform_left,16.0), "%s receives the standard awakening duration" % race_name)
  _check(is_equal_approx(game.transform_cd,32.0), "%s receives the standard awakening cooldown" % race_name)
  _check(is_equal_approx(game.ether,game.max_ether-28.0), "%s pays the correct Eterium cost" % race_name)
  _check(crest_region.position.is_equal_approx(Vector2(race_index*128,0)), "%s selects its own crest atlas cell" % race_name)
  _check(crest_region.size.is_equal_approx(Vector2(128,128)), "%s uses a complete crest cell" % race_name)
  _check(game._awakening_mote_count(race_index) == EXPECTED_MOTES[race_index], "%s uses its distinct aura motif count" % race_name)

  if race_index > 0:
   _check(not primary.is_equal_approx(previous_primary), "%s has a different primary aura color" % race_name)
   _check(not accent.is_equal_approx(previous_accent), "%s has a different highlight color" % race_name)
  previous_primary = primary
  previous_accent = accent

 game.queue_free()
 await process_frame
 if FileAccess.file_exists("user://aetherion_save.json"):
  DirAccess.remove_absolute(ProjectSettings.globalize_path("user://aetherion_save.json"))

 if failures == 0:
  print("AETHERION_AWAKENING_TESTS: PASS")
  quit(0)
 else:
  push_error("AETHERION_AWAKENING_TESTS: FAIL (%d checks)" % failures)
  quit(1)

func _check(condition: bool, label: String) -> void:
 if condition:
  print("PASS: " + label)
 else:
  failures += 1
  push_error("FAIL: " + label)
