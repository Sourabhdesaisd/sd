// inst_mem.v
// Simple 32-bit word-addressed instruction memory

module inst_mem (
    input  wire [31:0] pc, 
    output  [31:0] instruction
);
    reg [31:0] mem [0:255];

    initial begin
        $readmemh("instructions.hex", mem);  // optional
    end




assign instruction = mem[pc[11:2]];

endmodule












