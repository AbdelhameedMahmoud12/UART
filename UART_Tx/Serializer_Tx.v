//-----------------------------------------------------------------------------
// Title       : UART Serializer
// Project     : UART Communication System
// File        : Serialzer_Tx.v
// Author      : Abdelhameed Mahmoud
// Description : Shifts 8-bit parallel data into serial format one bit at a time,
//               LSB first, controlled by Enable signal from counter.
//-----------------------------------------------------------------------------

module Serialzer_Tx (
    input  wire [7:0] P_Data,       // Parallel input data
    input  wire       Data_Valid,   // High when P_Data is valid
    input  wire       Enable,       // One-cycle pulse to trigger shifting
    input  wire       CLK,          // System clock
    input  wire       RST,          // Active-low reset
    input  wire       Busy,         // High when FSM is sending bits
    output wire       Serial_Data   // Serial bit output (LSB first)
);

    //=========================================================================
    // Internal Register
    //=========================================================================
    reg [7:0] Shift_Reg;  

    //=========================================================================
    // Output Assignment
    //=========================================================================
    assign Serial_Data = Shift_Reg[0];  

    //=========================================================================
    // Shift Register Logic
    //=========================================================================
    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            Shift_Reg <= 8'b0000_0000;
        end else if (Data_Valid && !Busy) begin
            // Load data only when valid and transmitter is idle
            Shift_Reg <= P_Data;
        end else if (Enable) begin
            Shift_Reg <= Shift_Reg >> 1;
        end
    end

endmodule
