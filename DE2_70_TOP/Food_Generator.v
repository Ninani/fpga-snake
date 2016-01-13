module Food_Generator(
	input	clk1,
	input	clk2,
	input	rst1_n,
	input	rst2_n,
	output	reg	[9:0]	xFood,
	output	reg	[9:0]	yFood
);

`include "VGA_Param.h"

wire [9:0] x;
wire [9:0] y;


always@(posedge clk2)
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



LFSR random (	.clk1(clk1),
				.clk2(clk2),
				.rst1_n(rst1_n),
				.rst2_n(rst2_n),
				.XCoord(x),
				.YCoord(y)
);

endmodule