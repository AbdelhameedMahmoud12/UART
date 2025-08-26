module uart_rx_counter (
    input  wire       CLK,
    input  wire       RSTn,          // async active-low
    input  wire       Counter_En,
    input  wire       New_Fram,      // restart timing at new start
    input  wire [5:0] PRESCALE,      // 8, 16, or 32
    input  wire       Serial_En,     // used for data_idx increment

    output reg  [2:0] data_idx,      // 0..7
    output reg        Take_Sample,   // registered (for external visibility)
    output reg        Valid,         // registered one-cycle center strobe
    output reg        Out_Valid,     // registered from center until bit end
    output reg  [3:0] Bit_number	// 0=start, 1..8=data bits, 9=parity, 10=stop 
	
);

    reg [5:0] Sampling_Counter; // 1..PRESCALE
  


	wire [5:0] center = PRESCALE>> 1;           // PRESCALE/2
    wire [5:0] s_minus = center - 6'd1;         // center-1
    wire [5:0] s_plus  = center + 6'd1;         // center+1
	
	
	
    wire       at_s_minus = (Sampling_Counter == s_minus);
    wire       at_center  = (Sampling_Counter == center);
    wire       at_s_plus  = (Sampling_Counter == s_plus);
    
	
	
	wire       at_bit_end = (Sampling_Counter == PRESCALE);
    // Registered outputs 
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn) begin
            Sampling_Counter <= 6'd0;
            Bit_number       <= 4'd0;
            Take_Sample      <= 1'b0;
            Valid            <= 1'b0;
            Out_Valid        <= 1'b0;
        end else if (Counter_En) begin
            // advance / restart
            if (New_Fram) begin
                Sampling_Counter <= 6'd1;
                Bit_number       <= 4'd0;
            end else if (at_bit_end) begin
                Sampling_Counter <= 6'd1;
                Bit_number       <= Bit_number + 1'b1;
            end else begin
                Sampling_Counter <= Sampling_Counter + 1'b1;
            end

            // make registered views of the combinational strobes
            Take_Sample <= (at_s_minus | at_center | at_s_plus);
            Valid       <= at_s_plus;                    // 1-cycle pulse
            Out_Valid   <= (Sampling_Counter >= center); // from center to end
        end else begin
            Sampling_Counter <= 6'd0;
            Bit_number       <= 4'd0;
            Take_Sample      <= 1'b0;
            Valid            <= 1'b0;
            Out_Valid        <= 1'b0;
        end
    end

    // data bit index increments exactly at centers while in DATA state
    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn)
            data_idx <= 3'd0;
        else if (New_Fram)
            data_idx <= 3'd0;
        else if (Serial_En && Valid) begin
            if (data_idx != 3'd7)
                data_idx <= data_idx + 3'd1;
        end else if (!Serial_En)
            data_idx <= 3'd0;
    end
endmodule
