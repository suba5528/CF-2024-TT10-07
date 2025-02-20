/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module SPI2 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    reg [7:0] data = 8'b10101001;          // Data to send via MISO
    reg [7:0] received_data;              // Data received from MOSI
    reg [2:0] state_mosi;                 // State for MOSI FSM
    reg [2:0] state_miso;                 // State for MISO FSM
    reg [7:0] read_data;                    // Data to send via MISO

    // State definitions
    localparam MOSI_IDLE_STATE  = 0;
    localparam MOSI_START_STATE = 1;
    localparam READ_STATE       = 2;
    localparam MOSI_STOP_STATE  = 3;
    localparam MISO_IDLE_STATE  = 4;
    localparam MISO_START_STATE = 5;
    localparam WRITE_STATE      = 6;
    localparam MISO_STOP_STATE  = 7;

    reg [3:0] mosi_counter;
    reg [3:0] miso_counter;
    wire spi_clk;
    reg miso_out;
    
    assign spi_clk = clk;
    assign uo_out  = 0;
    assign uio_out = 0;
    assign uio_oe  = 0;
    
    initial begin
        state_mosi = MOSI_IDLE_STATE;
        state_miso = MISO_IDLE_STATE;
        miso_out = 1;
    end

    // MOSI state machine (data reception from master)
    always @(negedge spi_clk) begin
        if (!rst_n) begin
            received_data = 0;
            state_mosi = MOSI_IDLE_STATE;
            mosi_counter = 7;
        end else begin
            case(state_mosi)
                MOSI_IDLE_STATE: begin
                    if (ui_in[0] == 0) state_mosi = MOSI_START_STATE;
                end
                MOSI_START_STATE: begin
                    if (ui_in[1] == 0) begin // Start bit detected
                        state_mosi = READ_STATE;
                        mosi_counter = 7;
                    end
                end
                READ_STATE: begin
                    received_data[mosi_counter] = ui_in[2]; // Store bit from MOSI
                    if (mosi_counter == 0) state_mosi = MOSI_STOP_STATE;
                    mosi_counter = mosi_counter - 1;
                end
                MOSI_STOP_STATE: state_mosi = MOSI_IDLE_STATE;
            endcase
        end
    end

    // MISO state machine (data transmission to master)
    always @(posedge spi_clk) begin
        if (!rst_n) begin
            read_data = 0;
            state_miso = MISO_IDLE_STATE;
            miso_counter = 7;
        end else begin
            case(state_miso)
                MISO_IDLE_STATE: begin
                    if (ui_in[0] == 0) state_miso = MISO_START_STATE;
                end
                MISO_START_STATE: begin
                    miso_out = 0; // Start bit
                    state_miso = WRITE_STATE;
                    read_data = received_data;
                    miso_counter = 7;
                end
                WRITE_STATE: begin
                    miso_out = read_data[miso_counter]; // Send bit to MISO
                    if (miso_counter == 0) state_miso = MISO_STOP_STATE;
                    miso_counter = miso_counter - 1;
                end
                MISO_STOP_STATE: begin
                    miso_out = 1; // Stop bit
                    state_miso = MISO_IDLE_STATE;
                end
            endcase
        end
    end

    // Unused input assignments to avoid warnings
    wire _unused = &{ena, 1'b0};

endmodule
