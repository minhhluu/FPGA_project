# 🖥️ FPGA Project – LCD Contrast Control + Temperature Display

## 📌 Overview

This project includes two FPGA-based implementations:

1. **LCD Contrast Control with Buttons** – Adjust the LCD contrast using two tactile buttons (Basys3, Xilinx).
2. **Real-Time Temperature Visualization** – Display temperature data in real time using WS2812 RGB LEDs (Altera DE2).


## 📘 Project Descriptions

### 1️⃣ LCD 4-bit Controller with Contrast Adjustment  
- **Platform**: Basys3 (Xilinx)  
- **Functionality**:
  - Interface with a 16x2 LCD in 4-bit mode  
  - Adjust LCD contrast via two hardware buttons  

🔗 [View Source Code & Implementation](https://github.com/minhhluu/FPGA_project/tree/main/Basys3_xilinx/LCD_4bit_controller_source)

**📸 Screenshot:**  
![basys3_lcd_4bit](https://i.postimg.cc/NjZCVFsk/3c678689633ad164882b.jpg)

---

### 2️⃣ Real-Time Temperature Display with WS2812 RGB LEDs  
- **Platform**: Altera DE2  
- **Functionality**:
  - Read temperature data from a sensor  
  - Visualize temperature using a WS2812 RGB LED strip in real time  

🔗 [View Source Code & Implementation](https://github.com/minhhluu/FPGA_project/tree/main/Altera_DE2)

**📸 Screenshot:**  
![FPGA_sys](https://i.postimg.cc/SRmyQmcF/8f7feb397774c12a9865.jpg)

---

## 🛠️ Key Features

- Full Verilog/VHDL hardware descriptions  
- Real hardware testing on both Basys3 and Altera DE2  
- Modular, reusable, and well-documented code  
- Clear mapping of hardware interfaces and peripherals  
