`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.12.2020 15:06:51
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top
(input logic CLK, input logic [3:0] inp,output logic [3:0] wire8o);
  
     
    genTop
#(
    4,
   'hC,
   "p_p4map.mem",
    "p_p4unmap.mem"
) top4
(
    CLK,
     inp,
     inp,
    wire8o
   );
 

endmodule
