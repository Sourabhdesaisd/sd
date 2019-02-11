module shift_unit32 (
    input  [31:0] rs1,
    input  [31:0] rs2,
    input  [3:0]  alu_ctrl,
    output reg [31:0] result_shift
);
    wire [4:0] shamt = rs2[4:0];
    always @(*) begin
        case (alu_ctrl)
            4'b0101: result_shift = rs1 << shamt;
            4'b0110: result_shift = rs1 >> shamt;
            4'b0111: result_shift = $signed(rs1) >>> shamt;
            default: result_shift = 32'b0;
        endcase
    end
endmodule
