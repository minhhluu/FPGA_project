# 🌡️ DHT11 Sensor FSM – State Descriptions & 1-Wire Protocol Guide

This Finite State Machine (FSM) implements communication with a **DHT11** sensor over a **1-Wire single data line**. It reads temperature and humidity data by decoding time-based signal patterns.

[![FSM-1-wire.png](https://i.postimg.cc/1XPVwh1s/FSM-1-wire.png)](https://postimg.cc/7GsLrRLW)

## 📘 DHT11 Protocol Overview

### 🔌 Signal Roles
- The **FPGA** initiates communication.
- The **DHT11 sensor** responds and transmits 40 bits (5 bytes) of data.

### 📦 Data Packet Format (40 bits)
| Byte | Description          |
|------|----------------------|
| 1    | Humidity Integer     |
| 2    | Humidity Decimal     |
| 3    | Temperature Integer  |
| 4    | Temperature Decimal  |
| 5    | Checksum = Byte1 + Byte2 + Byte3 + Byte4

---

## 🕒 Timing Details – Bit Encoding

Each bit is encoded by:
- **Start**: 50 µs LOW signal
- **Followed by**: variable HIGH signal

| Bit Value | LOW Time | HIGH Time | Meaning             |
|-----------|----------|-----------|---------------------|
| `'0'`     | ~50 µs   | ~26–28 µs | Logical 0           |
| `'1'`     | ~50 µs   | ~70 µs    | Logical 1           |

### 📉 Logic `'0'` Timing Diagram

![Data 0](https://i.postimg.cc/tgQ6pVvs/data-0.png)  
**Figure 4**: A logic **'0'** is transmitted by:
- 50 µs LOW
- ~26–28 µs HIGH

---

### 📈 Logic `'1'` Timing Diagram

![Data 1](https://i.postimg.cc/2yskhnZv/data-1.png)
**Figure 5**: A logic **'1'** is transmitted by:
- 50 µs LOW
- ~70 µs HIGH

---

## 🔁 FSM State Descriptions

### 💤 IDLE
- **State**: Waiting for a read trigger.
- **Transition**: `cnt > START_LOW → START_LOW`

---

### 🔧 START_LOW
- **Purpose**: MCU pulls the line LOW (≥18 ms).
- **Transition**: `cnt > WAIT_RESPONSE → WAIT_HIGH`

---

### ⏳ WAIT_HIGH
- **Purpose**: Wait for the sensor to pull the line LOW (ACK).
- **Transition**: `dht_io_in == 0 → WAIT_RESP_LOW`

---

### ⬇️ WAIT_RESP_LOW
- **Purpose**: DHT pulls line LOW for ~80 µs.
- **Transition**: `cnt > DELAY_80 → WAIT_RESP_HIGH`

---

### ⬆️ WAIT_RESP_HIGH
- **Purpose**: DHT pulls line HIGH for ~80 µs (handshake).
- **Transition**: `dht_io_in == 1 && cnt > DELAY_80 → READ_DATA`

---

### 📥 READ_DATA
- **Purpose**: Read 40 bits (5 bytes)
  - For each bit:
    - 50 µs LOW (fixed)
    - HIGH duration indicates logic `'0'` or `'1'`
- **Transition**: `bit_count == 39 → WAIT_CHECKSUM`

---

### ⏱️ WAIT_CHECKSUM
- **Purpose**: Buffer before checksum validation.
- **Transition**: `next → CHECKSUM`

---

### 🧮 CHECKSUM
- **Purpose**: Validate 5th byte = sum of previous 4 bytes.
- **Transition**: `next → DONE`

---

### ✅ DONE
- **Purpose**: End state, data ready for processing.
- **Transition**: `cnt > START_LOW → START_LOW` (next read cycle)

---

## 🔍 Summary of Critical Timings

| Phase             | Duration        | Description                            |
|------------------|------------------|----------------------------------------|
| MCU Start Signal | ≥18 ms           | Host pulls data line LOW               |
| DHT Response     | ~80 µs LOW + ~80 µs HIGH | Acknowledgment sequence       |
| Data Bit `'0'`   | 50 µs LOW + 26–28 µs HIGH | Logical 0 bit                 |
| Data Bit `'1'`   | 50 µs LOW + 70 µs HIGH     | Logical 1 bit                 |

---

## 📚 References

- 📝 Official Datasheet: [DHT11 Technical Data Sheet (Mouser)](https://www.mouser.com/datasheet/2/758/DHT11-Technical-Data-Sheet-Translated-Version-1143054.pdf?srsltid=AfmBOoppmOsYqqrDa_1h-ueCuj3xBtRUHrJL2iQqnzX5UGalZBZ7McdP)
