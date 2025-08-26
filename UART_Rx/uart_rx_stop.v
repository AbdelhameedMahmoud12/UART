module uart_rx_stop (
    input  wire CLK,
    input  wire RSTn,
    input  wire Stop_En,
    input  wire Valid,
    input  wire Stop_Sample,
    output reg  STP_ERR
);
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn) STP_ERR <= 1'b0;
        else if (Stop_En && Valid) STP_ERR <= (Stop_Sample != 1'b1);
        else if (!Stop_En) STP_ERR <= 1'b0;
    end
endmodule
