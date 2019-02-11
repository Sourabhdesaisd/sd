module arithmetic_unit32 (
    input  [31:0] rs1,
    input  [31:0] rs2,
    input  [3:0]  alu_ctrl,
    output reg [31:0] result_alu,
    output       zero_flag,
    output reg   carry_flag,
    output reg   negative_flag,
    output reg   overflow_flag
);
    wire [32:0] add_ext = {1'b0, rs1} + {1'b0, rs2};
    wire [32:0] sub_ext = {1'b0, rs1} - {1'b0, rs2};

    always @(*) begin
        result_alu = 32'b0;
        carry_flag = 1'b0;
        negative_flag = 1'b0;
        overflow_flag = 1'b0;

        case (alu_ctrl)
            4'b0000: begin
                result_alu = add_ext[31:0];
                carry_flag = add_ext[32];
            end
            4'b0001: begin
                result_alu = sub_ext[31:0];
                carry_flag = sub_ext[32]; // borrow indicator style
            end
            4'b1010: begin
                result_alu = rs2; // LUI expects prepared imm
                carry_flag = 1'b0;
            end
            4'b1011: begin
                result_alu = add_ext[31:0]; // AUIPC: PC+imm expected as inputs
                carry_flag = add_ext[32];
            end
            default: begin
                result_alu = 32'b0;
                carry_flag = 1'b0;
            end
        endcase

        negative_flag = result_alu[31];

        case (alu_ctrl)
            4'b0000: begin
                overflow_flag = (~rs1[31] & ~rs2[31] & result_alu[31]) |
                                ( rs1[31] & rs2[31] & ~result_alu[31]);
            end
            4'b0001: begin
                overflow_flag = ( rs1[31] & ~rs2[31] & ~result_alu[31]) |
                                (~rs1[31] &  rs2[31] &  result_alu[31]);
            end
            default: overflow_flag = 1'b0;
        endcase
    end

    assign zero_flag = (result_alu == 32'b0);
endmodule
