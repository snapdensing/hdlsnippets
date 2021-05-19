`timescale 1ns/1ps
`define CLK_PERIOD 10

module tb_datagen;

  reg clk,nrst;
  reg en_ctr,en_sample;
  reg [7:0] frame_size;
  wire done;
  reg clr;
  reg [31:0] delay;

  /* AXI Stream master */
  wire m_axis_tvalid;
  reg m_axis_tready;
  wire m_axis_tlast;
  wire [7:0] m_axis_tdata;

  datagen UUT(
    .clk(clk),
    .nrst(nrst),
    .en_ctr(en_ctr),
    .en_sample(en_sample),
    .frame_size(frame_size),
    .done(done),
    .clr(clr),
    .delay(delay),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tdata(m_axis_tdata)
    );

  always begin
    #(`CLK_PERIOD/2) clk = ~clk;
  end
 
  initial begin
    clk = 0;
    nrst = 0;
    en_ctr = 0;
    en_sample = 0;
    frame_size = 8'd10;
    clr = 0;
    delay = 32'd10;
    m_axis_tready = 0;

    #(`CLK_PERIOD*10)
    nrst = 1'b1;

    #(`CLK_PERIOD*5)
    en_ctr = 1'b1;

    #(`CLK_PERIOD*5)
    en_sample = 1'b1;

    while(!done)
      #(`CLK_PERIOD);

    clr = 1'b1;
    #(`CLK_PERIOD);
    clr = 0;
    #(`CLK_PERIOD); 
    m_axis_tready = 1'b1; 

    while(!m_axis_tlast)
      #(`CLK_PERIOD);

    m_axis_tready = 0;
  end
endmodule
