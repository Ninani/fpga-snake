module debouncer ( 
	input button, 
	input clk, 
	output reg bt_act
);  

parameter F_CLK  = 25175000; 
parameter D_TIME = F_CLK; 

reg [31:0] counter; 


always@(posedge clk, negedge button) 
	if(button == 0) 
		counter <= 0; 
	else 
		if(counter < D_TIME) 
			counter <= counter + 1; 
			
always@(posedge clk) 
	if(counter < D_TIME) 
		bt_act <= 1; 
	else 
		bt_act <= 0;

endmodule