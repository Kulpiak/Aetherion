extends SceneTree

const GAME_SCRIPT = preload("res://scripts/game.gd")
const ATTACK_ATLAS: Texture2D = preload("res://assets/aetherion_race_attack_glyphs.svg")
const RACE_COUNT := 5

var failures := 0

func _initialize() -> void:
 call_deferred("_run_tests")

func _run_tests() -> void:
 var game = GAME_SCRIPT.new()
 root.add_child(game)
 await process_frame
 game.set_process(false)

 _check(ATTACK_ATLAS != null, "the race attack atlas loads")
 if ATTACK_ATLAS != null:
  var dimensions := ATTACK_ATLAS.get_size()
  _check(dimensions == Vector2(640.0,128.0), "the atlas has five 128-pixel race cells")
  var atlas_image := ATTACK_ATLAS.get_image()
  _check(atlas_image != null and not atlas_image.is_empty(), "the SVG atlas exposes readable pixel data")
  if atlas_image != null and not atlas_image.is_empty():
   var previous_signature := Vector3.ZERO
   for race_index in range(RACE_COUNT):
    var region: Rect2 = game._race_attack_region(race_index)
    _check(region.position.is_equal_approx(Vector2(race_index*128,0)), "race %d selects its own attack glyph cell" % race_index)
    _check(region.size.is_equal_approx(Vector2(128,128)), "race %d uses a complete 128-pixel glyph cell" % race_index)
    var visible_pixels := 0
    var color_sum := Vector3.ZERO
    for y in range(8,120,3):
     for x in range(race_index*128+8,(race_index+1)*128-8,3):
      var sample := atlas_image.get_pixel(x,y)
      if sample.a > 0.12:
       visible_pixels += 1
       color_sum += Vector3(sample.r,sample.g,sample.b)
    _check(visible_pixels > 35, "race %d attack glyph contains visible artwork" % race_index)
    if visible_pixels > 0:
     var signature := color_sum/float(visible_pixels)
     if race_index > 0:
      _check(signature.distance_to(previous_signature) > 0.08, "race %d has a visually distinct attack palette" % race_index)
     previous_signature = signature

 _check(game._race_attack_region(-1).position.is_equal_approx(Vector2.ZERO), "negative race indices safely clamp to Terranie")
 _check(game._race_attack_region(99).position.is_equal_approx(Vector2(512,0)), "large race indices safely clamp to Noctari")

 game.queue_free()
 await process_frame

 if failures == 0:
  print("AETHERION_RACE_ATTACK_ART_TESTS: PASS")
  quit(0)
 else:
  push_error("AETHERION_RACE_ATTACK_ART_TESTS: FAIL (%d checks)" % failures)
  quit(1)

func _check(condition: bool, label: String) -> void:
 if condition:
  print("PASS: " + label)
 else:
  failures += 1
  push_error("FAIL: " + label)
