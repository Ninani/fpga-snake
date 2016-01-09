module Food_Generator(
	input	clk,
	input	rst_n,
	output	reg	[9:0]	xFood,
	output	reg	[9:0]	yFood
);

`include "VGA_Param.h"

wire [9:0] x;
wire [9:0] y;


always@(posedge clk)
begin
	if(x < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT - 6
	& x > H_SYNC_CYC + H_SYNC_BACK + 6
	& y < V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT - 6
	& y > V_SYNC_CYC + V_SYNC_BACK + 6)
	begin
		xFood <= x;
		yFood <= y;
	end
end



LFSR random (	.clk(clk),
				.rst_n(rst_n),
				.XCoord(x),
				.YCoord(y)
);

endmodule