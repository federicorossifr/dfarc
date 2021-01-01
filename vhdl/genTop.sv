`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.12.2020 15:37:44
// Design Name: 
// Module Name: genTop
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


module genTop
#(
    parameter int positSize = 4,
    parameter int maxLx = 'hC,
    parameter mapFile = "p_p4map.mem",
    parameter unmapFile = "p_p4unmap.mem",
    localparam int maxLy = 2*maxLx,
    localparam mapDepth = $pow(2,positSize-1),
    localparam mapWidth = $clog2(maxLx),
    localparam unmapDepth = maxLy,
    localparam unmapWidth = positSize - 1
)
(
     input logic          CLK,
     input logic  [positSize-1:0]   A1,
     input logic  [positSize-1:0]   A2,
     output logic [positSize-1:0]  DATA
   );
   
   logic[mapWidth-1:0] m1,m2;
  
  /*----------------------------------------------------
    Single port ROM: 16 words x 16bit
  ----------------------------------------------------*/

    lut #(mapWidth, mapDepth, mapFile) _pm1 (
    .clock     (CLK       ),
    .address (A1    ),
    .data (m1       )
    );
    
    lut #(mapWidth, mapDepth, mapFile) _pm2 (
    .clock     (CLK       ),
    .address (A2    ),
    .data (m2       )
    );    
    
    lut #(unmapWidth, unmapDepth, unmapFile) _pum (
    .clock     (CLK       ),
    .address (m1+m2    ),
    .data (DATA       )
    );    
     

endmodule
