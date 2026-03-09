module counter(
    input wire clk,
    input wire rst_n,
    input wire cnt_en,
    input wire tdr0_wr_en,
    input wire tdr1_wr_en,
    input wire [31:0] tdr_reg,
    input wire timer_en_neg,
    output wire [63:0] count
);

reg [31:0] tdr0;
reg [31:0] tdr1;
wire [63:0] next_cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tdr0 <= 0;
        tdr1 <= 0;
    end else begin
        tdr0 <= (tdr0_wr_en) ? tdr_reg :
                (timer_en_neg) ? 0 :
                (cnt_en) ? next_cnt[31:0] : tdr0;
        tdr1 <= (tdrl_wr_en) ? tdr_reg :
                (timer_en_neg) ? 0 :
                (cnt_en) ? next_cnt[63:32] : tdr1;
    end
end

assign next_cnt = count + 1;
assign count = {tdr1, tdr0};

endmodule
