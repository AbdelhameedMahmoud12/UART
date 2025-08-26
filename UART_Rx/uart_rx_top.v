

// -----------------------------------------------------------------------------
// uart_rx_top - top-level integration
// -----------------------------------------------------------------------------
module uart_rx_top (
    input  wire       CLK,
    input  wire       RSTn,        // async active-low
    input  wire       RX_IN,       // serial in (idle high)
    input  wire       PAR_EN,      // parity enable
    input  wire       PAR_TYP,     // 0: even, 1: odd
    input  wire [5:0] prescale,      // x8, x16, x32


	//------------------------------//
	output wire       PAR_ERR,		//-
	output wire       STP_ERR,		//---> made Them as output for Test Bench
	output wire 	  STR_ERR,		//-
	//------------------------------//
	
	output wire [7:0] P_DATA,
    output wire       DATA_VLD
);

    // wires
    wire        Take_Sample, Valid, Out_Valid;
    wire [3:0]  Bit_number;
    wire        Counter_En, Serial_En, Start_En, Stop_En, Parity_En, New_Fram;
    wire        OUT_Sample;
    wire [2:0]  data_idx;

    // sampler

uart_rx_sampler u_samp (
    .CLK         (CLK),
    .RSTn        (RSTn),
    .RX_IN       (RX_IN),
    .take_sample_w(Take_Sample), 
    .OUT_Sample  (OUT_Sample)
);
    // counter
    uart_rx_counter u_cnt (
        .CLK         (CLK),
        .RSTn        (RSTn),
        .Counter_En  (Counter_En),
        .New_Fram    (New_Fram),
        .PRESCALE    (prescale),
        .Serial_En   (Serial_En),
        .data_idx    (data_idx),
        .Take_Sample (Take_Sample),
        .Valid       (Valid),
        .Out_Valid   (Out_Valid),
        .Bit_number  (Bit_number)

    );

    // deserializer
    uart_rx_deserializer u_des (
        .CLK         (CLK),
        .RSTn        (RSTn),
        .Valid       (Valid),
        .Serial_En   (Serial_En),
        .Bit_idx     (data_idx),
        .Sample_Data (OUT_Sample),
        .P_DATA      (P_DATA)
    );

    // checkers
  
    uart_rx_start u_start (
        .CLK           (CLK),
        .RSTn          (RSTn),
        .Start_En      (Start_En),
        .Valid         (Valid),
        .Center_Sample (OUT_Sample),
        .Start_error   (STR_ERR)
    );

    uart_rx_parity u_par (
        .CLK           (CLK),
        .RSTn          (RSTn),
        .Parity_En     (Parity_En),
        .Valid         (Valid),
        .PAR_TYP       (PAR_TYP),
        .P_DATA        (P_DATA),
        .Parity_Sample (OUT_Sample),
        .PAR_ERR       (PAR_ERR)
    );

    uart_rx_stop u_stop (
        .CLK         (CLK),
        .RSTn        (RSTn),
        .Stop_En     (Stop_En),
        .Valid       (Valid),
        .Stop_Sample (OUT_Sample),
        .STP_ERR     (STP_ERR)
    );

    // FSM
    uart_rx_fsm u_fsm (
        .CLK          (CLK),
        .RSTn         (RSTn),
        .PAR_EN       (PAR_EN),
        .RX_IN        (RX_IN),
        .Bit_Counter  (Bit_number),
        .Stop_error   (STP_ERR),
        .Start_error  (STR_ERR),
        .Parity_error (PAR_ERR),
        .Out_Valid    (Out_Valid),
        .Counter_En   (Counter_En),
        .Serial_En    (Serial_En),
        .Start_En     (Start_En),
        .Stop_En      (Stop_En),
        .Parity_En    (Parity_En),
        .New_Fram     (New_Fram),
        .DATA_VLD     (DATA_VLD)
    );

endmodule
