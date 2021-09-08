extends TileMap


onready var number_scene = preload("res://Scenes/Number.tscn")
onready var log_box = get_parent().get_node("Log")

# Sudoku grid:
var grid = []
var grid_size = Vector2(9, 9)

# Sudoku difficulty:
enum Difficulty {
	EASY, MEDIUM, HARD, DEATH
}
var difficulty_level = Difficulty.MEDIUM

# User interaction:
onready var finished_generating = true


# Sudoku Generator and Solver:
# Facts: 
# - There are 6.67 sextillion (6.67*10^21) possible solved sudoku grids.
# - The minimum number of clues you can have that still produces a unique solution is 17.
# - Only around 49,000 sudokus with 17 clues and a unique solution have been found.


func _ready():
	randomize()
	
	# Initialize matrix for solving sudoku using DLX:
	init_exact_cover_matrix()
	
	# Automatic sudoku creation:
	init_grid()
	#var show_process = true
	#init_grid(show_process)
	
	# Custom sudoku creation:
	#init_grid_custom()
	
	
	# Testing DLX algorithm:
#	var solutions = []
#	var partial_solution = []
#	DLX(test_matrix, partial_solution, solutions)
#	print(solutions)

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_R:
			get_tree().reload_current_scene()
		elif finished_generating:
			if event.scancode == KEY_S:
				var solutions = solve_sudoku(true)
				log_box.println("Solutions found: "+str(solutions.size()))
			elif event.scancode == KEY_G:
				# Generate sudoku puzzle:
				init_grid()
				fill_grid(true)
			elif event.scancode == KEY_E:
				difficulty_level = Difficulty.EASY
				log_box.println("Sudoku difficulty level set to: EASY")
			elif event.scancode == KEY_M:
				difficulty_level = Difficulty.MEDIUM
				log_box.println("Sudoku difficulty level set to: MEDIUM")
			elif event.scancode == KEY_H:
				difficulty_level = Difficulty.HARD
				log_box.println("Sudoku difficulty level set to: HARD")
			elif event.scancode == KEY_D:
				difficulty_level = Difficulty.DEATH
				log_box.println("Sudoku difficulty level set to: DEATH")
			elif event.as_text().is_valid_integer():
				var value = int(event.as_text())
				var mouse_pos = get_global_mouse_position()
				var grid_pos = world_to_map(mouse_pos)
				var row = grid_pos.y
				var col = grid_pos.x
				if row < 0 or row >= grid_size.y or col < 0 or col >= grid_size.x:
					return
				grid[row][col].number = value
				

func init_grid():
	grid.clear()
	for child in get_children():
		child.queue_free()
	for row in grid_size.y:
		grid.append([])
		for col in grid_size.x:
			var number = number_scene.instance()
			add_child(number)
			number.rect_position = map_to_world(Vector2(col, row))
			grid[row].append(number)
			number.set_units(row, col)


func init_grid_custom():
	grid.clear()
	for child in get_children():
		child.queue_free()
#	var entries = [[4, 1, 5, 0, 7, 8, 2, 0, 9],
#					[0, 6, 0, 0, 2, 9, 5, 0, 0],
#					[0, 0, 0, 0, 0, 1, 4, 7, 0],
#					[3, 0, 0, 0, 4, 5, 0, 0, 2],
#					[0, 0, 0, 1, 0, 0, 0, 5, 0],
#					[0, 0, 7, 0, 3, 0, 0, 9, 0],
#					[6, 7, 0, 9, 0, 0, 1, 3, 0],
#					[0, 4, 9, 0, 1, 3, 0, 2, 0],
#					[0, 3, 1, 2, 5, 0, 0, 0, 6]]
	var entries = [[0, 0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0, 0]]
	for row in grid_size.y:
		grid.append([])
		for col in grid_size.x:
			var entry = entries[row][col]
			var number = number_scene.instance()
			add_child(number)
			number.rect_position = map_to_world(Vector2(col, row))
			grid[row].append(number)
			number.set_units(row, col)
			number.number = entry
	finished_generating = true


