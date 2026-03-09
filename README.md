Project: Timer IP

Features:
- 64-bit count up
- Register set is configured via APB bus (IP is APB slave)
- Support 32-bit transfer with 1 cycle wait state and error handling
- Timer uses active low asynchronus reset
- Counter can be counted based on system clock or divided up to 256
- Support timer interrupt (can be enabled or disabled)

Files: <br>
```rtl/``` <br>
&nbsp;&nbsp;&nbsp;&nbsp;```apb_slave.v``` <br>
&nbsp;&nbsp;&nbsp;&nbsp;```register.v``` <br>
&nbsp;&nbsp;&nbsp;&nbsp;```counter_control.v ```<br>
&nbsp;&nbsp;&nbsp;&nbsp;```counter.v``` <br>
&nbsp;&nbsp;&nbsp;&nbsp;```interrupt.v``` <br>
&nbsp;&nbsp;&nbsp;&nbsp;```timer.v``` <br>
```tb/``` <br>
&nbsp;&nbsp;&nbsp;&nbsp;```test_bench.v``` <br>
```sim/``` <br>
&nbsp;&nbsp;&nbsp;&nbsp;```Makefile``` <br>
&nbsp;&nbsp;&nbsp;&nbsp;```compile.f``` <br>
&nbsp;&nbsp;&nbsp;&nbsp;```rtl.f``` <br>
&nbsp;&nbsp;&nbsp;&nbsp;```tb.f``` <br>
