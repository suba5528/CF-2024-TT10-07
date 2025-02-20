<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
This Verilog module implements an SPI (Serial Peripheral Interface) Slave device. It communicates with an SPI Master, receiving data via MOSI (Master Out Slave In) and sending data via MISO (Master In Slave Out). The module uses Finite State Machines (FSMs) to control data reception and transmission.



## How to test

 For testin FPGA, Connect an SPI Master (like an Arduino) to the slave(FPGA) module.
Use 4 SPI signals: cs, clock_in, mosi, and miso.
Monitor MISO to check if data transmission is correct.

## External hardware

Basys3 FPGA board
