# Verilog Frogger Game

This project implements a Frogger game in Verilog, designed to run on a 16x16 RGB LED board. The game features classic Frogger gameplay, where the player navigates a frog across moving rows of obstacles to reach the goal.

## Features

- **16x16 RGB LED Display:** The game is visually rendered on a 16x16 LED matrix, supporting full RGB colors for dynamic graphics.
- **Randomized Rows:** Each row can be randomized for obstacle type and placement, making each playthrough unique.
- **Variable Speeds:** Rows move at different speeds, increasing the challenge and variety.
- **Randomized Cars and Obstacles:** Cars and other obstacles are randomly generated in both position and color, adding unpredictability.
- **Score Tracking:** The game tracks the player's score based on successful crossings.
- **Hardware Integration:** Designed for FPGA boards (such as DE1-SoC), with modules for clock division, input handling, and LED driving.

## File Overview
- `DE1_SoC.sv`: Top-level module for FPGA integration.
- `LEDDriver.sv`: Handles driving the 16x16 RGB LED matrix.
- `counter.sv`, `clock_divider.sv`: Timing and clock management modules.
- `LSFR.sv`: Linear Feedback Shift Register for randomization.
- `inputChange.sv`: Processes player input.
- `redRow.sv`, `green.sv`: Row logic and color management.
- `score.sv`: Score tracking logic.

## How It Works
- The frog is controlled via hardware inputs (buttons or switches).
- Rows of cars and obstacles move horizontally, with each row having its own speed and randomization.
- The player must avoid obstacles and reach the top row to score points.
- The game uses an LSFR for randomizing row patterns, car positions, and colors.

## Getting Started
1. Load the Verilog files onto your FPGA development board.
2. Connect the 16x16 RGB LED matrix and input controls as specified in your hardware setup.
3. Power on the board and start playing Frogger!

## Special Features
- **Randomization:** Every game session is different due to LSFR-based randomization in rows, speeds, and car colors.
- **Multiple Speeds:** Rows move at independent speeds, requiring strategic timing.
- **RGB Graphics:** Obstacles and frog are displayed in vibrant colors.

## License
This project is for educational purposes.

---
For more details, see the individual module files and comments within the code.
