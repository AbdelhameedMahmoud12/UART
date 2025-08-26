module uart_rx_start (
    input  wire CLK,
    input  wire RSTn,
    input  wire Start_En,
    input  wire Valid,
    input  wire Center_Sample,
    output reg  Start_error
);
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn) Start_error <= 1'b0;
        else if (Start_En && Valid) Start_error <= (Center_Sample != 1'b0);
        else if (!Start_En) Start_error <= 1'b0;
    end
endmodule
