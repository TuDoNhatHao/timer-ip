Project: Timer IP

Features:
- 64-bit count up
- Register set is configured via APB bus (IP is APB slave)
- Support 32-bit transfer with 1 cycle wait state and error handling
- Timer uses active low asynchronus reset
- Counter can be counted based on system clock or divided up to 256
- Support timer interrupt (can be enabled or disabled)
<pre>
Files: <br>
rtl/ <br>
apb_slave.v <br>
    register.v <br>
    counter_control.v <br>
    counter.v <br>
    interrupt.v <br>
    timer.v <br>
tb/ <br>
    test_bench.v <br>
sim/ <br>
    Makefile <br>
    compile.f <br>
    rtl.f <br>
    tb.f <br>
</pre>
