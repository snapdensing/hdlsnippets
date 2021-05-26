# Test System for AXI DMA (Simple)

The system demonstrates the use of AXI DMA to automatically forward AXI stream data to DDR Memory. 

## Hardware system
The hardware system consists of the Zynq PS, AXI DMA, and an AXI Lite-wrapped block called Datagen. Datagen contains a free-running 8-bit counter. A separate enable signal allows Datagen to sample the counter output and forward this to the DMA using an AXI Stream master interface.

The AXI Stream master consists of 8-bit data sampled from the free-running counter. The number of bytes transferred for the whole stream is configurable through one of the AXI Lite memory mapped registers of Datagen. Samples for the stream are stored in an internal buffer. Once all samples have been collected, Datagen generates an interrupt request to the Zynq PS, which would in turn activate the AXI DMA block to collect stream data from Datagen.

To build the Vivado block diagram, source the file `./tcl/build_system.tcl`. This file automatically creates a Vivado project in the dma root directory. Once the block diagram is built, proceed to generate an HDL wrapper for it and through Synthesis, Implementation, and bitstream generation. You may then export the hardware system for use in Vitis. The tcl script was created using Vivado version 2020.1.

## Software

Bare-metal drivers for the system are located in the `./sw` directory. The software initially configures and enable Datagen and proceeds to a loop which waits for Datagen's interrupt request. Once the request is received, it enables the AXI DMA to receive the stream and store to DDR.

## To-do

As of now, the interrupt generation is set to edge-triggered. Further modifications to Datagen must be done to change this into a level-sensitive interrupt.