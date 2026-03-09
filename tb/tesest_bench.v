`timescale 1ns/1ps
module test_bench;
    reg clk, rst_n, tim_psel, tim_pwrite, tim_penable, dbg_mode;
    reg [11:0] tim_paddr;
    reg [31:0] tim_pwdata;
    reg [3:0] tim_pstrb;
    wire tim_pready, tim_pslverr, tim_int;
    wire [31:0] tim_prdata;

    timer u_dut (
        .sys_clk        ( clk        ),
        .sys_rst_n      ( rst_n      ),
        .tim_psel       ( tim_psel   ),
        .tim_pwrite     ( tim_pwrite ),
        .tim_penable    ( tim_penable),
        .tim_pready     ( tim_pready ),
        .tim_paddr      ( tim_paddr  ),
        .dbg_mode       ( dbg_mode   ),
        .tim_pwdata     ( tim_pwdata ),
        .tim_pstrb      ( tim_pstrb  ),
        .tim_pslverr    ( tim_pslverr),
        .tim_int        ( tim_int    ),
        .tim_prdata     ( tim_prdata )
    );

    parameter TCR    = 12'h00;
    parameter TDR0   = 12'h04;
    parameter TDR1   = 12'h08;
    parameter TCMP0  = 12'h0C;
    parameter TCMP1  = 12'h10;
    parameter TIER   = 12'h14;
    parameter TISR   = 12'h18;
    parameter THCSR  = 12'h1C;

    string RESET;
    string GREEN;
    string RED;
    string CYAN;

    reg [31:0] wdata;
    reg [3:0] div_val;
    reg div_en, timer_en;
    reg [31:0] exp_data_tcr;
    reg [31:0] exp_data [7:0];
    reg [63:0] exp_cnt;
    reg [63:0] read_cnt;
    reg [31:0] store_tdr0;
    reg [31:0] store_tdr1;
    reg [3:0] err;
    reg [8:0] exp_int_cnt;
    reg [3:0] speed;

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #10 rst_n = 1;
    end

    initial begin
        RESET = "\033[0m";
        RED = "\033[31m";
        GREEN = "\033[32m";
        CYAN = "\033[36m";
        tim_psel = 0;
        tim_pwrite = 0;
        tim_penable = 0;
        dbg_mode = 0;
        tim_pstrb = 4'b1111;
