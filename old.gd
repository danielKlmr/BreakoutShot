# Ball:

# Bounce-Verhalten gegen das Spielfeld
if(position.x - game_variables.ballradius <= 0):
	bounce(movement, Vector2(1, 0))
if(position.x + game_variables.ballradius >= game_variables.x_size):
	bounce(movement, Vector2(-1, 0))
if(position.y - game_variables.ballradius <= 0):
	bounce(movement, Vector2(0, 1))
if(position.y + game_variables.ballradius >= game_variables.y_size):
	bounce(movement, Vector2(0, -1))
