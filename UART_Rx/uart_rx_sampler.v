
module uart_rx_sampler (
    input  wire CLK,
    input  wire RSTn,
    input  wire RX_IN,
    input  wire take_sample_w,   
    output wire OUT_Sample
);
    reg [2:0] Save_Reg;
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn)
            Save_Reg <= 3'b111;                 // idle high
        else if (take_sample_w)
            Save_Reg <= {Save_Reg[1:0], RX_IN};
    end
    // 3-input majority
    assign OUT_Sample = (Save_Reg[2] & Save_Reg[1]) |
                        (Save_Reg[2] & Save_Reg[0]) |
                        (Save_Reg[1] & Save_Reg[0]);
endmodule
