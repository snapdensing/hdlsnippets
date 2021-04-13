#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

#include "xscugic.h"
#include "xparameters.h"

XScuGic InterruptController;
static XScuGic_Config *GicConfig;

void ExtIrq_Handler(void *InstancePtr)
{
	xil_printf("ExtIrq_Handler\r\n");
}

int SetUpInterruptSystem(XScuGic *XScuGicInstancePtr)
{
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler) XScuGic_InterruptHandler, XScuGicInstancePtr);
	Xil_ExceptionEnable();
	return XST_SUCCESS;
}

int interrupt_init()
{
	int Status;

	GicConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
	if (NULL == GicConfig) {
		return XST_FAILURE;
	}
	Status = XScuGic_CfgInitialize(&InterruptController, GicConfig, GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = SetUpInterruptSystem(&InterruptController);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = XScuGic_Connect(&InterruptController, XPAR_FABRIC_PLTIMER_0_TRIG_OUT_INTR, (Xil_ExceptionHandler)ExtIrq_Handler, (void *)NULL);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/* Change IRQ Trigger to Rising Edge */
	XScuGic_SetPriorityTriggerType(&InterruptController, XPAR_FABRIC_PLTIMER_0_TRIG_OUT_INTR, 0x0, 0x3);

	XScuGic_Enable(&InterruptController, XPAR_FABRIC_PLTIMER_0_TRIG_OUT_INTR);

	return XST_SUCCESS;
}

int main()
{
    init_platform();

    print("Hello World\n\r");

    interrupt_init();

    while(1);

    print("Successfully ran Hello World application");
    cleanup_platform();
    return 0;
}
