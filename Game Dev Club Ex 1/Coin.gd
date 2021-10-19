extends Area2D

# we'll do this later

func _on_Coin_body_entered(body):
	queue_free()
