// ======================================================
// btb_file.v  (BTB Storage Arrays: TAG, VALID, TARGET,
//              2-bit STATE predictor, and LRU bit)
// ======================================================
module btb_file #(
    parameter SETS = 8,
    parameter WAYS = 2,
    parameter TAGW = 27
)(
    input                   clk,
    input                   rst,

    // --- READ PORT --------
    input  [2:0]            rd_set,
    input  [0:0]            rd_way0,   
    output                  rd_valid0,
    output [TAGW-1:0]       rd_tag0,
    output [31:0]           rd_target0,
    output [1:0]            rd_state0,

    input  [0:0]            rd_way1,
    output                  rd_valid1,
    output [TAGW-1:0]       rd_tag1,
    output [31:0]           rd_target1,
    output [1:0]            rd_state1,

    // --- WRITE PORT --------
    input                   wr_en,
    input  [2:0]            wr_set,
    input                   wr_way,     // 0 or 1
    input                   wr_valid,
    input  [TAGW-1:0]       wr_tag,
    input  [31:0]           wr_target,
    input  [1:0]            wr_state,

    // LRU
    output                  rd_lru,
    input                   wr_lru_en,
    input                   wr_lru_val
);

    // ================= Arrays =================
    reg                valid_arr  [0:SETS-1][0:WAYS-1];
    reg [TAGW-1:0]     tag_arr    [0:SETS-1][0:WAYS-1];
    reg [31:0]         target_arr [0:SETS-1][0:WAYS-1];
    reg [1:0]          state_arr  [0:SETS-1][0:WAYS-1];
    reg                lru        [0:SETS-1];

    // ============= READ ACCESS =============
    assign rd_valid0  = valid_arr[rd_set][0];
    assign rd_tag0    = tag_arr[rd_set][0];
    assign rd_target0 = target_arr[rd_set][0];
    assign rd_state0  = state_arr[rd_set][0];

    assign rd_valid1  = valid_arr[rd_set][1];
    assign rd_tag1    = tag_arr[rd_set][1];
    assign rd_target1 = target_arr[rd_set][1];
    assign rd_state1  = state_arr[rd_set][1];

    assign rd_lru     = lru[rd_set];

    // ============= WRITE ACCESS =============
    integer i,j;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0; i<SETS; i=i+1) begin
                lru[i] <= 0;
                for (j=0; j<WAYS; j=j+1) begin
                    valid_arr[i][j]  <= 0;
                    tag_arr[i][j]    <= 0;
                    target_arr[i][j] <= 0;
                    state_arr[i][j]  <= 2'b01;   // weakly not taken
                end
            end
        end
        else begin
            if (wr_en) begin
                valid_arr [wr_set][wr_way] <= wr_valid;
                tag_arr   [wr_set][wr_way] <= wr_tag;
                target_arr[wr_set][wr_way] <= wr_target;
                state_arr [wr_set][wr_way] <= wr_state;
            end

            if (wr_lru_en)
                lru[wr_set] <= wr_lru_val;
        end
    end

endmodule
