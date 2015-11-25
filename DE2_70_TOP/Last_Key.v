module Last_Key
	#(parameter W_SIZE = 2)
(
	input wire clk, reset,
	input wire ps2data, ps2clk, rd_key_kode,
	output wire [7:0] key_kode,
	output wire kb_buf_empty
);

localparam BRK = 8'hf0;

localparam
	wait_brk = 1'b0,
	get_code = 1'b1;
	
reg state_reg, state_next;
wire [7:0] scan_out;
reg got_code_tick;
wire scan_done_tick;

PS2_Receiver receiver_unit(
	.clk(clk),
	.reset(reset),
	.rx_en(1'b1),
	.ps2data(ps2data),
	.ps2clk(ps2clk),
	.rx_done_tick(scan_done_tick),
	.dout(scan_out)
);

fifo #(.B(8), .W(W_SIZE)) fifo_key_unit
(
	.clk(clk), 
	.reset(reset), 
	.rd(rd_key_code),
	.wr (got_code_tick), 
	.w_data(scan_out),
	.empty (kb_buf_empty), 
	.full(),
	.r_data(key_code)
);

//state registers	
always @(posedge clk, posedge reset)
		if (reset)
			state_reg <= wait_brk;
		else 
			state_reg <= state_next;


//state logic
always @* 
begin 
	got_code_tick = 1'b0;
	state_next = state_reg;
	case (state_reg)
		wait_brk:
			if(scan_done_tick == 1'b1 && scan_out==BRK)
				state_next = get_code;
		get_code:
			if(scan_done_tick)
			begin
				got_code_tick = 1'b1;
				state_next = wait_brk;
			end
	endcase		
end


endmodule
