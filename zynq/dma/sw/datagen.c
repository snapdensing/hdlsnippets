//#include <stdio.h>
//#include "platform.h"
//#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"

void startDatagenCtr(){
	u32 regval;
	regval = Xil_In32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR);
	Xil_Out32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR, regval | 0x00000002);
}

void stopDatagenCtr(){
	u32 regval;
	regval = Xil_In32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR);
	Xil_Out32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR, regval & 0xFFFFFFFD);
}

void startDatagenSample(){
	u32 regval;
	regval = Xil_In32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR);
	Xil_Out32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR, regval | 0x00000001);
}

void stopDatagenSample(){
	u32 regval;
	regval = Xil_In32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR);
	Xil_Out32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR, regval & 0xFFFFFFFE);
}

void setDatagenFrameSize(u8 frameSize){
	u32 regval;
	regval = Xil_In32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR) & 0xFFFF00FF;
	Xil_Out32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR, regval | (u32)(frameSize << 8));
}

u8 getDatagenFrameSize(){
	return (u8)((Xil_In32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR) & 0x0000FF00) >> 8);
}

void setDatagenDelay(u32 delay){
	Xil_Out32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR + 8, delay);
}

u32 getDatagenDelay(){
	return Xil_In32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR + 8);
}

void clrDatagenIrq(){
	Xil_Out32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR + 4, 0x00000000);
}

u32 readDatagenCfg(){
	return Xil_In32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR);
}

u32 readDatagenStat(){
	return Xil_In32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR + 4);
}

u32 readDatagenDbg(){
	return Xil_In32(XPAR_DATAGEN_AXIWRAPPER_0_S00_AXI_BASEADDR + 12);
}