# Uses backtracking sudoku generator algorithm from:
# https://www.codeproject.com/articles/23206/sudoku-algorithm-generates-a-valid-sudoku-in-0-018
func fill_grid(show_process):
	finished_generating = false
	log_box.println("\nGenerating new Sudoku puzzle...")
	var difficulty
	match difficulty_level:
		Difficulty.EASY:
			difficulty = "EASY"
		Difficulty.MEDIUM:
			difficulty = "MEDIUM"
		Difficulty.HARD:
			difficulty = "HARD"
		Difficulty.DEATH:
			difficulty = "DEATH"
		
	log_box.println("Difficulty level: "+difficulty)
	var iterations = 0
	var tries = 25000
	while true:
		var current_cell_index = 0 # 0 to 80
		var number_of_cells = grid_size.x * grid_size.y
		
		# set up available numbers for each cell
		var available_numbers_list = []
		for i in range(number_of_cells):
			available_numbers_list.append([1,2,3,4,5,6,7,8,9])
		
		while current_cell_index < number_of_cells and iterations < tries:
			iterations += 1
			#print(current_cell_index)
			
			if show_process: yield(get_tree().create_timer(0.01), "timeout")
			
			var row = int(current_cell_index / int(grid_size.y))
			var col = current_cell_index % int(grid_size.x)
			var cell = grid[row][col]
			var available_numbers = available_numbers_list[current_cell_index]
			
			if not available_numbers.empty(): # if possible numbers left in cell
				var available_num = available_numbers[randi() % available_numbers.size()]
				cell.number = available_num
				
				if not number_conflicts(cell, true):
					# no conflict, so this number works for grid. Remove number from list and continue:
					grid[row][col].number = available_num
					available_numbers_list[current_cell_index].erase(available_num)
					current_cell_index += 1 # proceed to next cell
					
				else: # if there is a conflict, remove number from list:
					available_numbers_list[current_cell_index].erase(available_num)
					
			else: # no possible numbers left for cell
				cell.number = 0
				available_numbers_list[current_cell_index] = [1,2,3,4,5,6,7,8,9] # reset available numbers
				current_cell_index -= 1 # go back to previous square and try a different number
		
		if current_cell_index == number_of_cells: # if finished filling grid, end function:
			log_box.println("Grid generated after "+str(iterations)+" iterations.")
			break
		else: # if hasn't filled grid after iteration limit, reset iterations, change seed and try again
			iterations = 0
			randomize()
			log_box.println("Iteration limit reached. Retrying...")
	
	# Randomly remove numbers to meet difficulty:
	carve_grid(difficulty_level, show_process) 

func number_conflicts(cell, only_check_previous = false):
	# Iterate through all previous cells to check for conflicts:
	for row in grid:
		for other_cell in row:
			if only_check_previous and cell == other_cell: # reached current cell without conflicts
				return false
			if cell.number != other_cell.number: # skip if different number
				continue
			# Cells have the same number:
			#print("Checking: "+str(cell))
			var units = cell.units
			var o_units = other_cell.units
			
			# Conflicts:
			var con_row = units.row == o_units.row
			var con_col = units.col == o_units.col
			var con_box = units.box == o_units.box
			#print(other_cell)
			if con_row or con_col or con_box:
#				if con_row:
#					print("Row conflict: " + str(cell))
#				if con_col:
#					print("Col conflict: " + str(cell))
#				if con_box:
#					print("Box conflict: " + str(cell))
				return true # conflict found


