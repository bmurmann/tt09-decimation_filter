/*
 * Copyright (c) 2024 Andrea Murillo Martinez & Jaeden Chang
 * SPDX-License-Identifier: Apache-2.0
 */

module tt_um_murmann_group (input  wire [7:0] ui_in,    // Dedicated inputs
                            output wire [7:0] uo_out,   // Dedicated outputs
                            input  wire [7:0] uio_in,   // IOs: Input path
                            output wire [7:0] uio_out,  // IOs: Output path
                            output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
                            input  wire       ena,      // will go high when the design is enabled
                            input  wire       clk,      // clock
                            input  wire       rst_n     // reset_n - low to reset
                           );
    
    // List all unused inputs to prevent warnings
    wire _unused = &{ui_in[7:2],ena,1'b0};

	// Declare wires
	wire X;
	wire type_dec;

  	// ADC 1 bit inpput
    assign X = ui_in[0];
  	// Type of decimation (incremental or regular delta-digma modulator)
    // 0: Incremental DSM (type 1)
    // 1: Regulat DSM (type 2)
  	assign type_dec = ui_in[1];

    // Output of the decimation filter (Z in decimation_filter module)
    wire [15:0] decimation_output; 

    // Enable the all uio pins for output
    assign uio_oe = 8'b11111111;
    
    // Assign most significant 8 bits to the dedicated output pins
    assign uo_out = decimation_output[15:8];

    // Assign less significant 8 bits to the general-purpose IO pins
    assign uio_out = decimation_output[7:0];

    
    decimation_filter my_decimation_filter(.clk(clk),
                                           .reset(~rst_n),
                                           .X(X),
                                           .type_dec(type_dec),
                                           .Z(decimation_output)
                                          );
    
endmodule

module decimation_filter 
  #(parameter OUTPUT_BITS = 16, // Bit-width of output
    parameter M = 16            // Decimation factor
   )(
    input wire clk,             // Clock
    input wire reset,           // Reset
    input wire X,               // Input data from ADC
    input wire type_dec,        // DSM type for decimation (0 = Type 1, 1 = Type 2)
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

    // Initialize everything to zero
    initial begin
      input_accumulator = 0;
      Y = 0;
      comb_1 = 0;
      comb_2 = 0;
      decimation_count = 0;
      Z = 0;
    end

    always @(posedge clk) begin
        $display("Time %0t: reset = %b, type_dec = %b, X = %b, input_accumulator = %d, Y = %d, decimation_count = %d, Output = %d", 
                 $time, reset, type_dec, X, input_accumulator, Y, decimation_count, Z);
        $display("Prev reset = %b", reset_d);
        
        // Detect positive edge of reset
        if ((reset && !reset_d) || (type_dec_d ^ type_dec)) begin
            $display("Edge Reset ON");

            if ((type_dec_d ^ type_dec) || type_dec) begin
                Z <= 0;
            end else begin
                $display("Sending Output for type_dec %b", type_dec);
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
            $display("X = %b", X);
            // Integrator stage (accumulate input samples)
            input_accumulator <= input_accumulator + X;
            Y <= Y + input_accumulator;

            $display("input_accumulator = %b, Y = %b, decimation_count = %b", input_accumulator, Y, decimation_count);

            // Decimation control based on type
            if (type_dec) begin
                // Type 2: Regular DSM with decimation control
                if (decimation_count == M - 1) begin
                    // Comb stage (only every M cycles)
                    comb_1 <= Y;
                    comb_2 <= comb_1;
                    Z <= comb_1 - comb_2;
                    $display("comb1 = %b, comb2 = %b, Output = %b", comb_1, comb_2, Z);

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
endmodule
