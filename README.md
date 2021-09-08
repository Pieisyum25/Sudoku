# Sudoku
---
Generate, solve, and play Sudoku puzzles.

### Program Screenshots:
<p float="left">
  <img src="https://user-images.githubusercontent.com/80517108/132532539-7c8298c5-8bad-4c2c-8e01-ecdbc0c237d0.JPG" alt="screenshot of puzzle generation" width="300"/>
  <img src="https://user-images.githubusercontent.com/80517108/132532550-5cd98012-3927-4f3b-b0a8-ec165f25cd66.JPG" alt="screenshot of puzzle generation" width="300"/>
  <br>
  <img src="https://user-images.githubusercontent.com/80517108/132532559-842efe58-eead-41bb-9190-3f96e60203ae.JPG" alt="screenshot of solved puzzle" width="300"/>
  <img src="https://user-images.githubusercontent.com/80517108/132532575-a8122ebf-fad7-4d0d-bc29-52ccc5db5d61.JPG" alt="screenshot of unsolvable puzzle" width="300"/>
</p>

### Description:
- Enter the world of Sudoku.
- This program does all things Sudoku related. It generates them, solves them, and even lets you play!
- Watch as the program generates fresh Sudoku puzzles for you in real time, and feel like you're hacking into some kind of computer system.
- Go on, just press 'G'.
- Source code and what little art there is was made by Pieisyum25 (me).

**Access it here (via itch.io): https://pieisyum25.itch.io/sudoku-generator-and-solver**

### Controls:
- 'G' to generate a new puzzle.
- 'E', 'M', 'H', and 'D' to change the generated puzzle difficulty level (Easy, Medium, Hard, Death).
- 'R' to refresh the program and clear everything (useful if puzzle generation is taking too long).
- 'S' to solve the current puzzle.
- Enter your own numbers by hovering your mouse over a square and pressing a number from '1' to '9'. Use '0' to clear a square.

### Algorithm Notes:
- Uses a backtracking algorithm for generating a new Sudoku puzzle.
- Uses Knuth's Dancing Links algorithm (DLX) to solve Sudoku puzzles as an exact cover problem.

---
Developed using the Godot game engine (https://godotengine.org/), with source code written in GDScript and art made using Pixilart (https://www.pixilart.com/).
