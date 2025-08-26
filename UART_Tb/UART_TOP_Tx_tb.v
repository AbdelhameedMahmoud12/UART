`timescale 1ns / 1ps

module UART_TOP_Tx_tb;


	//=========================================================================
    // Parameters
    //=========================================================================
	parameter normal = 10;
	parameter parity = 11;
	parameter Data_length  = 8;
	parameter Clock_Period = 5;
	//==============================divide memory==============================
	parameter All_Test_Cases = 6;
	parameter start_even_Test_Cases = 2;
	parameter start_odd_Test_Cases  = 4;



    //=========================================================================
    // DUT Signals
    //=========================================================================
    reg         CLK;
    reg         RST;
    reg  [Data_length-1:0]  P_Data;
    reg         Data_Valid;
    reg         Parity_Enable ;
    reg         Parity_Type ;  // 0 = Even, 1 = Odd
    wire        Tx_OUT;
	wire		Busy;
    //=========================================================================
    // Clock generation
    //=========================================================================

    always #(Clock_Period/2) CLK = ~CLK;  // 200 MHz clock

    //=========================================================================
    // Instantiate DUT
    //=========================================================================
    UART_Tx_Top DUT (
        .CLK(CLK),
        .RST(RST),
        .P_Data(P_Data),
        .Data_Valid(Data_Valid),
        .Parity_Enable(Parity_Enable),
        .Parity_Type(Parity_Type),
        .Tx_OUT(Tx_OUT),
		.Busy(Busy)
    );

    //=========================================================================
    // Testbench Variables
    //=========================================================================
    integer i, j;
    reg [Data_length-1:0] input_data [All_Test_Cases-1:0];
    reg [parity-1:0] expected_output [All_Test_Cases-1:0];
    integer data_len = 0;
    integer out_index = 0;

    //=========================================================================
    // Load Data Task
    //=========================================================================
    task load_data;
        begin
            $readmemb("input_data.txt", input_data);
            $readmemb("expected_output.txt", expected_output);
        end
    endtask

    //=========================================================================
    // Apply Reset
    //=========================================================================
    task apply_reset;
        begin
		    RST = 1;
			#(2*Clock_Period);
            RST = 0;
			#(2*Clock_Period);
            RST = 1;
			#(2*Clock_Period);
        end
    endtask

    //=========================================================================
    // Send One Byte to DUT
    //=========================================================================
    task send_byte(input [7:0] data);
        begin
            @(posedge CLK);
            P_Data = data;
            Data_Valid = 1;
            @(posedge CLK);
            Data_Valid = 0;
			$display("the data in  : %b ", data);
        end
    endtask
	task initialize;
	begin
	load_data();
	CLK = 1'b0;
    RST= 1'b0;
    P_Data= 8'b0;
    Data_Valid= 1'b0;
    Parity_Enable = 1'b0;
    Parity_Type= 1'b0 ;
	#(Clock_Period);
	end
	endtask

    //=========================================================================
    // Compare Output with Expected
    //=========================================================================
  task compare_output(
    input integer num_bits,    // Number of bits to capture
    input integer test_idx,    // Test case index
    input [7:0]   ser_data     // Original parallel data
	);
		reg [0:normal-1] normal_frame;
		reg [0:parity-1] parity_frame;
	begin
		// ----------- Normal Operation -----------
		if (!Parity_Enable) begin
			for (j = 0; j < num_bits; j = j + 1) begin
				@(posedge CLK);
				// Force Data_Valid at bit 5 for disturbance test
				Data_Valid = (j == 5) ? 1'b1 : 1'b0;
				normal_frame[j] = Tx_OUT;
			end

			// Compare The result
			if (normal_frame == expected_output[test_idx][normal-1:0])
				$display("Status          : PASSED");
			else
				$display("Status          : FAILED");

			$display("Serial Data     : %b", ser_data);
			$display("Expected Tx     : %b", expected_output[test_idx][normal-1:0]);
			$display("Observed Tx     : %b", normal_frame);
			$display("***********************************************\n");
		end

		// ----------- Parity Operation -----------
		else begin
			for (j = 0; j < num_bits; j = j + 1) begin
				@(posedge CLK);
				parity_frame[j] = Tx_OUT;
			end

			// Compare The result
			if (parity_frame == expected_output[test_idx][parity-1:0])
				$display("Status          : PASSED");
			else
				$display("Status          : FAILED");

			$display("Serial Data     : %b", ser_data);
			$display("Expected Tx     : %b", expected_output[test_idx][parity-1:0]);
			$display("Observed Tx     : %b", parity_frame);
			$display("***********************************************\n");
		end
	end
	endtask
  //=========================================================================
// Main Test Sequence
//=========================================================================
initial begin
    // Initialization and Reset
    initialize();
    apply_reset();

    // ---------------- Normal Operation ----------------
    $display("\n=========================================================");
    $display("############### NORMAL OPERATION TEST CASES #############");
    $display("=========================================================\n");
    Parity_Enable = 1'b0;  // Disable parity


    for (i = 0; i < start_even_Test_Cases; i = i + 1) begin
        $display("----- Test Case #%0d -----", i + 1);
        send_byte(input_data[i]);
        compare_output(normal, i, input_data[i]);
        #(Clock_Period);
    end

    // ---------------- Even Parity Operation ----------------
    $display("\n=========================================================");
    $display("############### EVEN PARITY TEST CASES ##################");
    $display("=========================================================\n");
    Parity_Enable = 1'b1;
    Parity_Type   = 1'b0;  // Even parity

    for (i = start_even_Test_Cases; i < start_odd_Test_Cases; i = i + 1) begin
        $display("----- Test Case #%0d -----", i + 1);
        send_byte(input_data[i]);
        compare_output(parity, i, input_data[i]);
        #(Clock_Period);
    end

    // ---------------- Odd Parity Operation ----------------
    $display("\n=========================================================");
    $display("################ ODD PARITY TEST CASES ##################");
    $display("=========================================================\n");
    Parity_Type = 1'b1;  // Odd parity

    for (i = start_odd_Test_Cases; i < All_Test_Cases; i = i + 1) begin
        $display("----- Test Case #%0d -----", i + 1);
        send_byte(input_data[i]);
        compare_output(parity, i, input_data[i]);
        #(Clock_Period);
    end

    // ---------------- Test Complete ----------------
    $display("\n=========================================================");
    $display("==================== TESTBENCH DONE =====================");
    $display("=========================================================\n");

    $stop;
end


endmodule
