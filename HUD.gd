extends CanvasLayer

signal start_game

# List of sprites used to display player life
onready var life_sprites = [ $ThirdLife, $SecondLife, $FirstLife ]
onready var lives_remaining = life_sprites.size()

# Should be called on each new game to restore default sprites
func reset_lives():
	lives_remaining = life_sprites.size()
	for sprite in life_sprites:
		sprite.animation = "default"

# This is called whenever a player has been hit. Returns the amount of lives remaining
func lose_life():
	var current_life = life_sprites[lives_remaining - 1]
	current_life.animation = "vanish"
	current_life.play()
	lives_remaining -= 1
	return lives_remaining

# This function is called when we want to display a message temporarily, such as “Get Ready”.
func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()

# This function is called when the player loses. Show game title and the “Start” button.
func show_game_over():
	show_message("Game Over")
	yield($MessageTimer, "timeout")
	$StartButton.show()
	$MessageLabel.text = "Dodge the\nCreeps!"
	$MessageLabel.show()

# This function is called in Main whenever the score changes.
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_MessageTimer_timeout():
	$MessageLabel.hide()

func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")
