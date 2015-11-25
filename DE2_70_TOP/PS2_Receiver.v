module PS2_Receiver
(
	input wire clk, reset,
	input wire ps2data, ps2clk, rx_en,
	output reg rx_done_tick,
	output wire [7:0] dout
);

localparam [1:0]
	idle = 2'b00,
	dps = 2'b01,
	load = 2'b10;
	
reg [1:0] state_reg, state_next;
reg [7:0] filter_reg;
wire [7:0] filter_next;
reg f_ps2clk_reg;
wire f_ps2clk_next;
reg [3:0] n_reg, n_next;
reg [10:0] b_reg, b_next;
wire fall_edge;

always @(posedge clk, posedge reset)
if (reset)
	begin
		filter_reg <= 0;
		f_ps2clk_reg <= 0;
	end
else
	begin
		filter_reg <= filter_next;
		f_ps2clk_reg <= f_ps2clk_next;
	end
	
assign filetr_next = {ps2clk, filter_reg[7:1]};
assign f_ps2_next = (filter_reg==8'b11111111) ? 1'b1 :
					(filter_reg==8'b00000000) ? 1'b0 :
					f_ps2clk_reg;
assign fall_edge = f_ps2clk_reg & ~f_ps2clk_next;

//state and data registers
always @(posedge clk, posedge reset)
	if (reset)
		begin
			state_reg <= idle;
			n_reg <= 0;
			b_reg <= 0;
		end
	else 
		begin
			state_reg <= state_next;
			n_reg <= n_next;
			b_reg <= b_next;
		end
//next logic state
always @*
begin
	state_next = state_reg;
	rx_done_tick = 1'b0;
	n_next = n_reg;
	b_next = b_reg;
	case(state_reg)
		idle:
			if(fall_edge & rx_en)
				begin
					b_next = {ps2data, b_reg[10:1]};
					n_next = 4'b1001;
					state_next = dps;
				end
		dps: 
			if (fall_edge)
				begin
					b_next = {ps2data, b_reg[10:1]};
					if (n_reg==0)
						state_next = load;
					else
						n_next = n_reg - 1;
				end
		load:
			begin
				state_next = idle;
				rx_done_tick = 1'b1;
			end
	endcase
end

assign dout = b_reg[8:1];

endmodule
