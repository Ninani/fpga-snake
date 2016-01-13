module PS2_Controller(
	input wire  data,			
	input wire clk,				
	output reg up,
	output reg left,
	output reg down,
	output reg right,
	output reg start
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
	up <= 0;
	down <= 0;
	left <= 0;
	right <= 0;
	
end

always @(negedge clk)
begin
	case(b)
	1:;
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
	
	if(b <= 10)
		b <= b+1;
	else if(b == 11)
		b <= 1;
end 

always@(posedge flag)
begin 
	if(current_data==8'hf0)
		begin
			if(previous_data == 8'h1D)//if 'W'
				up <= 1;
			else if(previous_data == 8'h1C)//'A'
				left <= 1;
			else if(previous_data == 8'h1B)//'S'
				down <= 1;
			else if(previous_data == 8'h23)//'D'
				right <= 1;
			else if(previous_data == 8'h4D)//'P'
				start <= 1;
		end	
			
	else
		begin
			up <= 0;
			left <= 0;
			down <= 0;
			right <= 0;
			
			previous_data<=current_data;
		end
		
end

endmodule
