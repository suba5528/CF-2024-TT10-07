`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg cs;
  reg mosi;
  wire miso;
  wire sclk;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Instantiate the SPI module
  tt_um_suba (

`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  ({4'b0000, rst_n, clk, mosi, cs}),  // Inputs
      .uo_out ({miso, sclk, 6'b000000}),          // Outputs
      .uio_in  (8'b00000000),                    // Bidirectional IOs (not used)
      .uio_out (),
      .uio_oe (),
      .ena    (1'b1) // Enable always high
  );

  // Generate clock signal for the simulation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // Toggle clock every 5 time units
  end

  // Test sequence
  initial begin
    rst_n = 0;
    cs = 1;
    mosi = 0;

    #10 rst_n = 1; // Release reset
    #10 cs = 0; // Assert CS

    // Send 8-bit data sequence via MOSI
    #20 mosi = 1;
    #10 mosi = 0;
    #10 mosi = 1;
    #10 mosi = 0;
    #10 mosi = 1;
    #10 mosi = 1;
    #10 mosi = 0;
    #10 mosi = 0;

    #20 cs = 1; // Deassert CS
    mosi = 0;

    #20 cs = 0;
    #20 mosi = 0;
    #10 mosi = 0;
    #10 mosi = 1;
    #10 mosi = 0;
    #10 mosi = 0;
    #10 mosi = 1;
    #10 mosi = 0;
    #10 mosi = 1;

    #20 cs = 1;
    mosi = 0;

    #20 cs = 0;
    #20 mosi = 0;
    #10 mosi = 0;
    #10 mosi = 0;
    #10 mosi = 1;
    #10 mosi = 0;
    #10 mosi = 0;
    #10 mosi = 0;
    #10 mosi = 1;

    #20 cs = 1;
    mosi = 0;

    #20 cs = 0;
    #20 mosi = 1;
    #10 mosi = 0;
    #10 mosi = 0;
    #10 mosi = 0;
    #10 mosi = 1;
    #10 mosi = 0;
    #10 mosi = 0;
    #10 mosi = 0;

    #20 cs = 1;
    mosi = 0;

    // Wait and finish simulation
    #100 $finish;
  end

  // Monitor signals for debugging
  initial begin
    $monitor("Time=%0t | RST=%b | Clock=%b | MOSI=%b | MISO=%b | SCLK=%b | CS=%b", 
             $time, rst_n, clk, mosi, miso, sclk, cs);
  end

endmodule

