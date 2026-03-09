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
        div_val     = 4'b0001;
        div_en      = 0;
        timer_en    = 0;
        store_tdr0  = 0;
        store_tdr1  = 0;
        #10;
        $display("Case: Register access");
        register_name(TCR);
        reset_chk(TCR);
        rw_access(TCR,32'h00000000);
        rw_access(TCR,32'hffffffff);
        rw_access(TCR,32'h55555555);
        rw_access(TCR,32'haaaaaaaa);
        
        register_name(TDR0);
        reset_chk(TDR0);
        rw_access(TDR0,32'h00000000);
        rw_access(TDR0,32'hffffffff);
        rw_access(TDR0,32'h55555555);
        rw_access(TDR0,32'haaaaaaaa);
        
        register_name(TDR1);
        reset_chk(TDR1);
        rw_access(TDR1,32'h00000000);
        rw_access(TDR1,32'hffffffff);
        rw_access(TDR1,32'h55555555);
        rw_access(TDR1,32'haaaaaaaa);
        
        register_name(TCMP0);
        reset_chk(TCMP0);
        rw_access(TCMP0,32'h00000000);
        rw_access(TCMP0,32'hffffffff);
        rw_access(TCMP0,32'h55555555);
        rw_access(TCMP0,32'haaaaaaaa);
        
        register_name(TCMP1);
        reset_chk(TCMP1);
        rw_access(TCMP1,32'h00000000);
        rw_access(TCMP1,32'hffffffff);
        rw_access(TCMP1,32'h55555555);
        rw_access(TCMP1,32'haaaaaaaa);
        
        register_name(TIER);
        reset_chk(TIER);
        rw_access(TIER,32'h00000000);
        rw_access(TIER,32'hffffffff);
        rw_access(TIER,32'h55555555);
        rw_access(TIER,32'haaaaaaaa);
        
        register_name(TISR);
        reset_chk(TISR);
        rw_access(TISR,32'h00000000);
        rw_access(TISR,32'hffffffff);
        rw_access(TISR,32'h55555555);
        rw_access(TISR,32'haaaaaaaa);
        
        register_name(THCSR);
        reset_chk(THCSR);
        rw_access(THCSR,32'h00000000);
        rw_access(THCSR,32'hffffffff);
        rw_access(THCSR,32'h55555555);
        rw_access(THCSR,32'haaaaaaaa);
        
        $display("Case: Reserved access");
        rw_access(12'h10,32'hffffffff);
        rw_access(12'h50,32'hffffffff);
        rw_access(12'hfff,32'hffffffff);
        
        $display("Case: Timing check");
        $display("Case: Single write and read");
        single_rw(TCR);
        single_rw(TDR0);
        single_rw(TDR1);
        single_rw(TCMP0);
        single_rw(TCMP1);
        single_rw(TIER);
        single_rw(TISR);
        single_rw(THCSR);
        
        $display("Case: Continuous write and read");
        continuous_rw();
        
        $display("Case: Counter");
        
        $display("Case: Default mode");
        default_mode(500,20,exp_cnt);
        rd_en(TDR0,2);
        rd_en(TDR1,2);
        counting_mode_checker;
        
        $display("Case: Control mode");
        for (integer i=0; i<9; i++) begin
            div_val = i;
            control_mode(0,5,div_val,exp_cnt);
            rd_en(TDR0,2);
            rd_en(TDR1,2);
            counting_mode_checker;
        end
        
        $display("Case: Counter reset");
        default_mode(500,20,exp_cnt);
        control_mode(0,5,4'b0010,exp_cnt);
        wr_en(TCR,32'h00000000);
        rd_en(TDR0,2);
        rd_en(TDR1,2);
        if (read_cnt === 0)
        begin
            $display("------------------------------------------------------------");
            $display("%stime = %t----PASS: Counter value is same as expected value------------------%s", GREEN, $time, RESET);
            $display("------------------------------------------------------------");
        end else begin
            $display("------------------------------------------------------------");
            $display("%stime = %t -------- FAIL: Counter value is not same as expected value --------", RED, $time, RESET);
            $display("Exp:0        Actual:%h ----------------", read_cnt);
        end
        
        $display("Case: Counter after reset");
        $display("Case: Default mode");
        default_mode(500,20, exp_cnt);
        wr_en(TCR, 32'h00000000);
        dbg_mode = 0;
        exp_cnt = 0;
        wr_en(TCR, 32'h00000001);
        @(posedge clk);
        exp_cnt++;
        dbg_mode = 1;
        rd_en(TDR0, 2);
        rd_en(TDR1, 2);
        counting_mode_checker;
        
        $display("Case: Control mode");
        for (integer i=0; i<9; i++) begin
            div_val = i;
            control_mode(0.5, div_val, exp_cnt);
            wr_en(TCR, 32'h00000000);
            dbg_mode = 0;
            exp_cnt = 0;
            wr_en(TCR, {20'b0, div_val, 6'b0, 2'b11});
            repeat(1 << div_val) begin
                @(posedge clk);
            end
            exp_cnt++;
            dbg_mode = 1;
            rd_en(TDR0, 2);
            rd_en(TDR1, 2);
            counting_mode_checker;
        end
        
        
