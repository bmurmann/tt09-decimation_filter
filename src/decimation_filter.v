/*
 * Copyright (c) 2024 Andrea Murillo Martinez & Jaeden Chang, BM
 * SPDX-License-Identifier: Apache-2.0
 */

module tt_um_murmann_group (
    input  wire [7:0] ui_in,     // Dedicated inputs
    output wire [7:0] uo_out,    // Dedicated outputs
    input  wire [7:0] uio_in,    // IOs: Input path
    output wire [7:0] uio_out,   // IOs: Output path
    output wire [7:0] uio_oe,    // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,       // Will go high when the design is enabled
    input  wire       clk,       // Clock
    input  wire       rst_n      // Reset (active low)
);

    // Prevent warnings for unused inputs
    wire _unused = &{ui_in[7:3], uio_in[7:0], ena, 1'b0};

    // Declare wires
    wire X;
    wire type_dec;
    wire global_reset;

    // ADC 1-bit input
    assign X = ui_in[0];

    // Type of decimation (incremental or regular delta-sigma modulator)
    // 0: Incremental DSM (type 1)
    // 1: Regular DSM (type 2)
    assign type_dec = ui_in[1];

    // Global reset, evaluated at t = 0
    assign global_reset = ui_in[2];

    // Output of the decimation filter (Z in decimation_filter module)
    wire [15:0] decimation_output;

    // Enable all uio pins for output
    assign uio_oe = 8'b11111111;

    // Assign most significant 8 bits to the dedicated output pins
    assign uo_out = decimation_output[15:8];

    // Assign least significant 8 bits to the general-purpose IO pins
    assign uio_out = decimation_output[7:0];

    // Instantiate the decimation filter
    decimation_filter my_decimation_filter(
        .clk(clk),
        .reset(~rst_n),
        .X(X),
        .type_dec(type_dec),
        .global_reset(global_reset),
        .Z(decimation_output)
    );

endmodule

module decimation_filter 
    #(parameter OUTPUT_BITS = 16, // Bit-width of output
      parameter M = 16            // Decimation factor
    )(
    input  wire clk,                // Clock
    input  wire reset,              // Reset
    input  wire X,                  // Input data from ADC
    input  wire type_dec,           // DSM type for decimation (0 = Type 1, 1 = Type 2)
    input  wire global_reset,       // Global reset, evaluated only at t = 0
    output reg [OUTPUT_BITS-1:0] Z  // Decimated output data
);

    // Integrator stage register
    reg [OUTPUT_BITS-1:0] input_accumulator;
    reg [OUTPUT_BITS-1:0] Y;

    // Comb stage registers
    reg [OUTPUT_BITS-1:0] comb_1;
    reg [OUTPUT_BITS-1:0] comb_2;

    // Decimation counter register
    reg [6:0] decimation_count;

    // Previous reset state to detect edges
    reg reset_d;

    // Previous decimation type to reset if it changes
    reg type_dec_d;

    always @(posedge clk) begin
        if (global_reset) begin
            // Global initialization at t=0
            input_accumulator <= 0;
            Y <= 0;
            comb_1 <= 0;
            comb_2 <= 0;
            decimation_count <= 0;
            Z <= 0;
            reset_d <= 0;
            type_dec_d <= type_dec;
        end else begin
            // Detect positive edge of reset or type change
            if ((reset && !reset_d) || (type_dec_d ^ type_dec)) begin
                if ((type_dec_d ^ type_dec) || type_dec) begin
                    Z <= 0;
                end else begin
                    // Type 1: Incremental DSM, output when reset is active
                    Z <= Y;
                end

                // Reset internal states
                input_accumulator <= 0;
                Y <= 0;
                comb_1 <= 0;
                comb_2 <= 0;
                decimation_count <= 0;

            end else begin
                // Integrator stage (accumulate input samples)
                input_accumulator <= input_accumulator + {15'b0, X};
                Y <= Y + input_accumulator;

                // Decimation control based on type
                if (type_dec) begin
                    // Type 2: Regular DSM with decimation control
                    if (decimation_count == M - 1) begin
                        // Comb stage (only every M cycles)
                        comb_1 <= Y;
                        comb_2 <= comb_1;
                        Z <= comb_1 - comb_2;

                        // Reset integrators and decimation counter
                        input_accumulator <= 0;
                        Y <= 0;
                        decimation_count <= 0;
                    end else begin
                        // Increment decimation counter
                        decimation_count <= decimation_count + 1;
                    end
                end 
            end
            // Update reset_d to detect the next reset edge
            reset_d <= reset;
            // Update type_dec_d to detect change
            type_dec_d <= type_dec;
        end
    end
endmodule
