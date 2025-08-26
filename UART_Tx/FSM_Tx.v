//-----------------------------------------------------------------------------
// Title       : UART Transmit FSM Controller
// Project     : UART Communication System
// File        : UART_FSM_Tx.v
// Author      : Abdelhameed Mahmoud
// Description : FSM for controlling UART transmission flow:
//               start -> data -> parity (optional) -> stop -> idle
//-----------------------------------------------------------------------------

module UART_FSM_Tx (
    input  wire       CLK,           // System clock
    input  wire       RST,           // Asynchronous active-low reset
    input  wire       Data_Valid,    // Input data ready
    input  wire       Parity_Enable, // Enable parity mode
    input  wire       Done_Flag,     // From counter after 8 data bits
    output reg  [1:0] Selector,      // To MUX_Tx
    output reg        Busy           // Activates counter and serializer
);

    //-------------------------------------------------------------------------
    // State Encoding
    //-------------------------------------------------------------------------
localparam [4:0] IDLE   = 5'b00001,
        START  = 5'b00010,
        DATA   = 5'b00100,
        PARITY = 5'b01000,
        STOP   = 5'b10000;

    reg [4:0] current_state, next_state;

    //-------------------------------------------------------------------------
    // State Transition
    //-------------------------------------------------------------------------
    always @(posedge CLK or negedge RST) begin
        if (!RST)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    //-------------------------------------------------------------------------
    // Next State Logic
    //-------------------------------------------------------------------------
    always @(*) begin
        case (current_state)
            IDLE:    next_state = (Data_Valid) ? START : IDLE;
            START:   next_state = DATA;
            DATA:    next_state = (Done_Flag) ? (Parity_Enable ? PARITY : STOP) : DATA;
            PARITY:  next_state = STOP;
            STOP:    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    //-------------------------------------------------------------------------
    // Output Logic
    //-------------------------------------------------------------------------
    always @(*) begin
        // Default values
        Busy     = 1'b0;
        Selector = 2'b00; 

        case (current_state)
            IDLE: begin
                Busy     = 1'b0;
                Selector = 2'b00; // high --> Stop bit 
            end
            START: begin
                Busy     = 1'b1;
                Selector = 2'b01; // Start bit (low)
            end
            DATA: begin
                Busy     = 1'b1;
                Selector = 2'b10; // Data bits
            end
            PARITY: begin
                Busy     = 1'b1;
                Selector = 2'b11; // Parity bit
            end
            STOP: begin
                Busy     = 1'b1;
                Selector = 2'b00; // Stop bit (high)
            end
        endcase
    end

endmodule
