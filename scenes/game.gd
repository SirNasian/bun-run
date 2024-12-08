extends Node2D

var Player: PackedScene = preload("res://entities/player/player.tscn")

func _ready() -> void:
	self.add_child(Player.instantiate())
