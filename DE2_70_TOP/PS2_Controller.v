module PS2_Controller(
	inout		 	data,				//	PS2 Keyboard Data
	inout			clk,				//	PS2 Keyboard Clock
	output reg [8:0] led
);

reg [7:0] current_data;
reg [7:0] previous_data;
reg [3:0] b;
reg flag;

initial 
begin
	b<=4'h1;
	flag<=1'b0;
	current_data<=8'hf0;
	previous_data<=8'hf0;
	led<=8'hf0;	
end

always @(negedge clk)
begin
	case(b)
	1:;
	//first bit
	2:current_data[0]<=data;
	3:current_data[1]<=data;
	4:current_data[2]<=data;
	5:current_data[3]<=data;
	6:current_data[4]<=data;
	7:current_data[5]<=data;
	8:current_data[6]<=data;
	9:current_data[7]<=data;
	10:flag<=1'b1;
	11:flag<=1'b0;
	endcase
	
	if(b<=10)
		b<=b+1;
	else if(b==11)
		b<=1;
end 

always@(posedge flag)
// Printing data obtained to led
begin 
	if(current_data==8'hf0)
		led<=previous_data;
	else
		previous_data<=current_data;
end

endmodule
