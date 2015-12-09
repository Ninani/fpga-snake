module LFSR 
(
	input clk1,
	input clk2,
	input rst_n,
	
	output reg [5:0] XCoord,
	output reg [5:0] YCoord
);

wire feedbackX = XCoord[5] ^ XCoord[1];
wire feedbackY = YCoord[5] ^ YCoord[1];

always @(posedge clk1 or negedge rst_n)
	if(~rst_n)
		XCoord <= 5'hf;
	else 
		XCoord <= {XCoord[4:0], feedbackX};

always @(posedge clk2 or negedge rst_n)
	if(~rst_n)
		YCoord <= 5'hf;
	else
		YCoord <= {YCoord[4:0], feedbackY};

endmodule
