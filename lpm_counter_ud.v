// lpm_counter_ud.v
   
   module lpm_counter_ud (clock, sclr, sload, data, q); 
   
   parameter lpm_width = 8; //default width = 8
   parameter lpm_direction = "UP"; // up count by default
   
   input clock, sclr, sload; 
   input [lpm_width-1:0] data;
   output [lpm_width-1:0] q; 
   reg [lpm_width-1:0] tmp; 
     always @(posedge clock or posedge sclr) 
       begin 
         if (sclr) tmp <= 0;
       else if (sload)
         tmp <= data; 
       else if (lpm_direction == "UP") 
         tmp <= tmp + 1'b1; 
       else tmp <= tmp - 1'b1; 
       end 
   assign q = tmp; 
   endmodule
