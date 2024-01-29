// LPM counter

// 2015

module lpm_counter (clock, sclr, q);
   parameter lpm_width = 8; //Default size =8 bits 
   parameter lpm_modulus = 64; // Default
   
   input  clock, sclr;
   output [lpm_width-1:0] q;
   
   reg    [lpm_width-1:0] tmp;

     always @(posedge clock or posedge sclr)
        begin
           if (sclr)
              tmp <= 0;
           else
              tmp <= tmp + 1'b1;
      end
           assign q = tmp;
endmodule