func carve_grid(difficulty, show_process):
	# Decide number of clues based on difficulty level:
	var clues_range = [0, 81]
	match difficulty:
		Difficulty.EASY:
			clues_range = [40, 50]
		Difficulty.MEDIUM:
			clues_range = [30, 40]
		Difficulty.HARD:
			clues_range = [25, 30]
		Difficulty.DEATH:
			clues_range = [20, 25]
	var clues = clues_range[0] + randi() % (clues_range[1] - clues_range[0])
	log_box.println("Clues attempting to leave: "+str(clues))
	var clues_remaining = []
	
	# Fill clue_indexes with every cell index and shuffle: (0 to 80)
	for i in (grid_size.x * grid_size.y):
		clues_remaining.append(i)
	clues_remaining.shuffle()
	
	# Remove clues (numbers) until sudoku has desired number of clues remaining:
	# Check that sudoku is still solvable (1 unique solution) after each removal.
	var regex = RegEx.new()
	regex.compile("\\d")
	
	var clues_removed = 0
	var check_frequency = 16
	var removed_cell_ids = []
	var consecutive_undo_count = 0
	var max_consecutive_undo_tries = 10
	
	while clues_remaining.size() > clues:
		var index = clues_remaining.pop_back()
		var row = int(index / int(grid_size.y))
		var col = int(int(index) % int(grid_size.x))
		var cell = grid[row][col]
		removed_cell_ids.append("R"+str(row)+"C"+str(col)+"#"+str(cell.number))
		cell.number = 0
		clues_removed += 1
		#print("Erased clue: "+str(cell))
		
		# Make sure sudoku still has 1 unique solution:
		if (clues_removed % check_frequency == 0):
			var solutions = solve_sudoku()
			if solutions.size() != 1:
				log_box.println("Error - solutions found: "+str(solutions.size()))
				
				# Undo removals, halve frequency (if >1), and shuffle indexes:
				while not removed_cell_ids.empty():
					if show_process: yield(get_tree().create_timer(0.01), "timeout")
					var cell_values = regex.search_all(removed_cell_ids.pop_back())
					var cell_row = int(cell_values[0].get_string())
					var cell_col = int(cell_values[1].get_string())
					var cell_number = int(cell_values[2].get_string())
					var cell_index = (cell_row * grid_size.x) + cell_col
					grid[cell_row][cell_col].number = cell_number # add number back to grid
					clues_remaining.append(cell_index) # add index back to clues remaining
				
				clues_remaining.shuffle()
				clues_removed -= check_frequency
				if check_frequency > 1:
					check_frequency /= 2
				else: # if frequency is 1:
					consecutive_undo_count += 1
			
			else: # if there is a unique solution, and undo wasn't required:
				removed_cell_ids.clear()
				log_box.println("Check frequency: "+str(check_frequency)+", Consecutive undos: "+str(consecutive_undo_count))
				consecutive_undo_count = 0
		
		# If too many undos occur, just accept what we have!
		if consecutive_undo_count > max_consecutive_undo_tries:
			log_box.println("Consecutive undo limit reached. Terminating grid carving...")
			break
	
	# Finished (ideal number of clues remaining) or broke out of while loop:
	log_box.println("\nSudoku generation finished!")
	finished_generating = true
	log_box.println("Number of clues / attempted: "+str(clues_remaining.size())+"/"+str(clues))

func solve_sudoku(fill_solution = false):
	var clues = 0
	for row in grid_size.y:
		for col in grid_size.x:
			if grid[row][col].number != 0:
				clues += 1
	if clues < 17:
		log_box.println("Error: too few clues to be solvable.")
		return []
	
	var known_cell_solutions = get_known_cell_solutions()
	var partial_solution = []
	var solutions = []
	DLX(exact_cover, partial_solution, solutions, known_cell_solutions)
	if fill_solution:
		fill_sudoku(solutions)
	return solutions

func fill_sudoku(solutions):
	var regex = RegEx.new()
	regex.compile("\\d")
	for solution in solutions:
		for cell_id in solution:
			var values = regex.search_all(cell_id)
			var row = int(values[0].get_string())
			var col = int(values[1].get_string())
			var number = int(values[2].get_string())
			grid[row][col].number = number



# Steps for solving an exact cover incidence matrix (Knuth's Algorithm X - Dancing Links Algorithm):

# 1. If the matrix M has no columns, the current partial solution is a valid solution!
# Terminate successfully. JK, exhaust it until you can't find a second solution (we only want one).

# 2. If matrix M still has columns, choose the column Col with the least number of 1's 
# (good rule for minimising total number of iterations).
# If column Col has no 1's (there is a column with only 0's), then terminate unsuccessfully.
# This is a dead-end as a solution must have a 1 in each column.

# 3. Choose a row such that M(Row, Col) = 1. Start at top row, then go down when backtracking.
# Copy the matrix each time you do this.

# 4. Include that row (Row) in the partial solution.

# 5. For each column ColTemp such that M(Row, ColTemp) = 1:
# 		For each row RowTemp such that M(RowTemp, ColTemp) = 1:
#		Delete row RowTemp from matrix M.
# Delete column ColTemp from matrix M.

# 6. Repeat this algorithm recursively on the reduced matrix M.

var test_matrix = {"A":[1,0,0,1,0,0,1],
					"B":[1,0,0,1,0,0,0],
					"C":[0,0,0,1,1,0,1],
					"D":[0,0,1,0,1,1,0],
					"E":[0,1,1,0,0,1,1],
					"F":[0,1,0,0,0,0,1]}

# Exact cover sudoku matrix:
var exact_cover = {}

