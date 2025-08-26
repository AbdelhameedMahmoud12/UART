module uart_rx_fsm (
    input  wire       CLK,
    input  wire       RSTn,
    input  wire       PAR_EN,
    input  wire       RX_IN,
    input  wire [3:0] Bit_Counter,   
    input  wire       Stop_error,
    input  wire       Start_error,
    input  wire       Parity_error,
    input  wire       Out_Valid,     

	
    output reg        Counter_En,
    output reg        Serial_En,
    output reg        Start_En,
    output reg        Stop_En,
    output reg        Parity_En,
    output reg        New_Fram,
    output reg        DATA_VLD
);
    localparam IDEL   = 5'b00001;
    localparam START  = 5'b00010;
    localparam DATA   = 5'b00100;
    localparam PARITY = 5'b01000;
    localparam STOP   = 5'b10000;

    reg [4:0] Current_State, Next_State;


    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn) begin
		Current_State <= IDEL; 
		end
		else begin
		Current_State <= Next_State;
		end
	end

    always @(*) begin
        // default Values
        Counter_En = 1'b0;
        Serial_En  = 1'b0;
        Start_En   = 1'b0;
        Stop_En    = 1'b0;
        Parity_En  = 1'b0;
        New_Fram   = 1'b0;
        Next_State = Current_State;
		DATA_VLD   =1'b0;

        case (Current_State)
            IDEL: begin
                if (~RX_IN) begin
                    Next_State         = START;
                    Counter_En = 1'b1;
                    Start_En   = 1'b1;
                    New_Fram   = 1'b1;
                end
				else Next_State = IDEL;
				
            end

            START: begin
                Counter_En = 1'b1;
                Start_En   = 1'b1;
                if (Out_Valid && Bit_Counter == 4'd1) begin
                    if (Start_error) Next_State = IDEL; else Next_State = DATA;
                end
				else Next_State = START;
            end

            DATA: begin
                Counter_En = 1'b1;
                Serial_En  = 1'b1;
                if (Out_Valid && Bit_Counter == 4'd9) begin
                    Next_State = (PAR_EN) ? PARITY : STOP;
                end
				else Next_State = DATA;
            end

            PARITY: begin
                Counter_En = 1'b1;
                Parity_En  = 1'b1;
				if(Parity_error) Next_State = IDEL;
                else if (Out_Valid && Bit_Counter == 4'd10) Next_State = STOP;
				else Next_State = PARITY;
				
            end

            STOP: begin
                Counter_En = 1'b1;
                Stop_En    = 1'b1;
				DATA_VLD   =1'b0;
                if (Out_Valid && Bit_Counter == 4'd11) begin
                    if (Stop_error) begin
                        Next_State = IDEL;
                    end else begin
                        // good frame
						DATA_VLD =1'b1;

                        if (~RX_IN) begin
                            Next_State       = START;
                            Start_En = 1'b1;
                            New_Fram = 1'b1;
                        end else begin
                            Next_State = IDEL;
                        end
                    end
                end else if (Out_Valid && Bit_Counter == 4'd10 && ~PAR_EN) begin
				if(Stop_error) Next_State = IDEL;
				else begin
				DATA_VLD =1'b1;

					if (~RX_IN) begin
					Next_State = START;
					Start_En = 1'b1;
					New_Fram = 1'b1;
					end
					else Next_State = IDEL;
				end
				end else Next_State = STOP;
            end
            default: Next_State = IDEL;
        endcase
    end


endmodule
