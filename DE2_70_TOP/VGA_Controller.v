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
reg		[3072:0]    coordinates;


assign	oVGA_BLANK	=	oVGA_H_SYNC & oVGA_V_SYNC;
assign	oVGA_SYNC	=	1'b0;
assign	oVGA_CLOCK	=	iCLK;

/*
assign	oVGA_R	=	R_R;

assign	oVGA_G	=	G_G;

assign	oVGA_B	=	B_B;
*/







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

/*		
obrazDlaPiksela = (H_Cont == 300)  	
				  & (V_Cont == 300);

*/
coordinates[2888] <= 1;

obrazDlaPoruszajacegoSiePiksela =   (H_Cont <= ValueChangeX + 2)
								  & (H_Cont >= ValueChangeX - 2)
								  & (V_Cont <= ValueChangeY + 2)
								  & (V_Cont >= ValueChangeY - 2);

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
		if (ValueChangeX > H_SYNC_CYC + H_SYNC_BACK + 5
		& ValueChangeY > V_SYNC_CYC + V_SYNC_BACK + 5
		& ValueChangeX < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT -5 
		& ValueChangeY < V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT -5)
		begin
			ValueChangeX <= ValueChangeX + 5*upDownDirection;
			ValueChangeY <= ValueChangeY + 5*leftRightDirection;
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
reg		upDownDirection;
reg		leftRightDirection;


always@(iUpButton or iLeftButton or iDownButton or iRightButton)
begin
	if(iUpButton)
	begin
		upDownDirection<=1;
		leftRightDirection<=0;
	end
	else
	begin
	if(iDownButton)
	begin
		upDownDirection<=-1;
		leftRightDirection<=0;
	end
	else
	begin
	if(iLeftButton)
	begin
		upDownDirection<=0;
		leftRightDirection<=-1;
	end
	else
	begin
		upDownDirection<=0;
		leftRightDirection<=1;
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




endmodule