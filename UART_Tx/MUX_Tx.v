//-----------------------------------------------------------------------------
// Title       : UART Transmission Multiplexer
// Project     : UART Communication System
// File        : MUX_Tx.v
// Author      : Abdelhameed Mahmoud
// Description : 4-to-1 multiplexer used to select the UART transmit output
//               between stop bit, start bit, serial data, or parity bit.
//-----------------------------------------------------------------------------

module MUX_Tx (
    input  wire       Serial_Data,  // Serial data bit from shift register
    input  wire       Parity_bit,   // Parity bit from parity generator
    input  wire [1:0] Selector,     // 2-bit select signal
    output reg        Tx_OUT        // Output signal for UART transmission
);

    //=========================================================================
    // Parameter Declarations
    //=========================================================================
    localparam Stop_bit  = 1'b1;  // UART Stop bit 
    localparam Start_bit = 1'b0;  // UART Start bit 

    //=========================================================================
    // Combinational Logic
    //=========================================================================
    always @(*) begin
        case (Selector)
            2'b00: Tx_OUT = Stop_bit;    // Send stop bit
            2'b01: Tx_OUT = Start_bit;   // Send start bit
            2'b10: Tx_OUT = Serial_Data; // Send data bit
            2'b11: Tx_OUT = Parity_bit;  // Send parity bit
            default: Tx_OUT = Stop_bit;  // Default to stop bit for safety
        endcase
    end

endmodule
