extends Panel

# List of labels in this panel
enum { VECTOR = 0, MOTION = 1, POSITION = 2, INPUT = 3 }

# Change the text field of one of the labels 
func updateText(var child, var text):
	get_child(child).text = text

func updateVectorInfo(var vector):
	updateText(VECTOR, str("vector: ", vector.x, ", ", vector.y))

func updateMotionInfo(var vector):
	updateText(MOTION, str("motion: ", vector.x, ", ", vector.y))

func updatePositionInfo(var vector):
	updateText(POSITION, str("pos: ", round(vector.x), ", ", round(vector.y)))

func updateInputInfo(var input):
	var key1 = input[0].substr(3, input[0].length() - 3) if (input[0] != null) else "n/a"
	var key2 = input[1].substr(3, input[1].length() - 3) if (input[1] != null) else "n/a"
	updateText(INPUT, str("input: ", key1, ", ", key2))

func _process(delta):
	if Input.is_action_just_pressed("ui_focus_next"):
		if (is_visible()): hide()
		else: show()
	