#include <stdlib.h>
#include "xaxidma.h"
#include "xil_printf.h"

int initDma(XAxiDma *XAxiDmaPtr, u16 DeviceId){
	XAxiDma_Config *CfgPtr;
	int Status;

	CfgPtr = XAxiDma_LookupConfig(DeviceId);
	if (!CfgPtr){
		xil_printf("No config found for %d\r\n", DeviceId);
		return XST_FAILURE;
	}

	Status = XAxiDma_CfgInitialize(XAxiDmaPtr, CfgPtr);
	if (Status != XST_SUCCESS){
		xil_printf("Initilization failed %d\r\n", Status);
		return XST_FAILURE;
	}

	if (XAxiDma_HasSg(XAxiDmaPtr)){
		xil_printf("Device configured as SG mode \r\n");
		return XST_FAILURE;
	}
}

void irqDisableDma(XAxiDma *XAxiDmaPtr){
	XAxiDma_IntrDisable(XAxiDmaPtr, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(XAxiDmaPtr, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
}