func init_exact_cover_matrix():
	exact_cover.clear()
	var total_cells = grid_size.x * grid_size.y
	
	for row in grid_size.y:
		for col in grid_size.x:
			for value in grid_size.y: # 9*9*9 = 729 different rows
				
				# Create row name in matrix:
				var row_name = "R"+str(row)+"C"+str(col)+"#"+str(value+1)
				#print(row_name)
				
				# Calculate constraint values:
				var con_cell = row * grid_size.y + col
				var con_row = total_cells + (row * grid_size.y + value)
				var con_col = total_cells*2 + (col * grid_size.x + value)
				var box = (3 * int(row / 3)) + int(col / 3)
				var con_box = total_cells*3 + (box * grid_size.y + value)
				
				# Make row array with values:
				var row_array = []
				for i in (total_cells*4): # 9*9*4 = 324 different columns
					row_array.append(0)
				row_array[con_cell] = 1
				row_array[con_row] = 1
				row_array[con_col] = 1
				row_array[con_box] = 1
				
				# Add row to matrix dict:
				exact_cover[row_name] = row_array

func get_known_cell_solutions():
	var known_cell_solutions = []
	for row in grid_size.y:
		for col in grid_size.x:
			var cell = grid[row][col]
			if cell.number != 0:
				var row_name = "R"+str(row)+"C"+str(col)+"#"+str(cell.number)
				known_cell_solutions.append(row_name)
	return known_cell_solutions

func DLX(matrix, partial_solution, solutions, known_cells = []):
	if not known_cells.empty():
		#print("Number of known cells: "+str(known_cells.size()))
		var updated_matrix = matrix
		for row_name in known_cells:
			#print(row_name)
			partial_solution.append(row_name)
			updated_matrix = reduce_matrix(updated_matrix, row_name)
		#print("Passed known cell removal stage!")
		DLX(updated_matrix, partial_solution, solutions)
		return
	if matrix == null:
		return
	
	# 1:
	if matrix.empty():
		solutions.append(partial_solution)
		return # solution found
	
	# 2:
	# Convert matrix to matrix sorted by columns:
	var all_values = matrix.values()
	var col_matrix = sort_matrix_by_columns(all_values)
	#print(col_matrix)
	
	# Get column with lowest number of 1's:
	var best_col_num = 0
	var lowest_count = col_matrix[0].size()
	for col in col_matrix.size():
		var ones_count = col_matrix[col].count(1)
		if ones_count < lowest_count:
			best_col_num = col
			lowest_count = ones_count
	if lowest_count == 0:
		partial_solution.pop_back()
		return # dead-end
	#print(best_col)
	
	# 3:
	var best_col = col_matrix[best_col_num]
	for index in best_col.size():
		if best_col[index] == 1:
			var row_name = matrix.keys()[index]
			#print(row_name)
			
			# 4:
			partial_solution.append(row_name)
			
			var reduced_matrix = reduce_matrix(matrix, row_name)
			#print(reduced_matrix)
			DLX(reduced_matrix, partial_solution, solutions)

func reduce_matrix(matrix, row_name):
	# 5. For each column ColTemp such that M(Row, ColTemp) = 1:
	# For each row RowTemp such that M(RowTemp, ColTemp) = 1:
	# Delete row RowTemp from matrix M.
	# Delete column ColTemp from matrix M.
	if matrix == null:
		return null
	var reduced_matrix = matrix.duplicate(true)
	var chosen_row = matrix.get(row_name)
	var rows_to_delete = []
	var cols_to_delete = []
	if chosen_row == null:
		log_box.println("No possible solutions.")
		return null
#	else:
#		print(row_name+" "+str(chosen_row.size()))
	for col_temp in chosen_row.size():
		if chosen_row[col_temp] == 1:
			cols_to_delete.append(col_temp)
			for row_key in matrix.keys():
				if matrix.get(row_key)[col_temp] == 1:
					rows_to_delete.append(row_key)
	# Deletion:
	for key in rows_to_delete:
		reduced_matrix.erase(key)
	for i in range(cols_to_delete.size()-1, -1, -1):
		for row in reduced_matrix.values():
			row.remove(cols_to_delete[i])
	
	return reduced_matrix

func sort_matrix_by_columns(matrix_by_rows):
	var cols = matrix_by_rows[0].size()
	var matrix_by_cols = []
	for col in range(cols):
		matrix_by_cols.append([])
	for row in matrix_by_rows:
		for col in row.size():
			matrix_by_cols[col].append(row[col])
	return matrix_by_cols
