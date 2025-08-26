//-----------------------------------------------------------------------------
// Title       : UART Transmitter Top Module
// Project     : UART Communication System
// File        : UART_Tx_Top.v
// Author      : Abdelhameed Mahmoud
// Description : Integrates FSM, Counter, Serializer, Parity generator, and MUX
//               to transmit serial UART data.
//-----------------------------------------------------------------------------
module UART_Tx_Top (
    input  wire       CLK,           // System clock
    input  wire       RST,           // Active-low reset
    input  wire [7:0] P_Data,        // Parallel input data
    input  wire       Data_Valid,    // High when P_Data is valid
    input  wire       Parity_Enable, // Enable parity generation
    input  wire       Parity_Type,   // 0 = Even, 1 = Odd
    output wire       Tx_OUT,        // Final UART output
    output wire       Busy           // Busy UART output

);

    //=========================================================================
    // Internal Signals
    //=========================================================================
    wire        Enable;
    wire        Done_Flag;
    wire [1:0]  Selector;
    wire        Serial_Data;
    wire        Parity_bit;

    //=========================================================================
    // FSM: Controls states and generates Selector, Busy
    //=========================================================================
    UART_FSM_Tx FSM_TX (
        .CLK          (CLK),
        .RST          (RST),
        .Data_Valid   (Data_Valid),
        .Parity_Enable(Parity_Enable),
        .Done_Flag    (Done_Flag),
        .Selector     (Selector),
        .Busy         (Busy)
    );

    //=========================================================================
    // Counter:
    //=========================================================================
    Counter_Control TX_Counter (
        .Data_Valid (Data_Valid),
        .CLK        (CLK),
        .RST        (RST),
        .Busy       (Busy),
        .Enable     (Enable),
        .Done_Flag  (Done_Flag)
    );

    //=========================================================================
    // Serializer: Converts parallel to serial based on Enable
    //=========================================================================
    Serialzer_Tx TX_Serializer (
        .P_Data     (P_Data),
        .Data_Valid (Data_Valid),
        .Enable     (Enable),
        .CLK        (CLK),
        .RST        (RST),
        .Busy       (Busy),
        .Serial_Data(Serial_Data)
    );

    //=========================================================================
    // Parity Generator: Generates even|odd parity
    //=========================================================================
    Parity_Tx TX_Parity (
        .P_Data     (P_Data),
        .Data_Valid (Data_Valid),
        .Parity_Ty  (Parity_Type),
        .Par_bit    (Parity_bit)
    );

    //=========================================================================
    // MUX: Selects Start, Data, Parity, or Stop bit
    //=========================================================================
    MUX_Tx TX_MUX (
        .Serial_Data(Serial_Data),
        .Parity_bit (Parity_bit),
        .Selector   (Selector),
        .Tx_OUT     (Tx_OUT)
    );

endmodule
