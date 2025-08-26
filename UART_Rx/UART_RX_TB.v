`timescale 1us/1ns

module UART_RX_TB;

    //============================================================
    // Testbench Signals
    //============================================================
    reg         CLK;
    reg         RST;
    reg         RX_IN;
    reg         PAR_EN;
    reg         PAR_TYP;
    reg  [5:0]  prescale;
    wire [7:0]  P_DATA;
    wire        DATA_VLD;
	wire        PAR_ERR;
	wire 		STP_ERR;
	wire 		STR_ERR;

    //============================================================
    // Parameters
    //============================================================
    parameter real TX_FREQ = 115.2; // kHz (fixed)
    real RX_FREQ;
    real TX_PERIOD, RX_PERIOD; 
	reg CLK_TX ;

    integer i;
	integer j;
	integer ps;


    //============================================================
    // Instantiate DUT
    //============================================================
    uart_rx_top uut (
        .CLK      (CLK),
        .RSTn     (RST),
        .RX_IN    (RX_IN),
        .PAR_EN   (PAR_EN),
        .PAR_TYP  (PAR_TYP),
        .prescale (prescale),
        .P_DATA   (P_DATA),
        .DATA_VLD (DATA_VLD),
		.STR_ERR  (STR_ERR),
		.STP_ERR  (STP_ERR),
		.PAR_ERR  (PAR_ERR)
    );

    //============================================================
    // Clock Generation
    //============================================================
    always #(RX_PERIOD/2.0) CLK = ~CLK;
	always #(TX_PERIOD/2.0) CLK_TX = ~CLK_TX;

    //============================================================
    // Tasks
    //============================================================
    task set_prescale;
        input integer ps;
        begin
            prescale  = ps;
            RX_FREQ   = TX_FREQ * ps;
            TX_PERIOD = 1000.0 / TX_FREQ; 
            RX_PERIOD = 1000.0 / RX_FREQ;
            $display("=== Setting PRESCALE = %0d (RX_FREQ = %0.3f kHz) ===", ps, RX_FREQ);
        end
    endtask

    task Recive_with_parity;
        input [10:0] data;
        input parity_type;
        begin
            PAR_EN  = 1'b1;
            PAR_TYP = parity_type;
            for (i = 0; i < 11; i = i + 1) begin
				@(negedge CLK_TX);
                RX_IN = data[i];
            end
        end
    endtask

    task Recive_no_parity;
        input [9:0] data;
        begin
            PAR_EN  = 1'b0;
            for (i = 0; i < 10; i = i + 1) begin
				@(negedge CLK_TX);
                RX_IN = data[i];

            end
        end
    endtask

    task initialization;
        begin
            CLK     = 1'b0;
            RX_IN   = 1'b1;
            PAR_EN  = 1'b0;
            PAR_TYP = 1'b0;
			CLK_TX = 1'b0 ; 
            #(TX_PERIOD);
        end
    endtask

    task REST;
        begin
            RST = 1'b1;
            #(TX_PERIOD);
            RST = 1'b0;
            #(TX_PERIOD);
            RST = 1'b1;
        end
    endtask

    task Check_P_Data;
        input [7:0] data;
        begin 
            @(posedge DATA_VLD)
            if (DATA_VLD && (P_DATA == data)) begin
                $display("Status          : PASSED");
            end else begin
                $display("Status          : FAILED");
            end
            $display("Received Data   : %b", P_DATA);
            $display("Expected Data   : %b", data);
            $display("DATA_VALID      : %b", DATA_VLD);
			$display("Parity Enable   : %b", PAR_EN);
			$display("Parity Type     : %b", PAR_TYP);
            $display("***********************************************\n");
        end
    endtask
	
	task glitch_start;
    begin
        RX_IN = 0;
        #(TX_PERIOD/4); // short glitch
        RX_IN = 1;
        #(TX_PERIOD);   // back to idle
		
    end
    endtask

    //============================================================
    // Main Test
    //============================================================
    initial begin
			initialization();
            REST();
   
			//============================================================
			//First, Set the prescale = 8 , Frequency = 921.6 KHz 
			//============================================================
            set_prescale(8);
            $display("************* Test #%0d: Parity Frame *************",1);
            Recive_with_parity(11'b11101011010, 1'b0); 
            Check_P_Data(8'hAD);			
			
            $display("************* Test #%0d: No Parity Frame *************",2); 
            Recive_no_parity(10'b1100110000);
            Check_P_Data(8'h98);
			
			//============================================================
			//Second, Set the prescale = 16 , Frequency = 1.843 MHz
			//============================================================
			set_prescale(16);
            $display("************* Test #%0d:  Parity Frame *************",3);
            Recive_with_parity(11'b10011101010, 1'b1); 
            Check_P_Data(8'h75);			
			
            $display("************* Test #%0d: No Parity Frame *************",4); 
            Recive_no_parity(10'b1110100010);
            Check_P_Data(8'hD1);

			//============================================================
			//Third, Set the prescale = 32 , Frequency = 3.686 MHz
			//============================================================
			set_prescale(32);
            $display("************* Test #%0d:  Parity Frame *************",5);
            Recive_with_parity(11'b10110111100, 1'b0); 
            Check_P_Data(8'hDE);			
			
            $display("************* Test #%0d: No Parity Frame *************",6); 
            Recive_no_parity(10'b1011101010);
            Check_P_Data(8'h75);
			
			
			//============================================================================
			//Forth, Set the prescale = 8 , Frequency = 921.6 KHz , Send with Parity Error
			//============================================================================
			set_prescale(8);
			$display("************* Test #%0d: Parity Error *************",7);
            fork
				Recive_with_parity(11'b10101101100, 1'b0); 
				begin
				@(posedge PAR_ERR);
				$display("Passed, Parity Error      : %b ",PAR_ERR);
				end
			join
			//============================================================================
			//Five, Set the prescale = 32 , Frequency = 3.686 MHz , Send with Parity Error
			//============================================================================
			set_prescale(32);
			$display("************* Test #%0d: Start Error *************",8);
            fork 
				glitch_start(); 
				begin
				@(posedge STR_ERR);
				$display("Passed, Start Error       : %b ",STR_ERR);
				end
				
			join
			//============================================================================
			//Six,  prescale = 32 , Frequency = 3.686 MHz , Send with Stop Error
			//============================================================================

			$display("************* Test #%0d: Stop Error *************",9);
			fork
				Recive_with_parity(11'b01110000110, 1'b1); 
				begin
				@(posedge STP_ERR);
				$display("Passed, Stop Error        : %b ",STP_ERR);
				end			
			
			join
		
        #(TX_PERIOD*2);
        $stop;
    end

endmodule
