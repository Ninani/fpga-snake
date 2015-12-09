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
						iRightButton,	);

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
reg		[9:0]		ValueChangeX;
reg		[9:0]		ValueChangeY;
/*
reg rst, wr_en, rd_en;
wire buf_empty, buf_full;
reg[13:0] buf_in;
reg[13:0] tempdata;
wire [13:0] buf_out;
wire [13:0] fifo_counter;
*/

reg rst, wr_en, rd_en;
reg buf_empty, buf_full;
reg[13:0] buf_in;
reg [13:0] buf_out;
reg [13:0] fifo_counter;
reg check;

/*
fifo ff( .clk(iCLK), .rst(rst), .buf_in(buf_in), .buf_out(buf_out), 
         .wr_en(wr_en), .rd_en(rd_en), .buf_empty(buf_empty), 
         .buf_full(buf_full), .fifo_counter(fifo_counter));*/


integer i;
assign	oVGA_BLANK	=	oVGA_H_SYNC & oVGA_V_SYNC;
assign	oVGA_SYNC	=	1'b0;
assign	oVGA_CLOCK	=	iCLK;

/*
assign	oVGA_R	=	R_R;

assign	oVGA_G	=	G_G;

assign	oVGA_B	=	B_B;
*/
/*
function containsFunc;
input[13:0] data; 
begin
    for( i = 0; i <= 10; i=i+1) 
	begin
		if( buf_mem[i] == data )
			containsFunc = 1;
	end
	containsFunc = 0;
end
endfunction*/

initial
begin
   rst = 1;
        rd_en = 0;
        wr_en = 0;
        buf_in = 0;


        #15 rst = 0;
  
        push(3231);
        push(3232);
        push(3233);
        push(3234);
        push(3235);
        push(3236);
        push(3237);
        
        buf_mem[0] = 3231;
        buf_mem[1] = 3232;
        buf_mem[2] = 3233;
        buf_mem[3] = 3234;
end




//assign	oVGA_R	=	10'b1111111111;   						// (jd)
//assign	oVGA_G	=	10'b0000000000;   						// (jd)
//assign	oVGA_B	=	10'b0000000000;  					 	// (jd)


always@(posedge iCLK)											// (jd)
begin															// (jd)

oVGA_R	<=	10'b0000000000;										// (jd)
oVGA_G	<=	10'b0000000000;										// (jd)
oVGA_B	<=	10'b0000000000;										// (jd)
		
obraz =   (H_Cont > H_SYNC_CYC + H_SYNC_BACK)                	// (jd)
		& (H_Cont < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT);  	// (jd)
		

obrazDlaProstokata =   (H_Cont > H_SYNC_CYC + H_SYNC_BACK + 100)       
		& (H_Cont < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT - 100)  
		& 			   (V_Cont > V_SYNC_CYC + V_SYNC_BACK + 100)       
		& (V_Cont < V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT - 100);   	

dataToCheck = (H_Cont/10)*80 + V_Cont/10;
containsTask();
obrazDlaPoruszajacegoSiePiksela =  (H_Cont > H_SYNC_CYC + H_SYNC_BACK)       
		& (H_Cont < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT)  
		& 			   (V_Cont > V_SYNC_CYC + V_SYNC_BACK)       
		& (V_Cont < V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT)
		& check;

check = 0;
/*
(H_Cont <= ValueChangeX - 4)
								  & (H_Cont >= ValueChangeX + 5)
								  & (V_Cont <= ValueChangeY + 5)
								  & (V_Cont >= ValueChangeY - 4);*/

if( obrazDlaPoruszajacegoSiePiksela )
begin
	oVGA_R	<=	10'b0000000000;								
	oVGA_G	<=	10'b0000000000;								
	oVGA_B	<=	10'b0000000000;						
end
else
	/*if( obrazDlaPiksela )
	begin
		oVGA_R	<=	10'b0000000000;								
		oVGA_G	<=	10'b0000000000;								
		oVGA_B	<=	10'b1111111111;						
	end
	else*/
		if( obrazDlaProstokata )
		begin
			oVGA_R	<=	10'b1111111111;								
			oVGA_G	<=	10'b0000000000;								
			oVGA_B	<=	10'b0000000000;								
		end
		else		
		if( obraz )// (jd)
		begin
			oVGA_R	<=	10'b0000000000;									// (jd)
			oVGA_G	<=	10'b1111111111;									// (jd)
			oVGA_B	<=	10'b0000000000;									// (jd)
		end
