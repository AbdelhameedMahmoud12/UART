//-----------------------------------------------------------------------------
// Title       : UART Bit Counter with Enable Pulse Generator
// Project     : UART Communication System
// File        : Counter_Control.v
// Author      : Abdelhameed Mahmoud
// Description : Generates enable pulse per bit for serializer and done flag
//               when all 8 bits have been sent.
//-----------------------------------------------------------------------------


module Counter_Control (
    input  wire       Data_Valid,  // Triggers start of transmission (optional use)
    input  wire       CLK,         // System clock
    input  wire       RST,         // Active-low asynchronous reset
    input  wire       Busy,        // High when FSM is in "data transmit" state
    output reg        Enable,      // 1-cycle pulse per bit for serializer shift
    output reg        Done_Flag    // High when Count == 7 (8th bit sent)
);

    //-------------------------------------------------------------------------
    // Internal Counter
    //-------------------------------------------------------------------------
    reg [2:0] Count;

    //-------------------------------------------------------------------------
    // Sequential Logic
    //-------------------------------------------------------------------------
    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            Count     <= 3'b000;
            Enable    <= 1'b0;
            Done_Flag <= 1'b0;
        end else if (Busy && !Done_Flag) begin
            Count     <= Count + 1'b1;
            Enable    <= 1'b1;  
            Done_Flag <= (Count == 3'b111); 
        end else begin
            Enable    <= 1'b0;  
            if (!Busy) begin
                Count     <= 3'b000;
                Done_Flag <= 1'b0;
            end
        end
    end

endmodule
