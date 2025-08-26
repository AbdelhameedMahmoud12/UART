module uart_rx_parity (
    input  wire       CLK,
    input  wire       RSTn,
    input  wire       Parity_En,
    input  wire       Valid,
    input  wire       PAR_TYP,       // 0: even, 1: odd
    input  wire [7:0] P_DATA,
    input  wire       Parity_Sample,
    output reg        PAR_ERR
);
    wire Parity_check = ^P_DATA;    // 1 if odd number of ones
    wire expected = (PAR_TYP) ? ~Parity_check : Parity_check; // odd: invert
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn) PAR_ERR <= 1'b0;
        else if (Parity_En && Valid) PAR_ERR <= (Parity_Sample != expected);
        else if (!Parity_En) PAR_ERR <= 1'b0;
    end
endmodule