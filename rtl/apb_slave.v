module apb_slave(
    input wire clk,
    input wire rst_n,
    input wire tim_pwrite,
    input wire tim_psel,
    input wire tim_penable,
    input wire error,
    output reg wr_en,
    output reg rd_en,
    output wire tim_pready,
    output wire tim_pslverr
);

wire access;

assign access = tim_psel & tim_penable;
assign tim_pslverr = error;
assign tim_pready = wr_en | rd_en;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_en <= 0;
        rd_en <= 0;
    end else begin
        wr_en <= access & tim_pwrite & !wr_en;
        rd_en <= access & !tim_pwrite & !rd_en;
    end
end

endmodule
