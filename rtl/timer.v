module timer(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire tim_psel,
    input wire tim_pwrite,
    input wire tim_penable,
    input wire [11:0] tim_paddr,
    input wire [31:0] tim_pwdata,
    input wire [3:0] tim_pstrb,
    input wire dbg_mode,
    output wire [31:0] tim_prdata,
    output wire tim_pready,
    output wire tim_pslverr,
    output wire tim_int
);

    wire timer_en_neg;
    wire error;
    wire wr_en;
    wire rd_en;
    wire halt_ack;
    wire [63:0] count;
    wire timer_en;
    wire div_en;
    wire [3:0] div_val;
    wire halt_req;
    wire tdr0_wr_en;
    wire tdr1_wr_en;
    wire [31:0] tdr_reg;
    wire cnt_en;
    wire int_st;
    wire int_en;
    wire int_clr;
    wire int_set;

apb_slave u_apb_slave(
    .clk           ( sys_clk        ),
    .rst_n         ( sys_rst_n      ),
    .tim_psel      ( tim_psel       ),
    .tim_pwrite    ( tim_pwrite     ),
    .tim_penable   ( tim_penable    ),
    .error         ( error          ),
    .wr_en         ( wr_en          ),
    .rd_en         ( rd_en          ),
    .tim_pready    ( tim_pready     ),
    .tim_pslverr   ( tim_pslverr    )
);
  
register u_register(
    .clk            ( sys_clk        ),
    .rst_n          ( sys_rst_n      ),
    .wr_en          ( wr_en          ),
    .rd_en          ( rd_en          ),
    .tim_paddr      ( tim_paddr      ),
    .tim_pwdata     ( tim_pwdata     ),
    .tim_pstrb      ( tim_pstrb      ),
    .halt_ack       ( halt_ack       ),
    .count          ( count          ),
    .int_st         ( int_st         ),
    .int_en         ( int_en         ),
    .int_set        ( int_set        ),
    .int_clr        ( int_clr        ),
    .error          ( error          ),
    .timer_en       ( timer_en       ),
    .timer_en_neg   ( timer_en_neg   ),
    .div_en         ( div_en         ),
    .div_val        ( div_val        ),
    .halt_req       ( halt_req       ),
    .tdr0_wr_en     ( tdr0_wr_en     ),
    .tdr1_wr_en     ( tdr1_wr_en     ),
    .tdr_reg        ( tdr_reg        ),
    .tim_prdata     ( tim_prdata     )
);
  
interrupt u_interrupt(
    .clk        ( sys_clk        ),
    .rst_n      ( sys_rst_n      ),
    .int_st     ( int_st         ),
    .int_en     ( int_en         ),
    .int_set    ( int_set        ),
    .int_clr    ( int_clr        ),
    .tim_int    ( tim_int        )
);

counter_control u_counter_control(
    .clk        ( sys_clk        ),
    .rst_n      ( sys_rst_n      ),
    .timer_en   ( timer_en       ),
    .div_en     ( div_en         ),
    .div_val    ( div_val        ),
    .dbg_mode   ( dbg_mode       ),
    .halt_req   ( halt_req       ),
    .halt_ack   ( halt_ack       ),
    .cnt_en     ( cnt_en         )
);

counter u_counter(
    .clk            ( sys_clk        ),
    .rst_n          ( sys_rst_n      ),
    .timer_en_neg   ( timer_en_neg   ),
    .cnt_en         ( cnt_en         ),
    .tdr0_wr_en     ( tdr0_wr_en     ),
    .tdr1_wr_en     ( tdr1_wr_en     ),
    .tdr_reg        ( tdr_reg        ),
    .count          ( count          )
);
endmodule
