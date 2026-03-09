module register(
    input wire clk,
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [11:0] tim_paddr,
    input wire [31:0] tim_pwdata,
    input wire [3:0] tim_pstrb,
    input wire halt_ack,
    input wire [63:0] count,
    input wire int_st,
    input wire int_en,
    output wire int_set,
    output reg int_clr,
    output wire error,
    output reg timer_en,
    output reg div_en,
    output reg [3:0] div_val,
    output reg halt_req,
    output wire tdr0_wr_en,
    output wire tdr1_wr_en,
    output wire timer_en_neg,
    output wire [31:0] tdr_reg,
    output wire [31:0] tim_prdata
);

wire [63:0] tcmp;
wire tcr_wr_sel;
reg timer_en_pre;
reg [31:0] tcmp0;
reg [31:0] tcmp1;
wire [31:0] tcr;
wire [31:0] tdr0;
wire [31:0] tdr1;
wire [31:0] tier;
wire [31:0] tisr;
wire [31:0] thcsr;

genvar n;
generate
    for (n = 0; n < 4; n++) begin
        assign tdr_reg[8*n+7:8*n] = (tim_pstrb[n]) ? tim_pwdata[8*n+7:8*n] : 8'b0;
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timer_en <= 0;
        timer_en_pre <= 0;
        div_en <= 0;
        div_val <= 4'b0001;
        tcmp0 <= 32'hffffffff;
        tcmp1 <= 32'hffffffff;
        int_en <= 0;
        int_clr <= 0;
        halt_req <= 0;
    end else begin
        timer_en <= (tcr_wr_sel & tim_pstrb[0]) ? tim_pwdata[0] : timer_en;
        timer_en_pre <= timer_en;
        div_en <= (tcr_wr_sel & tim_pstrb[0] & timer_en) ? tim_pwdata[1] : div_en;
        div_val <= (tcr_wr_sel & tim_pstrb[0]) ? tim_pwdata[11:8] : div_val;
        tcmp0[7:0] <= ((tim_paddr == 12'h0c) & wr_en & tim_pstrb[0]) ? tim_pwdata[7:0] : tcmp0[7:0];
        tcmp0[15:8] <= ((tim_paddr == 12'h0c) & wr_en & tim_pstrb[1]) ? tim_pwdata[15:8] : tcmp0[15:8];
        tcmp0[23:16] <= ((tim_paddr == 12'h0c) & wr_en & tim_pstrb[2]) ? tim_pwdata[23:16] : tcmp0[23:16];
        tcmp0[31:24] <= ((tim_paddr == 12'h0c) & wr_en & tim_pstrb[3]) ? tim_pwdata[31:24] : tcmp0[31:24];
        tcmp1[7:0] <= ((tim_paddr == 12'h10) & wr_en & tim_pstrb[0]) ? tim_pwdata[7:0] : tcmp1[7:0];
        tcmp1[15:8] <= ((tim_paddr == 12'h10) & wr_en & tim_pstrb[1]) ? tim_pwdata[15:8] : tcmp1[15:8];
        tcmp1[23:16] <= ((tim_paddr == 12'h10) & wr_en & tim_pstrb[2]) ? tim_pwdata[23:16] : tcmp1[23:16];
        tcmp1[31:24] <= ((tim_paddr == 12'h10) & wr_en & tim_pstrb[3]) ? tim_pwdata[31:24] : tcmp1[31:24];
        int_en <= ((tim_paddr == 12'h14) & wr_en & tim_pstrb[0]) ? tim_pwdata[0] : int_en;
        int_clr <= ((tim_paddr == 12'h18) & wr_en & tim_pstrb[0]) ? tim_pwdata[0] : int_clr;
        halt_req <= ((tim_paddr == 12'h1c) & wr_en & tim_pstrb[0]) ? tim_pwdata[0] : halt_req;
    end
end

assign timer_en_neg = (timer_en_pre & !timer_en);
assign tcr_wr_sel = (tim_paddr == 12'h00) & wr_en;
assign tdr0_wr_en = (tim_paddr == 12'h04) & wr_en;
assign tdrl_wr_en = (tim_paddr == 12'h08) & wr_en;
assign tcr = {(20'b0 & tim_pwdata[31:12]), div_val, (6'b0 & tim_pwdata[7:2]), div_en, timer_en};
assign tdr0 = count[31:0];
assign tdrl = count[63:32];
assign tier = {(31'b0 & tim_pwdata[31:1]), int_en};
assign tisr = {(31'b0 & tim_pwdata[31:1]), int_st};
assign tcmp = {tcmp1, tcmp0};
assign thcsr = {(30'b0 & tim_pwdata[31:2]), halt_ack, halt_req};
assign int_set = (tcmp == count);
assign error = ((tim_pwdata[11:8] != div_en) & timer_en & tcr_wr_sel & tim_pstrb[0]) 
             | ((tim_pwdata[11:8] != div_val) & timer_en & tcr_wr_sel & tim_pstrb[1]) 
             | ((tim_pwdata[11:8] > 8) & tcr_wr_sel & tim_pstrb[1]);
assign tim_prdata = (!rd_en) ? 0 :
                    (tim_paddr == 12'h00) ? tcr :
                    (tim_paddr == 12'h04) ? tdr0[31:0] :
                    (tim_paddr == 12'h08) ? tdrl[31:0] :
                    (tim_paddr == 12'h0c) ? tcmp0[31:0] :
                    (tim_paddr == 12'h10) ? tcmp1[31:0] :
                    (tim_paddr == 12'h14) ? tier[31:0] :
                    (tim_paddr == 12'h18) ? tisr[31:0] :
                    (tim_paddr == 12'h1c) ? thcsr[31:0] :
                    32'b0;
endmodule