end																	// (jd)
///////////////////////////////////////////////////////////////////////////
///////Drawing flying pixel////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

always@(posedge iPresClk)	
begin
		if (ValueChangeX > H_SYNC_CYC + H_SYNC_BACK + 10
		& ValueChangeY > V_SYNC_CYC + V_SYNC_BACK + 10
		& ValueChangeX < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT -10 
		& ValueChangeY < V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT -10)
		begin
			case(direction)
			2'b11:
				begin
				   ValueChangeX <= ValueChangeX;
				   ValueChangeY <= ValueChangeY - 10;
				end
			2'b00:
				begin
				   ValueChangeX <= ValueChangeX;
				   ValueChangeY <= ValueChangeY + 10;
				end
			2'b10:
				begin
				   ValueChangeX <= ValueChangeX - 10;
				   ValueChangeY <= ValueChangeY;
				end
			2'b01:
				begin
					ValueChangeX <= ValueChangeX + 10;
					ValueChangeY <= ValueChangeY;
				end
			endcase
		end
		else
		begin
			ValueChangeX <= 10'b0100000000;
			ValueChangeY <= 10'b0100000000;
		end
end

always@(posedge iCLK)										
begin			
	
end
//dla ValueChangeX <= ValueChangeX + 1; to pokazuje sie 
//taki szybki naprzemienny piorun z stojacego piksela w prawo i dol albo w lewo i dol
//dla ValueChangeX <= ValueChangeX - 1; to pokazuje sie 
//takie pare kropek latajace w prawo i dol


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
		direction<=2'b11;
	end
	else
	begin
	if(iDownButton)
	begin
		direction<=2'b00;
	end
	else
	begin
	if(iLeftButton)
	begin
		direction<=2'b10;
	end
	else
	begin
		direction<=2'b01;
	end	
	end
	end
end


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


task push;
input[13:0] data;


   if( ! buf_full )
   begin
           buf_in = data;
           wr_en = 1;
                @(posedge iCLK);
                #1 wr_en = 0;
   end
endtask

task pop;
output [13:0] data;

   if( ! buf_empty )
   begin

     rd_en = 1;
          @(posedge iCLK);

          #1 rd_en = 0;
          data = buf_out;

   end
endtask

reg dataToCheck;

task containsTask;
	check = 0;
	#10000 rd_en = 0;
endtask


















reg[`BUF_WIDTH -1:0]  rd_ptr, wr_ptr;           // pointer to read and write addresses  
reg[13:0]              buf_mem[`BUF_SIZE -1 : 0]; //  

always @(fifo_counter)
begin
   buf_empty = (fifo_counter==0);
   buf_full = (fifo_counter== `BUF_SIZE);
end

always @(posedge iCLK or posedge rst)
begin
   if( rst )
       fifo_counter <= 0;

   else if( (!buf_full && wr_en) && ( !buf_empty && rd_en ) )
       fifo_counter <= fifo_counter;

   else if( !buf_full && wr_en )
       fifo_counter <= fifo_counter + 1;

   else if( !buf_empty && rd_en )
       fifo_counter <= fifo_counter - 1;
   else
      fifo_counter <= fifo_counter;
end

always @( posedge iCLK or posedge rst)
begin
   if( rst )
      buf_out <= 0;
   else
   begin
      if( rd_en && !buf_empty )
         buf_out <= buf_mem[rd_ptr];

      else
         buf_out <= buf_out;

   end
end

always @(posedge iCLK)
begin

   if( wr_en && !buf_full )
      buf_mem[ wr_ptr ] <= buf_in;

   else
      buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
end

always@(posedge iCLK or posedge rst)
begin
   if( rst )
   begin
      wr_ptr <= 0;
      rd_ptr <= 0;
   end
   else
   begin
      if( !buf_full && wr_en )    wr_ptr <= wr_ptr + 1;
          else  wr_ptr <= wr_ptr;

      if( !buf_empty && rd_en )   rd_ptr <= rd_ptr + 1;
      else rd_ptr <= rd_ptr;
   end

end
/////////////////////////////////////////////////////////////
always @(posedge iCLK)
begin
	if( i==1000)
		i=0;
		i = i+1;
	   if(buf_mem[i] == dataToCheck)
		  check=1;
end
/*
function containsFunc;
input[13:0] data; 
begin
    for( i = 0; i <= 1<<13; i=i+1) 
	begin
		if( buf_mem[i] == data )
			containsFunc = 1;
	end
	containsFunc = 0;
end
endfunction
*/
endmodule