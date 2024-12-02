# Verilog Project: Counter and Timer Display on Basys3 Board ⏱️

## Overview 📄

This project demonstrates the use of Verilog to design and implement a counter and timer on the **Basys3 FPGA development board** using **Vivado**. The counter is displayed on a connected VGA monitor, while the timer is shown on the 7-segment display (SSD) of the Basys3 board.

The design leverages the Basys3’s onboard components (7-segment display and VGA output) to provide an interactive and visual representation of the counter and timer.

---

## Features 📌

1. **Counter Display on VGA**  
   - Outputs an incrementing counter value to the VGA monitor.  
   - The VGA output is formatted with proper timing signals to meet the VGA protocol.  

2. **Timer Display on 7-Segment Display**  
   - Displays a timer (hours, minutes, or seconds depending on the configuration).  
   - Updates the SSD dynamically using multiplexing to show multiple digits.  

3. **User Control (Optional)**  
   - Buttons or switches can be used to start, stop, or reset the counter/timer.  

4. **Period Counting**  
   - The system can count specific periods or cycles, useful for timing intervals or event tracking.  
   - Configurable period durations to suit various applications, such as event-driven or periodic counting.  

---  

## Hardware Requirements 🔌

- **Basys3 Board**  
  - Artix-7 FPGA
  - 7-segment display
  - VGA output connector
- **VGA Monitor and Cable**  
  - For visualizing the counter output.

---

## Software Requirements 💻

- **Vivado Design Suite**  
  - Used for writing, simulating, and implementing Verilog code.
  - Configures the Basys3 board via a USB cable.

---



## How to Use

1. **Open the Project in Vivado**  
   - Create a new project in Vivado and import all Verilog source files.
   - Add the Basys3 constraints file to map the pin configurations.

2. **Synthesize and Implement**  
   - Run synthesis, implementation, and generate the bitstream.

3. **Program the Basys3 Board**  
   - Connect the Basys3 board to your computer via USB.
   - Load the generated bitstream onto the board.

4. **Connect a VGA Monitor**  
   - Connect a VGA monitor to the Basys3 board to see the counter display.

5. **Observe the Timer on SSD**  
   - The timer will display and update on the Basys3 7-segment display.

---

Enjoy experimenting with FPGA-based designs on your Basys3 board! 🚀
