module Key_To_Led
(
	input wire [7:0] key_code,
	output reg led0,
	output reg led1,
	output reg led2,
	output reg led3
);

always @*

	case(key_code)
		8'h16: led0 <= 1;
		8'h1e: led1 <= 1;
		8'h26: led2 <= 1;
		8'h25: led3 <= 1;
		default:
		begin
			led0 <= 0;
			led1 <= 0;
			led2 <= 0;
			led3 <= 0;
		end
	endcase

endmodule
