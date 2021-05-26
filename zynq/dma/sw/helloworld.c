/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xaxidma.h"
#include "xuartps.h"
#include "xscugic.h"

/* User Headers */
#include "dma.h"
#include "datagen.h"

/* User parameters */
#define BUFFER_DEPTH 20
#define FRAME_SIZE 15
#define DATAGEN_DELAY 1000000000

#ifndef DDR_BASE_ADDR
#define MEM_BASE_ADDR 0x01000000
#else
#define MEM_BASE_ADDR (DDR_BASE_ADDR + 0x1000000)
#endif

#define BUFFER_BASE MEM_BASE_ADDR

/* Function prototypes */
int initIrq();

/* Axi DMA Instance */
XAxiDma AxiDma;

/* PS UART */
XUartPs UartPs;

/* Interrupt Controller */
XScuGic InterruptController;
static XScuGic_Config *GicConfig;

/* Flags for IRQ Handlers */
int datagenFlag;

int main()
{
	int Status;
	int i;

    init_platform();

    /* DMA buffer */
    u8 *RxBufferPtr = (u8 *)BUFFER_BASE;

    /* Initialize DMA */
    Status =  initDma(&AxiDma, XPAR_AXIDMA_0_DEVICE_ID);
    if (Status == XST_FAILURE){
    	return XST_FAILURE;
    }
    irqDisableDma(&AxiDma);

    /* Initialize Datagen */
    setDatagenFrameSize((u8)FRAME_SIZE);
    setDatagenDelay((u32)DATAGEN_DELAY);
    startDatagenCtr();

    /* Initialize PS UART */
    /*XUartPs_Config *UartPsConfigPtr;
    UartPsConfigPtr = XUartPs_LookupConfig(XPAR_PS7_UART_1_DEVICE_ID);
    Status = XUartPs_CfgInitialize(&UartPs, UartPsConfigPtr, UartPsConfigPtr->BaseAddress);
    if (Status != XST_SUCCESS){
    	print("Error Initializing PS UART\r\n");
    	return XST_FAILURE;
    }
    XUartPs_SetBaudRate(&UartPs, 115200);*/

    /* Initialize Interrupts */
    initIrq();
    datagenFlag = 0;

    /* Display buffer contents */
	xil_printf("***** Initial buffer contents: \n");
	for (i=0; i<BUFFER_DEPTH; i++){
		xil_printf("      Data[%d]: 0x%02X\n", i, RxBufferPtr[i]);
	}

	/* Enable DataGen Sample Generation */
	startDatagenSample();

    while(1){

    		print("***** Waiting for datagen transfer...\r\n");
    		i = 0;
    		while(datagenFlag == 0){
    			if (i==200000000){
    				xil_printf("Datagen Debug Reg: 0x%X\n", readDatagenDbg());
    				xil_printf("Datagen Status Reg: 0x%X\n", readDatagenStat());
    				i = 0;
    			}else{
    				i++;
    			}

    		}
    		datagenFlag = 0;

    		/* Flush buffer */
    		Xil_DCacheFlushRange((UINTPTR)RxBufferPtr, BUFFER_DEPTH);

    		/* Start AXI DMA transfer */
    		Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)RxBufferPtr, FRAME_SIZE, XAXIDMA_DEVICE_TO_DMA);
    		if (Status != XST_SUCCESS){
    			return XST_FAILURE;
    		}

    		/* Wait for transfer to complete */
    		i = 0;
    		while (XAxiDma_Busy(&AxiDma,XAXIDMA_DEVICE_TO_DMA)){
    			i++;
    		}
    		xil_printf("***** DMA busy counter: %d\n", i);

    		/* Display buffer contents */
    		Xil_DCacheInvalidateRange((UINTPTR)RxBufferPtr, BUFFER_DEPTH);
    		xil_printf("***** Buffer contents after DMA transfer: \n");
    		for (i=0; i<BUFFER_DEPTH; i++){
    			xil_printf("      Data[%d]: 0x%02X\n", i, RxBufferPtr[i]);
    		}


    }

    print("Successfully ran Hello World application");
    cleanup_platform();
    return 0;
}

/* Datagen IRQ Handler */
void datagenIrqHandler(void *InstancePtr){
	xil_printf("***** Datagen IRQ\n");
	datagenFlag = 1;
	clrDatagenIrq();
}

/* Setup interrupts */
int SetUpInterruptSystem(XScuGic *XScuGicInstancePtr){
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler) XScuGic_InterruptHandler, XScuGicInstancePtr);
	Xil_ExceptionEnable();
	return XST_SUCCESS;
}

int initIrq(){
	int Status;

	GicConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
	if (NULL == GicConfig){
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(&InterruptController, GicConfig, GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS){
		return XST_FAILURE;
	}

	Status = SetUpInterruptSystem(&InterruptController);
	if (Status != XST_SUCCESS){
		return XST_FAILURE;
	}

	Status = XScuGic_Connect(&InterruptController, XPAR_FABRIC_DATAGEN_AXIWRAPPER_0_IRQ_INTR,
			(Xil_ExceptionHandler)datagenIrqHandler, (void *)NULL);
	if (Status != XST_SUCCESS){
		return XST_FAILURE;
	}

	XScuGic_SetPriorityTriggerType(&InterruptController, XPAR_FABRIC_DATAGEN_AXIWRAPPER_0_IRQ_INTR, 0x0, 0x3);

	XScuGic_Enable(&InterruptController, XPAR_FABRIC_DATAGEN_AXIWRAPPER_0_IRQ_INTR);

	return XST_SUCCESS;
}
