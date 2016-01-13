`define BUF_WIDTH 13    // BUF_SIZE = 16 -> BUF_WIDTH = 4, no. of bits to be used in pointer
`define BUF_SIZE ( 1<<`BUF_WIDTH )

module	VGA_Controller(	//	Host Side
						iRed,
						iGreen,
						iBlue,
						oCoord_X,
						oCoord_Y,
						//	VGA Side
						oVGA_R,
						oVGA_G,
						oVGA_B,
						oVGA_H_SYNC,
						oVGA_V_SYNC,
						oVGA_SYNC,
						oVGA_BLANK,
						oVGA_CLOCK,
						//	Control Signal
						iCLK,
						iRST_N,
						iPresClk,
						iUpButton,
						iDownButton,
						iLeftButton,
						iRightButton,
						startButton,	
						foodX,
						foodY,
						foodClk
						);

`include "VGA_Param.h"

//	Host Side
output	reg	[9:0]	oCoord_X;
output	reg	[9:0]	oCoord_Y;
input		[9:0]	iRed;
input		[9:0]	iGreen;
input		[9:0]	iBlue;
//	VGA Side
output	reg	[9:0]	oVGA_R;  			// (jd)
output	reg	[9:0]	oVGA_G;  			// (jd)
output	reg	[9:0]	oVGA_B;  			// (jd) 
output	reg			oVGA_H_SYNC;
output	reg			oVGA_V_SYNC;
output				oVGA_SYNC;
output				oVGA_BLANK;
output				oVGA_CLOCK;
//	Control Signal
input				iCLK;
input				iRST_N;
input				iPresClk;
input				iUpButton;
input				iDownButton;
input				iLeftButton;
input				iRightButton;
input				startButton;
input		[9:0]	foodX;
input		[9:0]	foodY;
input				foodClk;

//	Internal Registers and Wires
reg		[9:0]		H_Cont;
reg		[9:0]		V_Cont;
reg		[9:0]		Cur_Color_R;
reg		[9:0]		Cur_Color_G;
reg		[9:0]		Cur_Color_B;
reg					obraz;  			// (jd)
reg					obrazDlaPiksela;  	
reg			        obrazDlaProstokata;
reg			        obrazDlaPoruszajacegoSiePiksela;
reg			        obrazGlowy;
reg		[9:0]		ValueChangeX;
reg		[5:0]		counter=0;
reg		[9:0]		ValueChangeY;
reg 	[13:0]		dataToCheck;
reg 	[13:0]		foodScaled;

reg[13:0]              buf_mem[200: 0]; //  

reg rst, wr_en, rd_en;
reg buf_empty, buf_full;
reg[13:0] buf_in;
reg [13:0] buf_out;
reg [13:0] fifo_counter;
reg [2:0] check;
reg [2:0] head;
reg [6:0] snakeLength;
reg [6:0] snakeLengthCopy;

integer i;
integer j;
assign	oVGA_BLANK	=	oVGA_H_SYNC & oVGA_V_SYNC;
assign	oVGA_SYNC	=	1'b0;
assign	oVGA_CLOCK	=	iCLK;

reg					background; 
reg					food;
reg					notended;

reg		[9:0]		foodValueX;
reg		[9:0]		foodValueY;


initial
begin  
    for(i = 0;i<140;i = i+1)
			buf_mem[i] = 0;
        
        buf_mem[0] = 3231;			//head!
        buf_mem[1] = 3232;
        buf_mem[2] = 3233;
        buf_mem[3] = 3234;
        snakeLength = 4;
        check = 0;
        head = 0;
        notended = 1;
end




always@(posedge iCLK)											// (jd)
begin															// (jd)

	oVGA_R	<=	10'b0000000000;										// (jd)
	oVGA_G	<=	10'b0000000000;										// (jd)
	oVGA_B	<=	10'b0000000000;										// (jd)
			
	background =   (H_Cont > H_SYNC_CYC + H_SYNC_BACK)                	// (jd)
			& (H_Cont < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT);  	// (jd)
		

	food = (H_Cont > H_SYNC_CYC + H_SYNC_BACK)       
		& (H_Cont < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT)  
		& 			   (V_Cont > V_SYNC_CYC + V_SYNC_BACK)       
		& (V_Cont < V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT)
		& (H_Cont/10)*80 + V_Cont/10 == (foodValueX/10)*80 + foodValueY/10;;
	
dataToCheck = (H_Cont/10)*80 + V_Cont/10;

check = 0;
head = 0;
for(i = 0;i<50;i = i+1)
begin
	if(buf_mem[i] == dataToCheck)
	begin
		  check=1;
	end
end
			  
obrazDlaPoruszajacegoSiePiksela =  (H_Cont > H_SYNC_CYC + H_SYNC_BACK)       
		& (H_Cont < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT)  
		& 			   (V_Cont > V_SYNC_CYC + V_SYNC_BACK)       
		& (V_Cont < V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT)
		& check == 1;

if(buf_mem[0] == dataToCheck)
	head = 1;
	
obrazGlowy =  (H_Cont > H_SYNC_CYC + H_SYNC_BACK)       
		& (H_Cont < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT)  
		& 			   (V_Cont > V_SYNC_CYC + V_SYNC_BACK)       
		& (V_Cont < V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT)
		& head == 1;

if(notended==1)
begin
if(obrazGlowy)
begin
	oVGA_R	<=	10'b1111111111;								
	oVGA_G	<=	10'b0000000000;								
	oVGA_B	<=	10'b0000000000;	
end
else
if( obrazDlaPoruszajacegoSiePiksela )
begin
	oVGA_R	<=	10'b0000000000;								
	oVGA_G	<=	10'b0000000000;								
	oVGA_B	<=	10'b0000000000;						
end
else		
	if(food)
	begin
		oVGA_R	<=	10'b1111111111;									
		oVGA_G	<=	10'b0000000000;									
		oVGA_B	<=	10'b0000000000;	
	end
	else
		if( background )
		begin
			oVGA_R	<=	10'b0000000000;									
			oVGA_G	<=	10'b1111111111;									
			oVGA_B	<=	10'b0000000000;									
		end
end
else
begin
			oVGA_R	<=	10'b1111111111;									
			oVGA_G	<=	10'b0000000000;									
			oVGA_B	<=	10'b0000000000;	
end
end																	// (jd)
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

always@(posedge iPresClk)	
begin
		///////////////MYCHANGES CONSUMPTION///////////////
		if(notended==0)
		begin
			if(counter<10)
				counter = counter+1;
			else
			begin
				counter = 0;
				for(i = 0;i<140;i = i+1)
					buf_mem[i] = 0;
        
				buf_mem[0] = 3231;			//head!
				buf_mem[1] = 3232;
				buf_mem[2] = 3233;
				buf_mem[3] = 3234;
				snakeLength = 4;
				notended = 1;
			end
		end
			
		foodScaled = (foodValueX/10)*80 + foodValueY/10;
		if(buf_mem[0] == foodScaled)
		begin
			snakeLength = snakeLength+1;
			foodValueX <= foodX;
			foodValueY <= foodY;
		end
		
		///////////////////////////////////////////////////
		snakeLengthCopy = snakeLength;
		if ((buf_mem[0]/80)*10 <= H_SYNC_CYC + H_SYNC_BACK + 10)
			buf_mem[0] = ((H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT -10)/10)*80 + (buf_mem[0]%80);
		else
		if((buf_mem[0]%80)*10 <= V_SYNC_CYC + V_SYNC_BACK + 10)
			buf_mem[0] = (buf_mem[0]/80)*80 + (V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT -10)/10 ;
		else
		if((buf_mem[0]/80)*10 >= H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT -10 )
			buf_mem[0] = ((H_SYNC_CYC + H_SYNC_BACK + 10)/10)*80 + (buf_mem[0]%80);
		else
		if((buf_mem[0]%80)*10 >= V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT -10 )
			buf_mem[0] = (buf_mem[0]/80)*80 + (V_SYNC_CYC + V_SYNC_BACK + 10)/10;		
		
		for(j=150;j>0;j=j-1)
			if(j<snakeLengthCopy)
				if(buf_mem[0] == buf_mem[j])
					notended = 0;
					
		for(j=150;j>0;j=j-1)
			if(j<snakeLengthCopy)
				buf_mem[j] = buf_mem[j-1]; 		
		case(direction)
			2'b11:			
				buf_mem[0] = buf_mem[0]-1; 				
			2'b00:
				buf_mem[0] = buf_mem[0]+1; 
			2'b10:
				buf_mem[0] = buf_mem[0]-80; 
			2'b01:
				buf_mem[0] = buf_mem[0]+80; 
		endcase
end

always@(posedge iCLK)										
begin			
	
end
//	Pixel LUT Address Generator
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		oCoord_X	<=	0;
		oCoord_Y	<=	0;
	end
	else
	begin
		if(	H_Cont>=X_START && H_Cont<X_START+H_SYNC_ACT &&
			V_Cont>=Y_START && V_Cont<Y_START+V_SYNC_ACT )
		begin
			oCoord_X	<=	H_Cont-X_START;
			oCoord_Y	<=	V_Cont-Y_START;
		end
	end
end

//	H_Sync Generator, Ref. 25.175 MHz Clock
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont		<=	0;
		oVGA_H_SYNC	<=	0;
	end
	else
	begin
		//	H_Sync Counter
		if( H_Cont < H_SYNC_TOTAL )
		H_Cont	<=	H_Cont+1;
		else
		H_Cont	<=	0;
		//	H_Sync Generator
		if( H_Cont < H_SYNC_CYC )
		oVGA_H_SYNC	<=	0;
		else
		oVGA_H_SYNC	<=	1;
	end
end

//	V_Sync Generator, Ref. H_Sync
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont		<=	0;
		oVGA_V_SYNC	<=	0;
	end
	else
	begin
		//	When H_Sync Re-start
		if(H_Cont==0)
		begin
			//	V_Sync Counter
			if( V_Cont < V_SYNC_TOTAL )
			V_Cont	<=	V_Cont+1;
			else
			V_Cont	<=	0;
			//	V_Sync Generator
			if(	V_Cont < V_SYNC_CYC )
			oVGA_V_SYNC	<=	0;
			else
			oVGA_V_SYNC	<=	1;
		end
	end
end

reg		[9:0]		R_R;
reg		[9:0]		G_G;
reg		[9:0]		B_B;
reg		[1:0] 		direction;


always@(posedge iUpButton or posedge iLeftButton or posedge iDownButton or posedge iRightButton)
begin
	if(iUpButton)
	begin
		//if(direction!=2'b00)
			direction<=2'b11;
	end
	else
	begin
	if(iDownButton)
	begin
		//if(direction!=2'b11)
			direction<=2'b00;
	end
	else
	begin
	if(iLeftButton)
	begin
		//if(direction!=2'b01)
			direction<=2'b10;
	end
	else
	begin
		//if(direction!=2'b10)
			direction<=2'b01;
	end	
	end
	end
end
/*
always@(posedge iUpButton)
begin
		//if(direction!=2'b00)
		direction<=2'b11;
end
always@(posedge iDownButton)
begin
		//if(direction!=2'b11)
			direction<=2'b00;
end
always@(posedge iLeftButton)
begin
		//if(direction!=2'b01)
			direction<=2'b10;
end
always@(posedge iRightButton)
begin
		//if(direction!=2'b10)
			direction<=2'b01;
end
*/
/*
always@(posedge iCLK)
begin
	R_R	=	(	H_Cont>=X_START+9 	&& H_Cont<X_START+H_SYNC_ACT+9 &&						
				V_Cont>=Y_START 	&& V_Cont<Y_START+V_SYNC_ACT )
				?	Cur_Color_R :	0;
	G_G	=	(	H_Cont>=X_START+9 	&& H_Cont<X_START+H_SYNC_ACT+9 &&						
				V_Cont>=Y_START 	&& V_Cont<Y_START+V_SYNC_ACT )
				?	Cur_Color_G :	0;
	B_B	=	(	H_Cont>=X_START+9 	&& H_Cont<X_START+H_SYNC_ACT+9 &&						
				V_Cont>=Y_START 	&& V_Cont<Y_START+V_SYNC_ACT )
				?	Cur_Color_B	:	0;
end
*/

//food generator
/*
reg [5:0] xFood;
reg [5:0] yFood;
reg foodOnBoard;

wire [9:0] xRand;
wire [9:0] yRand;


LFSR lfsr( 
	.clk1(iCLK),
	.clk2(iPresClk),
	.rst_n(iRST_N),
	.XCoord(xRand),
	.YCoord(yRand)
			
);
*/

/*
always @(posedge iCLK)
begin
	foodOnBoard <= 0;
	if(!foodOnBoard) 
	begin
		xFood <= xRand;
		yFood <= yRand;
		foodOnBoard <= 1;
	end
	if(yFood>47) yFood <= yRand;
end
*/

//display food

//END food generator



endmodule