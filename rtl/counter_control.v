module counter_control(
    input wire clk,
    input wire rst_n,
    input wire timer_en,
    input wire div_en,
    input wire [3:0] div_val,
    input wire dbg_mode,
    input wire halt_req,
    output reg halt_ack,
    output wire cnt_en
);

wire [7:0] limit;
reg [7:0] int_cnt;
wire halt_en;

assign halt_en = dbg_mode & halt_req;
assign limit = (1 << div_val) - 1;
assign cnt_en = (timer_en & div_en & (div_val == 0) & !halt_en) | 
                (timer_en & !div_en & !halt_en) | 
                (timer_en & div_en & (int_cnt == limit) & !halt_en);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        halt_ack <= 0;
        int_cnt <= 0;
    end else begin
        halt_ack <= halt_en;
        int_cnt <= (halt_en || !timer_en || !div_en || (int_cnt == limit)) ? int_cnt : int_cnt + 1;
    end
end

endmodule
