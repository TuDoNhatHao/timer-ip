module interrupt(
    input wire clk,
    input wire rst_n,
    input wire int_set,
    input wire int_clr,
    input wire int_en,
    output reg int_st,
    output wire tim_int
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        int_st <= 0;
    end else begin
        int_st <= (int_clr) ? 0 :
                  (int_set) ? 1 : int_st;
    end
end

assign tim_int = int_en & int_st;

endmodule
