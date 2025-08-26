//-----------------------------------------------------------------------------
// Title       : UART Parity Bit Generator
// Project     : UART Communication System
// File        : Parity_Tx.v
// Author      : Abdelhameed Mahmoud
// Description : This module generates a parity bit based on input data and
//               parity type. It supports even and odd parity generation.
//-----------------------------------------------------------------------------


module Parity_Tx (
    input  wire [7:0] P_Data,      // Parallel 8-bit data to generate parity for
    input  wire       Data_Valid,  // Indicates when P_Data is valid (active high)
    input  wire       Parity_Ty,   // Parity type: 0 = Even, 1 = Odd
    output reg        Par_bit      // Output parity bit
);

    //=========================================================================
    // Combinational Logic
    //=========================================================================
    always @(*) begin

            case ({Parity_Ty, ^P_Data})
                2'b00: Par_bit = 1'b0; // Even parity, even ones -> parity = 0
                2'b01: Par_bit = 1'b1; // Even parity, odd ones  -> parity = 1
                2'b10: Par_bit = 1'b1; // Odd parity, even ones  -> parity = 1
                2'b11: Par_bit = 1'b0; // Odd parity, odd ones   -> parity = 0
                default: Par_bit = 1'b0;
            endcase
   
    end

endmodule
