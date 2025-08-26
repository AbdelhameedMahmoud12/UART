module uart_rx_deserializer (
    input  wire       CLK,
    input  wire       RSTn,
    input  wire       Valid,
    input  wire       Serial_En,
    input  wire [2:0] Bit_idx,
    input  wire       Sample_Data,
    output reg  [7:0] P_DATA
);
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn) P_DATA <= 8'd0;
        else if (Valid && Serial_En)
            P_DATA[Bit_idx] <= Sample_Data; // LSB-first
    end
endmodule