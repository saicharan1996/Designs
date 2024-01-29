           //                              -*- Mode: Verilog -*-
// Filename        : time_base.v
// Description     : Generates the TIC (tic_enable), preTIC (pre_tic_enable)
//                    ACCUM_INT (accum_enable) and accum_sample_enable.
 
//                  The accumulator sample rate is set at 40/7 MHz in this design.
//                  The accum_sample_enable pulse is derived from the sample clock
//                  driver for the 2015, but is on a different enable phase.
 
// Author          : Peter Mumford  UNSW 2005
/*
    Copyright (C) 2007  Peter Mumford
 
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.
 
    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.
 
    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/
 
module time_base (clk, rstn, tic_divide, accum_divide, sample_clk, pre_tic_enable, tic_enable, accum_enable, accum_sample_enable, tic_count, accum_count);
    
 
   input clk, rstn;
   input [23:0] tic_divide;
   input [23:0] accum_divide;
   output sample_clk; // to RF front end GP2015
   output pre_tic_enable; // to code_nco's
   output tic_enable; // to code_gen's
   output accum_enable; // accumulation interrupt
   output accum_sample_enable; // accumulators sampling enable (40/7MHz)
   output [23:0] tic_count; // the value of the TIC counter
   output [23:0] accum_count; // the value of the accum counter
    
   wire [3:0] sc_q; // ouput of divide by 7 counter
   wire [23:0] tic_q;
   wire [23:0] accum_q;
   reg tic_shift; // used to delay TIC 1 clock cycles
//   reg toggle; // used to create accum_sample_enable
    
   // divide by 7 for RF front end (GP2015) sample clock
   // 4 bit counter
   lpm_counter sc(
        .clock(clk),
        .sclr(!rstn),
        .q(sc_q)
        );
 
   defparam      sc.lpm_width= 4;
   defparam      sc.lpm_modulus= 7;
 
   assign    sample_clk = (sc_q == 0)? 1:0;
   assign    accum_sample_enable = (sc_q == 3)? 1:0; // accumulator sample pulse
    
  //--------------------------------------------------
  // generate the tic_enable
  //
  // tic period = (tic_divide + 1) * Clk period
  // If clocked by GP2015 40HHz:
  // tic period = (tic_divide + 1) / 40MHz
  // For default tic period (0.1s) tic_divide = 0x3D08FF
  //----------------------------------------------------  
   lpm_counter_ud te(
          .clock(clk),
          .sclr(!rstn),
          .sload(pre_tic_enable),
          .data(tic_divide),
          .q(tic_q)
          );
   defparam      te.lpm_direction="DOWN";
   defparam      te.lpm_width=24;
  
  // The preTIC comes first latching the code_nco,
  // followed by the TIC latching everything else.
  // This is due to the delay between the code_nco phase
  // and the prompt code.
   assign    pre_tic_enable = (tic_q == 0)? 1:0;
 
   assign    tic_count = tic_q;
    
   always @ (posedge clk)
   begin
   if (!rstn) // set up shift register
        begin
        tic_shift <= 0;
        end
     else // run
        begin
        tic_shift <= pre_tic_enable;
        end
   end // always @ (posedge clk)
    
   assign tic_enable = tic_shift;
  //---------------------------------------------------------
  // generate the accum_enable
  //
  // The Accumulator interrupt signal and flag needs to have
  // between 0.5 ms and about 1 ms period.
  // This is to ensure that accumulation data can be read
  // before it is written over by new data.
  // The accumulators are asynchronous to each other and have a
  // dump period of nominally 1ms.
  //
  // ACCUM_INT period = (accum_divide + 1) / 40MHz
  // For 0.5 ms accumulator interrupt
  // accum_divide = 40000000 * 0.0005 - 1
  // accum_divide = 0x4E1F      
  //----------------------------------------------------------
   lpm_counter_ud ae(
          .clock(clk),
          .sclr(!rstn),
          .sload(accum_enable),
          .data(accum_divide),
          .q(accum_q)
          );
   defparam      ae.lpm_direction="DOWN";
   defparam      ae.lpm_width=24;
 
   assign    accum_enable = (accum_q == 0)? 1:0;
   
   assign    accum_count = accum_q;
 
endmodule // time_base