module anim_prescaler ( 
	input clkin, 
	output reg clkout
);  

parameter F_OSC = 5000000; 

reg [31:0] counter; 

always@ (posedge clkin) 
	if (counter < (F_OSC-1)) 
		counter <= counter + 1; 
	else 
		counter <= 0;

always@ (posedge clkin) 
	if(counter < (F_OSC/2)) 
		clkout <=0; 
	else  
		clkout <=1;

endmodule