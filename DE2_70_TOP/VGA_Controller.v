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
						iRST_N	);

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

//	Internal Registers and Wires
reg		[9:0]		H_Cont;
reg		[9:0]		V_Cont;
reg		[9:0]		Cur_Color_R;
reg		[9:0]		Cur_Color_G;
reg		[9:0]		Cur_Color_B;
reg					obraz;  			// (jd)
reg					obrazDlaPiksela;  	
reg			        obrazDlaProstokata;


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
		
		
//po dodaniu V_Cont
/*
obraz =   (H_Cont > H_SYNC_CYC + H_SYNC_BACK)               
		& (H_Cont < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT);  	
		& (V_Cont > V_SYNC_CYC + V_SYNC_BACK)       
		& (V_Cont < V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT);   	
*/		

		
obrazDlaProstokata =   (H_Cont > H_SYNC_CYC + H_SYNC_BACK + 100)       
		& (H_Cont < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT - 100); 
		
	
//po dodaniu V_Cont	
/*
obrazDlaProstokata =   (H_Cont > H_SYNC_CYC + H_SYNC_BACK + 100)       
		& (H_Cont < H_SYNC_CYC + H_SYNC_BACK + H_SYNC_ACT - 100);  
		& 			   (V_Cont > V_SYNC_CYC + V_SYNC_BACK + 100)       
		& (V_Cont < V_SYNC_CYC + V_SYNC_BACK + V_SYNC_ACT - 100);   	
*/		


obrazDlaPiksela = (H_Cont == 300);  	


//po dodaniu V_Cont
/*
obrazDlaPiksela = (H_Cont == 300);  	
				  (V_Cont == 300);
*/

if( obrazDlaPiksela )
	begin
	oVGA_R	<=	10'b0000000000;								
	oVGA_G	<=	10'b0000000000;								
	oVGA_B	<=	10'b1111111111;						
end
else
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

/*
Szanowna Pani.

Przygl¹dn¹³em siê Pañstwa projektowi VGA i stwierdzam,
¿e problem wynika z faktu, i¿ podaj¹ Pañstwo sygna³ RGB
w czasie przeznaczonym na sygna³y synchronizuj¹ce.
Uk³ad który znajduje siê w DE2-70 tego nie toleruje
i wy³¹cza wówczas obraz RGB ca³kowicie.

Zmodyfikowa³em Pañstwa kod dodaj¹c sygna³ "obraz",
który przyjmuje wartoœæ '1' gdy w linii sygna³u video
jest czas na sygna³ RGB obrazu. Zatem sygna³y: RED, GREEN i BLUE
mog¹ byæ ró¿ne od zera tylko wtedy gdy zmienna "obraz" jest
równa jeden.

Dodatkowo lepiej aby generowanie obrazu odbywa³o siê w procesie
i by³o zsynchronizowane z procesami generuj¹cymi sygna³y
synchronizacji V i H. Dlatego stworzy³em taki proces.
W zwi¹zku z tym musia³em równie¿ zmieniæ zmienne: oVGA_R, oVGA_G
i oVGA_B na typ register.

Poprawiony plik "VGA_Controller.v" przesy³am w za³¹czniku.
Wszystkie linie kodu zmodyfikowane lub dodane przeze mnie
oznaczy³em na koñcu w komentarzu symbolem: (jd)
Po podmianie tego pliku, projekt powinien generowaæ obraz czerwony.

Proszê o potwierdzenie odebrania tej wiadomoœci.

Pozdrawiam,

(jd)*/








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