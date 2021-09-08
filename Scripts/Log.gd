extends Container

onready var line_scene = preload("res://Scenes/Line.tscn")
onready var lines = $Lines

var queue = []

func println(text):
	# Make a new label, add it as a child, check capacity
	var line = line_scene.instance()
	lines.add_child(line)
	line.text = text
	if queue.size() >= 15:
		for child in queue:
			child.visible = false
			child.queue_free()
		queue.clear()
	queue.append(line)
