# 🚀 DRAM Model in Verilog

This repository contains a complete Verilog implementation of a **behavioral DRAM (Dynamic Random-Access Memory) Model**, supporting read, write, partial writes, refresh cycles and full functional verification.

---

## 📑 Table of Contents

- [🔎 Overview](#-overview)
- [🖼 Block Diagram](#-block-diagram)
- [📥 I/O Port Descriptions](#-io-port-descriptions)
- [✨ Features](#-features)
- [📁 Modules](#-modules)
- [🧪 Testbench Description](#-testbench-description)
- [▶️ Simulation](#-simulation)

---

## 🔎 Overview

This project models a simplified DRAM that implements:

- 🗃 **256K x 16-bit memory array**
- 🕹 Row/Column multiplexed addressing using **RAS/CAS** strobes
- ✏️ Full word write and selective upper/lower byte writes
- 🔄 CAS-before-RAS refresh detection logic
- 🔌 Bidirectional data bus with tri-state behavior
- 🧪 Fully verified using a functional testbench

---

## 🖼 Block Diagram

![DRAM Block Diagram](https://raw.githubusercontent.com/Srikar109755/DRAM_Model/main/DRAM/images/DRAM_Block_Diagram.png)

---

## 📥 I/O Port Descriptions

| 🔢 Port Name | 🔠 Width  | 🔁 Direction | 📝 Description |
| ----------- | -------- | --------- | ----------- |
| `DATA`    | 16-bit | inout     | Bidirectional data bus |
| `MA`      | 10-bit | input     | Multiplexed row/column address |
| `RAS_N`   | 1-bit  | input     | Row Address Strobe (**active low**) |
| `CAS_N`   | 1-bit  | input     | Column Address Strobe (**active low**) |
| `LWE_N`   | 1-bit  | input     | Lower Write Enable (**active low**) |
| `UWE_N`   | 1-bit  | input     | Upper Write Enable (**active low**) |
| `OE_N`    | 1-bit  | input     | Output Enable (**active low**) |

> ⚠️ **Note:** All control signals ending with `_N` are active-low.

---

## ✨ Features

- ✅ **256K x 16-bit memory** (total 4 Mbit capacity)
- ✅ Full read and write operations
- ✅ Selective lower or upper byte writes
- ✅ CAS-before-RAS refresh cycle support
- ✅ Proper tri-state bidirectional data bus modeling
- ✅ Supports preloading data from file (`Data_DRAM.txt`)
- ✅ Comprehensive testbench for full functional validation

---

## 📁 Modules

### 📄 `DRAM.v`

- Core DRAM functionality:
  - Row/Column address decoding
  - Read, full write, partial byte writes
  - CAS-before-RAS refresh detection
  - Bidirectional bus behavior

### 🧪 `DRAM_tb.v`

- Full-featured testbench that validates:
  - Full word read/write
  - Partial upper/lower byte write
  - Refresh cycle simulation
  - Console display of all memory operations

---

## 🧪 Testbench Description

The testbench exercises multiple scenarios:

- 📝 Full write ➡ full read
- 📝 Partial lower byte write ➡ read
- 📝 Partial upper byte write ➡ read
- 🔄 CAS-before-RAS refresh

---

## ▶️ Simulation

You can simulate using:

- ModelSim
- Vivado XSIM
- Verilator
- VCS

### ModelSim Example:

```bash
vlog DRAM.v DRAM_tb.v
vsim DRAM_tb
