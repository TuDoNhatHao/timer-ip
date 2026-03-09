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
        $display("Case: Counter after overflow");
        $display("Case: Default mode");
        default_mode(-16,15,exp_cnt);
        dbg_mode = 0;
        @(posedge clk);
        exp_cnt++;
        dbg_mode = 1;
        rd_en(TDR0,2);
        rd_en(TDR1,2);
        counting_mode_checker;
        
        $display("Case: Control mode");
        for (integer i=0; i<9; i++) begin
            div_val = i;
            control_mode(-6,5,div_val,exp_cnt);
            dbg_mode = 0;
            repeat (1 << div_val) begin
                @(posedge clk);
            end
            exp_cnt++;
            dbg_mode = 1;
            rd_en(TDR0,2);
            rd_en(TDR1,2);
            counting_mode_checker;
        end
        $display("Case: Halt mode");
        $display("Case: Halt mode is acknowledged");
        dbg_mode = 1;
        wr_en(THCSR,32'h00000001);
        rd_en(THCSR,3);
        
        $display("Case: Counter's value when halted");
        $display("Case: Default mode");
        default_mode(500,20,exp_cnt);
        dbg_mode = 1;
        wr_en(THCSR,32'h00000001);
        rd_en(TDRO,2);
        rd_en(TDR1,2);
        counting_mode_checker;
        
        $display("Case: Control mode");
        control_mode(5,5,4'b0010,exp_cnt);
        dbg_mode = 1;
        wr_en(THCSR,32'h00000001);
        rd_en(TDRO,2);
        rd_en(TDR1,2);
        counting_mode_checker;
        
        $display("Case: After halted");
        $display("Case: Halt_ack's value after halted");
        dbg_mode = 1;
        wr_en(THCSR,32'h00000001);
        dbg_mode = 0;
        wr_en(THCSR,32'h00000000);
        if (tim_prdata === 32'h00000000) begin
            $display("------------------------------------------------------------");
            $display("%stime = %t ----------- PASS: Halt_ack signal is same as expected value -----------%s", GREEN, $time, RESET);
            $display("------------------------------------------------------------");
        end else begin
            $display("------------------------------------------------------------");
            $display("%stime = %t ----------- FAIL: Halt_ack signal is not same as expected value -----------%s", RED, $time, RESET);
            $display("Exp:32'h00000003     Actual:%8h", tim_prdata);
        end

        $display("Case: Counter's value after halted");
        $display("Case: Default mode");
        default_mode(0,15,exp_cnt);
        dbg_mode = 0;
        @(posedge clk);
        exp_cnt++;
        dbg_mode = 1;
        rd_en(TDR0,2);
        rd_en(TDR1,2);
        counting_mode_checker;
        
        $display("Case: Control mode");
        for (integer i=0; i<9; i++) begin
            div_val = i;
            control_mode(0,6,div_val,exp_cnt);
            dbg_mode = 0;
            repeat (1 << div_val) begin
                @(posedge clk);
            end
            exp_cnt++;
            dbg_mode = 1;
            rd_en(TDR0,2);
            rd_en(TDR1,2);
            counting_mode_checker;
        end

        $display("Case: Interrupt");
        $display("Case: Interrupt pending bit");
        wr_en(TISR,32'h00000000);
        wr_en(TCR,32'h00000001);
        setting_int_st;
        rd_en(TISR,4);
        
        $display("Case: Timer interrupt");
        wr_en(TISR,32'h00000000);
        wr_en(TIER,32'h00000001);
        setting_int_st;
        if (tim_int == 1) begin
            $display("------------------------------------------------------------");
            $display("%stime = %t----------------PASS: Timer interrupt is asserted----------------%s", GREEN, $time, RESET);
            $display("------------------------------------------------------------");
        end else begin
            $display("------------------------------------------------------------");
            $display("%stime = %t----------------FAIL: Timer interrupt is not asserted----------------%s", RED, $time, RESET);
            $display("Exp:1        Actual:%1b", tim_int);
        end
        
        $display("Case: Reset timer interrupt");
        wr_en(TISR,32'h00000000);
        wr_en(TIER,32'h00000001);
        setting_int_st;
        wr_en(TISR,32'h00000001);
        if (tim_int == 1) begin
            $display("------------------------------------------------------------");
            $display("%stime = %t-----PASS: Timer interrupt is not asserted when interrupt pending bit is cleared-----%s", GREEN, $time, RESET);
            $display("------------------------------------------------------------");
        end else begin
            $display("------------------------------------------------------------");
            $display("%stime = %t-----FAIL: Timer interrupt is asserted when interrupt pending bit is cleared-----%s", RED, $time, RESET);
            $display("Exp:1        Actual:%1b", tim_int);
        end

        $display("Case: APB slave / Register");
        $display("Case: Byte access");
        for (integer i = 0; i<16; i++) begin
            tim_pstrb = i;
            $display("=======================================");
            $display("%s===========Case: pstrb = 4'b%4b===========%s", CYAN, tim_pstrb, RESET);
            $display("=======================================");
            for (integer j = 0; j<=28; j = j+4) begin
                err = 0;
                tim_paddr = j;
                register_name(tim_paddr);
                byte_access_test(tim_pstrb, tim_paddr, 32'h00000000);
                byte_access_test(tim_pstrb, tim_paddr, 32'h55555557);
                byte_access_test(tim_pstrb, tim_paddr, 32'haaaaaaaa);
                byte_access_test(tim_pstrb, tim_paddr, 32'hffffffff);
                if (err === 0) begin
                    $display("------------------------------------------------------------");
                    $display("%stime = %t================PASS: Byte access is successful================%s", GREEN, $time, RESET);
                    $display("------------------------------------------------------------");
                end
            end
        end

        $display("Case: Wait state");
        rd_en(tim_paddr,6);
        
        $display("Case: Error handling");
        $display("Case: Error occurs when select prohibited div_val");
        wr_en(TCR,32'h00000000);
        wr_en_err(TCR,32'h00000f00);
        
        $display("Case: Error occurs when div_en changes while timer_en is HIGH");
        wr_en(TCR,32'h00000001);
        wr_en_err(TCR,32'h00000003);
        
        $display("Case: Error occurs when div_val changes while timer_en is HIGH");
        wr_en(TCR,32'h00000000);
        wr_en(TCR,32'h00000003);
        wr_en_err(TCR,32'h00000503);
        
        //tim_pstrb[0] = 0 coverage error signal
        tim_pstrb = 4'b1111;
        wr_en(TCR,32'h00000001);
        tim_pstrb = 4'b0010;
        wr_en(TCR,32'h00000030);
        tim_pstrb = 4'b1111;

        $display("Case: Internal counter when counting speed is not divided");
        dbg_mode = 0;
        wr_en(TCR,32'h00000000);
        wr_en(TCR,32'h00000000);
        rd_en(TDR0,2);
        rd_en(TDR1,2);
        wr_en(TCR,32'h00000003);
        timer_en = wdata[0];
        div_en = wdata[1];
        speed = 4'b0000;
        internal_counter_exp(speed,exp_int_cnt);
        dbg_mode = 1;
        rd_en(TDR0,2);
        rd_en(TDR1,2);
        internal_counter_checker;
        
        $display("Case: Internal counter when control mode is disabled");
        dbg_mode = 0;
        wr_en(TCR,32'h00000000);
        wr_en(TCR,32'h00000000);
        rd_en(TDR0,2);
        rd_en(TDR1,2);
        wr_en(TCR,32'h00000201);
        timer_en = wdata[0];
        div_en = wdata[1];
        speed = wdata[11:8];
        internal_counter_exp(speed,exp_int_cnt);
        dbg_mode = 1;
        rd_en(TDR0,2);
        rd_en(TDR1,2);
        dbg_mode = 0;
        internal_counter_checker;

        $display("Case: Internal counter when timer is disabled");
        dbg_mode = 0;
        wr_en(TCR,32'h00000000);
        wr_en(TCR,32'h00000000);
        rd_en(TDR0,2);
        rd_en(TDR1,2);
        wr_en(TCR,32'h00000202);
        timer_en = wdata[0];
        div_en = wdata[1];
        speed = wdata[11:8];
        internal_counter_exp(speed,exp_int_cnt);
        dbg_mode = 1;
        rd_en(TDR0,2);
        rd_en(TDR1,2);
        dbg_mode = 0;
        internal_counter_checker;
        #100;
        $finish;
    end

    task register_name;
        input [11:0] addr;
        begin
            case (addr)
                12'h00: $display("%s==================== Register TCR ====================%s", CYAN, RESET);
                12'h04: $display("%s==================== Register TDRO ====================%s", CYAN, RESET);
                12'h08: $display("%s==================== Register TDR1 ====================%s", CYAN, RESET);
                12'h0c: $display("%s==================== Register TCMP0 ====================%s", CYAN, RESET);
                12'h10: $display("%s==================== Register TCMP1 ====================%s", CYAN, RESET);
                12'h14: $display("%s==================== Register TIER ====================%s", CYAN, RESET);
                12'h18: $display("%s==================== Register TISR ====================%s", CYAN, RESET);
                12'h1c: $display("%s==================== Register THCSR ====================%s", CYAN, RESET);
            endcase
        end
    endtask
    
    task test_case;
        input [3:0] testcase;
        begin
            case (testcase)
                0: rw_checker;
                1: rw_checker_continuous(exp_data);
                2: store_count_value(read_cnt);
                3: halt_ack_checker;
                4: int_status_checker;
                5: byte_access_checker;
                6: wait_state;
            endcase
        end
    endtask

    task byte_access;
        input [3:0] tim_pstrb;
        input [31:0] tim_pwdata;
        begin
            case (tim_pstrb)
                4'b0001: wdata = {24'b0, tim_pwdata[7:0]};
                4'b0010: wdata = {16'b0, tim_pwdata[15:8], 8'b0};
                4'b0011: wdata = {16'b0, tim_pwdata[15:0]};
                4'b0100: wdata = {8'b0, tim_pwdata[23:16], 16'b0};
                4'b0101: wdata = {8'b0, tim_pwdata[23:16], 8'b0, tim_pwdata[7:0]};
                4'b0110: wdata = {8'b0, tim_pwdata[23:8]};
                4'b0111: wdata = {8'b0, tim_pwdata[23:0]};
                4'b1000: wdata = {tim_pwdata[31:24], 24'b0};
                4'b1001: wdata = {tim_pwdata[31:24], 16'b0, tim_pwdata[7:0]};
                4'b1010: wdata = {tim_pwdata[31:24], 8'b0, tim_pwdata[15:8], 8'b0};
                4'b1011: wdata = {tim_pwdata[31:24], tim_pwdata[15:0]};
                4'b1100: wdata = {tim_pwdata[31:16], 16'b0};
                4'b1101: wdata = {tim_pwdata[31:16], 8'b0, tim_pwdata[7:0]};
                4'b1110: wdata = {tim_pwdata[31:8], 8'b0};
                4'b1111: wdata = tim_pwdata[31:0];
                default: wdata = 32'b0;
            endcase
        end
    endtask

    task wr_en;
        input [11:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            #1;
            tim_pwrite  = 1;
            tim_psel    = 1;
            tim_penable = 0;
            tim_paddr   = addr;
            tim_pwdata  = data;
            byte_access(tim_pstrb, tim_pwdata);
            @(posedge clk);
            #1 tim_penable = 1;
            @(posedge clk);
            @(posedge clk);
            #1;
            tim_pwrite  = 0;
            tim_psel    = 0;
            tim_penable = 0;
        end
    endtask

    task rd_en;
        input [11:0] addr;
        input [3:0] testcase;
        begin
            @(posedge clk);
            #1;
            tim_pwrite  = 0;
            tim_psel    = 1;
            tim_penable = 0;
            tim_paddr   = addr;
            @(posedge clk);
            #1 tim_penable = 1;
            @(posedge clk);
            #1;
            test_case(testcase);
            @(posedge clk);
            #1;
            tim_psel    = 0;
            tim_penable = 0;
        end
    endtask

    task reset_chk;
      input [11:0] addr;
      begin
        @(posedge clk);
        #1;
        rst_n = 0;
        @(posedge clk);
        #1;
        rst_n = 1;
        tim_pwrite  = 0;
        tim_psel    = 1;
        tim_paddr   = addr;
        @(posedge clk);
        #1 tim_penable = 1;
        @(posedge clk);
        #1;
        if (tim_paddr === TCR)
        begin
            if (tim_prdata === 32'h00000100) begin
                $display("------------------------------------------------------------");
                $display($stime = %t --------PASS: The reset value is correct---------%s", GREEN, $stime);
                $display("------------------------------------------------------------");
            end else begin
                $display("------------------------------------------------------------");
                $display($stime = %t --------FAIL: The reset value is not correct---------%s", RED, $stime);
                $display("Exp:32'h00000100 Act:32'h%8h", tim_prdata);
            end
        end else if (tim_paddr === TCMP0 || tim_paddr === TCMP1)
        begin
            if (tim_prdata === 32'hffffffff) begin
                $display("------------------------------------------------------------");
                $display($stime = %t --------PASS: The reset value is correct---------%s", GREEN, $stime);
                $display("------------------------------------------------------------");
            end else begin
                $display("------------------------------------------------------------");
                $display($stime = %t --------FAIL: The reset value is not correct---------%s", RED, $stime);
                $display("Exp:32'hffffffff Act:32'h%8h", tim_prdata);
            end
        end else
        begin
            if (tim_prdata == 32'h00000000) begin
                $display("------------------------------------------------------------");
                $display("%stime = %t------------------PASS: The reset value is correct------------------%s", GREEN, $time);
            end else begin
                $display("------------------------------------------------------------");
                $display("%stime = %t------------------FAIL: The reset value is not correct------------------%s", RED, $time);
                $display("Exp:32'h00000000    Act:32'h%8h------------------", tim_prdata);
            end
        end
        @(posedge clk);
        #1;
        tim_psel    = 0;
        tim_penable = 0;
      end
    endtask

    task rw_access;
        input [11:0] addr;
        input [31:0] data;
        begin
            case (addr)
                TCR, TCMP0, TCMP1, TIER: begin
                    wr_en(addr, data);
                    rd_en(addr, 0);
                end
                TDR0, TDR1: begin
                    dbg_mode = 1;
                    wr_en(THCSR, 32'h00000001);
                    wr_en(TCR, 32'h00000001);
                    wr_en(addr, data);
                    rd_en(addr, 0);
                end
                TISR: begin
                    wr_en(TCMP0, 32'h11111111);
                    wr_en(TDR0, 32'h22222222);
                    wr_en(TISR, 32'h00000001);
                    wr_en(addr, data);
                    rd_en(addr, 0);
                end
                THCSR: begin
                    dbg_mode = 0;
                    wr_en(addr, data);
                    rd_en(addr, 0);
                end
                default: begin
                    wr_en(addr, data);
                    rd_en(addr, 0);
                end
            endcase
        end
    endtask

    task register_tcr;
        output [31:0] exp_data_tcr;
        begin
            if (timer_en === 0) begin
                if (wdata[11:8] < 9) begin
                    div_val = wdata[11:8];
                end
                div_en = wdata[1];
                exp_data_tcr = {20'b0, div_val, 6'b0, wdata[1:0]};
            end else exp_data_tcr = {20'b0, div_val, 6'b0, div_en, wdata[0]};
            timer_en = wdata[0];
        end
    endtask

    task rw_checker;
        reg [31:0] exp_data_tcr;
        begin
            case (tim_paddr)
                TCR:
                begin
                    register_tcr(exp_data_tcr);
                    if (tim_prdata === exp_data_tcr)
                    begin
                        $display("------------------------------------------------------------");
                        $display("%stime = %t----------------PASS: Read value is same as write value----------------%s", GREEN, $time, RESET);
                    end else begin
                        $display("------------------------------------------------------------");
                        $display("%stime = %t----------------FAIL: Read value is not same as write value----------------%s", RED, $time, RESET);
                        $display("Exp:%8h    Actual:%8h----------------", exp_data_tcr, tim_prdata);
                    end
                end
                TDR0, TDR1, TCMP0, TCMP1:
                begin
                    if (tim_prdata === wdata)
                    begin
                        $display("------------------------------------------------------------");
                        $display("%stime = %t----------------PASS: Read value is same as write value----------------%s", GREEN, $time, RESET);
                        $display("------------------------------------------------------------");
                    end else begin
                        $display("------------------------------------------------------------");
                        $display("%stime = %t----------------FAIL: Read value is not same as write value----------------%s", RED, $time, RESET);
                        $display("Exp:%8h        Actual:%8h----------------------------", wdata, tim_prdata);
                    end
                end
                TIER,THCSR:
                begin
                    if (tim_prdata === {31'b0, wdata[0]})
                    begin
                        $display("@%stime = %t----------------PASS: Read value is same as write value-----------------%s", GREEN, $time, RESET);
                    end else begin
                        $display("@%stime = %t----------------FAIL: Read value is not same as write value-----------------%s", RED, $time, RESET);
                        $display("Exp:00000000%1h Actual:%8h", wdata[0], tim_prdata);
                    end
                end
                TISR:
                begin
                    if (tim_prdata === 32'b0)
                    begin
                        $display("------------------------------------------------------------");
                        $display("%stime = %t----------------PASS: Read value is same as write value-----------------%s", GREEN, $time, RESET);
                        $display("------------------------------------------------------------");
                    end else begin
                        $display("------------------------------------------------------------");
                        $display("%stime = %t----------------FAIL: Read value is not same as write value-----------------%s", RED, $time, RESET);
                        $display("Exp:32'h00000000          Actual:%8h----------------------------", tim_prdata);
                    end
                end
                default:
                begin
                    if (tim_prdata === 32'b0)
                    begin
                        $display("------------------------------------------------------------");
                        $display("%stime = %t----------------PASS: Read value is same as write value----------------%s", GREEN, $time, RESET);
                    end else begin
                        $display("------------------------------------------------------------");
                        $display("%stime = %t----------------FAIL: Read value is not same as write value----------------%s", RED, $time, RESET);
                        $display("Exp:32'h00000000        Actual:%8h----------------", tim_prdata);
                    end
                end
            endcase
        end
    endtask

    task single_rw;
        input [11:0] addr;
        begin
            //write
            @(posedge clk);
            #1;
            tim_psel    = 0;
            tim_penable = 0;
            tim_paddr   = addr;
            tim_pwdata  = 32'h33333333;
            register_name(addr);
            @(posedge clk);
            #1 tim_penable = 1;
            @(posedge clk);
            @(posedge clk);
            #1;
            tim_psel    = 0;
            tim_penable = 0;
            case (addr)
                TCR, TCMP0, TCMP1, TIER: begin
                    wr_en(addr, 32'h77777777);
                end
                TDR0, TDR1: begin
                    dbg_mode = 1;
                    wr_en(THCSR, 32'h00000001);
                    wr_en(TCR, 32'h00000001);
                    wr_en(addr, 32'h77777777);
                end
                TISR: begin
                wr_en(TCMP0, 32'h11111111);
                wr_en(TDR0, 32'h22222222);
                wr_en(TISR, 32'h00000001);
                wr_en(addr, 32'h77777777);
                end
                THCSR: begin
                    dbg_mode = 0;
                    wr_en(addr, 32'h77777777);
                end
            endcase
            @(posedge clk);
            #1;
            tim_psel    = 1;
            tim_penable = 0;
            tim_pwdata  = 32'hdddddddd;
            @(posedge clk);
            #1 tim_penable = 0;
            @(posedge clk);
            @(posedge clk);
            #1;
            tim_psel    = 0;
            tim_penable = 0;
            //read
            @(posedge clk);
            #1;
            tim_psel    = 0;
            tim_penable = 0;
            @(posedge clk);
            #1 tim_penable = 1;
            @(posedge clk);
            @(posedge clk);
            #1;
            tim_psel    = 0;
            tim_penable = 0;
            
            rd_en(addr,0);
            
            @(posedge clk);
            #1;
            tim_psel    = 1;
            tim_penable = 0;
            @(posedge clk);
            #1 tim_penable = 0;
            @(posedge clk);
            @(posedge clk);
            #1;
            tim_psel    = 0;
            tim_penable = 0;
        end
    endtask
