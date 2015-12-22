module LFSR 
(
	input clk1,
	input clk2,
	input rst_n,
	

	output reg [9:0] XCoord,
	output reg [9:0] YCoord
);

wire feedbackX;
wire feedbackY;
assign feedbackX = XCoord[0] ^ XCoord[9];
assign feedbackY = YCoord[0] ^ YCoord[9];

always @(posedge clk1 or negedge rst_n)
	if(rst_n==1'b0)
		XCoord <= 9'hF;	//reset condition
	else
	begin 
		//XCoord <= {XCoord[4:0], feedbackX};
		XCoord[0] <= feedbackX; 
		XCoord[1] <= XCoord[0];
		XCoord[2] <= XCoord[1];
		XCoord[3] <= XCoord[2];
		XCoord[4] <= XCoord[3];
		XCoord[5] <= XCoord[4];
		XCoord[6] <= XCoord[5];
		XCoord[7] <= XCoord[6];
		XCoord[8] <= XCoord[7];
		XCoord[9] <= XCoord[8];
	end

always @(posedge clk2 or negedge rst_n)
	if(rst_n==1'b0)
		YCoord <= 9'hF;
	else
	begin
		//YCoord <= {YCoord[4:0], feedbackY};
		YCoord[0] <= feedbackY; 
		YCoord[1] <= YCoord[0];
		YCoord[2] <= YCoord[1];
		YCoord[3] <= YCoord[2];
		YCoord[4] <= YCoord[3];
		YCoord[5] <= YCoord[4];
		YCoord[6] <= YCoord[5];
		YCoord[7] <= YCoord[6];
		YCoord[8] <= YCoord[7];
		YCoord[9] <= YCoord[8];
	end

endmodule
