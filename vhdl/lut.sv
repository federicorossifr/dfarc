module lut 
#(parameter int unsigned width = 8,
   parameter int unsigned depth = 8,
   parameter content = "dummy.mif",
   localparam int unsigned addrBits = $clog2(depth)
)
(
    input logic [addrBits-1:0] address,
    output logic [width-1:0]  data,
    input logic clock
);

   logic [width-1:0] rom [0:depth-1];
   
   
   // initialise ROM contents
   initial begin
     $readmemh(content,rom);
   end
   
    always_ff @ (posedge clock)
    begin
      data <= rom[address];
    end
endmodule
