`timescale 1ns/1ps
module datagen(
  clk,
  nrst,
  en_ctr,
  en_sample,
  frame_size,
  done,
  clr,
  delay,
  m_axis_tvalid,
  m_axis_tready,
  m_axis_tlast,
  m_axis_tdata,
  
  debug_state,
  debug_ctr
  );

  input clk,nrst;
  input en_ctr,en_sample;
  input [7:0] frame_size;
  output done;
  input clr;
  input [31:0] delay;
  
  output [1:0] debug_state;
  output [7:0] debug_ctr;

  /* AXI Stream master */
  output m_axis_tvalid;
  input m_axis_tready;
  output m_axis_tlast;
  output [7:0] m_axis_tdata;

  /* Free-running counter */
  reg [7:0] ctr;
  always@(posedge clk)
    if (!nrst)
      ctr <= 0;
    else
      if (en_ctr)
        ctr <= ctr + 1;
      else
        ctr <= ctr;

  /* State machine */
  parameter S_IDLE   = 2'd0;
  parameter S_DELAY  = 2'd1;
  parameter S_SAMPLE = 2'd2;
  parameter S_STREAM = 2'd3;
  reg [1:0] state;

  /* Buffer */
  reg [7:0] buffer [0:255];
  reg [7:0] buf_tail,buf_ptr;

  always@(posedge clk)
    if (state == S_SAMPLE)
      buffer[buf_tail] <= ctr;

  always@(posedge clk)
    if (!nrst)
      buf_tail <= 0;
    else
      case(state)
        S_SAMPLE:
          buf_tail <= buf_tail + 1;
        S_STREAM:
          buf_tail <= buf_tail;
        default:
          buf_tail <= 0;
      endcase

  /* Delay counter */
  reg [31:0] delay_ctr;
  always@(posedge clk)
    if (!nrst)
      delay_ctr <= 0;
    else
      if (state == S_DELAY)
        delay_ctr <= delay_ctr + 1;
      else
        delay_ctr <= 0;
  
  /* State machine */    
  always@(posedge clk)
    if (!nrst)
      state <= S_IDLE;
    else
      case(state)
        S_IDLE:
          if (en_sample)
            state <= S_DELAY;
          else
            state <= S_IDLE;

        S_DELAY:
          if (en_sample) 
            if (delay_ctr == delay)
              state <= S_SAMPLE;
            else
              state <= S_DELAY;
          else
            state <= S_IDLE;

        S_SAMPLE:
          if (en_sample)
            if (buf_tail == frame_size)
              state <= S_STREAM;
            else
              state <= S_SAMPLE;
          else
            state <= S_IDLE;

        S_STREAM:
          if (buf_ptr == frame_size)
            state <= S_DELAY;
          else
            state <= S_STREAM;

      endcase

  /* Done signal */
  reg done;
  always@(posedge clk)
    if (!nrst)
      done <= 0;
    else
      case(state)
        S_SAMPLE:
          if (buf_tail == frame_size)
            done <= 1'b1; // latch up
          else
            done <= 0;

        S_STREAM:
          if (done) // latch down
            if (clr)
              done <= 0;
            else
              done <= 1'b1;
          else
            done <= 0;
            
        default:
          done <= 0;
      endcase

  /* AXI Stream master interface */
  assign m_axis_tvalid = (state == S_STREAM)? 1'b1 : 0;
  assign m_axis_tdata = buffer[buf_ptr];
  assign m_axis_tlast = ((state == S_STREAM) && (buf_ptr == frame_size))? 1'b1 :0;  
 
  always@(posedge clk)
    if (!nrst)
      buf_ptr <= 0;
    else
      if (state == S_STREAM)
        if (m_axis_tvalid && m_axis_tready)
          buf_ptr <= buf_ptr + 1;
        else
          buf_ptr <= buf_ptr;
      else
        buf_ptr <= 0;
        
  assign debug_state = state;
  assign debug_ctr = ctr;
endmodule
