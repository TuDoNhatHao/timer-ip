Project: Timer IP

Features:
- 64-bit count up
- Register set is configured via APB bus (IP is APB slave)
- Support 32-bit transfer with 1 cycle wait state and error handling
- Timer uses active low asynchronus reset
- Counter can be counted based on system clock or divided up to 256
- Support timer interrupt (can be enabled or disabled)

Files: <br>
rtl/
    apb_slave.v
    register.v
    counter_control.v
    counter.v
    interrupt.v
    timer.v
tb/
    test_bench.v
sim/
    Makefile
    compile.f
    rtl.f
    tb.f
