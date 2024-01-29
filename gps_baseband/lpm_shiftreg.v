// parameterized SR


module lpm_shiftreg (clock, sclr,enable,shiftin, q);

   parameter lpm_width = 4; // default to 4 bits

   input  clock, sclr, enable, shiftin;
   output [lpm_width-1:0] q;
   
   reg [lpm_width-1:0]    tmp;
   
   always @(posedge clock or posedge sclr)
     begin
        if (sclr) begin
	   tmp <= 0;
	end else if (enable) begin
	   tmp    <= tmp << 1;
	   tmp[0] <= shiftin;
	end
     end
   assign q = tmp;   
endmodule
