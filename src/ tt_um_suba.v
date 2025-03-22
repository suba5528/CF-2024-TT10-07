/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

`timescale 1ns / 1ps

module tt_um_suba (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output reg [7:0] uio_out,   // IOs: Output path
    output reg [7:0] uio_oe,    // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // Always 1 when the design is powered
    input  wire       clk,      // Clock
    input  wire       rst_n     // Reset (active low)
);
    // Internal registers
    reg [7:0] received_data;  // Data received from MOSI
    reg [7:0] transmit_data = 8'b10101001; // Data to send via MISO
    reg [2:0] state_mosi;     // MOSI state machine
    reg [2:0] state_miso;     // MISO state machine
    reg [3:0] mosi_counter;
    reg [3:0] miso_counter;
    reg miso_out;

    // Assignments
    wire cs   = ui_in[0]; // Chip Select
    wire mosi = ui_in[1]; // MOSI input
    wire spi_clk = clk;
    
    assign uo_out  = {7'b0, miso_out};
    
    // Ensure uio_out and uio_oe are correctly initialized
    always @(*) begin
        uio_out = 8'b0;
        uio_oe = 8'b0;
    end
    
    // MOSI State Machine (Receiving Data)
    always @(negedge spi_clk or negedge rst_n) begin
        if (!rst_n) begin
            received_data <= 8'b0;
            state_mosi <= 0;
            mosi_counter <= 7;
        end else begin
            case(state_mosi)
                0: if (!cs) state_mosi <= 1;
                1: if (!cs) begin
                        state_mosi <= 2;
                        mosi_counter <= 7;
                   end
                2: begin
                    received_data[mosi_counter] <= mosi;
                    if (mosi_counter == 0) state_mosi <= 3;
                    else mosi_counter <= mosi_counter - 1;
                   end
                3: state_mosi <= 0;
            endcase
        end
    end

    // MISO State Machine (Transmitting Data)
    always @(posedge spi_clk or negedge rst_n) begin
        if (!rst_n) begin
            state_miso <= 0;
            miso_counter <= 7;
            miso_out <= 1;
        end else begin
            case(state_miso)
                0: if (!cs) state_miso <= 1;
                1: begin
                    miso_out <= 0;
                    state_miso <= 2;
                    miso_counter <= 7;
                   end
                2: begin
                    miso_out <= transmit_data[miso_counter];
                    if (miso_counter == 0) state_miso <= 3;
                    else miso_counter <= miso_counter - 1;
                   end
                3: begin
                    miso_out <= 1;
                    state_miso <= 0;
                   end
            endcase
        end
    end

    // Unused input assignments to avoid warnings
    wire _unused = &{ena, ui_in[7:2], uio_in[7:0]};

endmodule

