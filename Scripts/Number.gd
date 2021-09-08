extends Label

var number = 0 setget set_number
var units = {}

func set_number(value):
	if value < 1 or value > 9:
		clear_number()
	else:
		number = value
		text = str(value)

func clear_number():
	number = 0
	text = ""

func set_units(row, col):
	units["row"] = row
	units["col"] = col
	units["box"] = (3 * int(row / 3)) + int(col / 3)

func _to_string():
	return "R"+str(units.row)+"C"+str(units.col)+"B"+str(units.box)+"#"+str(number)
