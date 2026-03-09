Project: Timer IP

Features:
- 64-bit count up
- Register set is configured via APB bus (IP is APB slave)
- Support 32-bit transfer with 1 cycle wait state and error handling
- Timer uses active low asynchronus reset
- Counter can be counted based on system clock or divided up to 256
- Support timer interrupt (can be enabled or disabled)

Files: <br>
<ul style="list-style-type: none; padding-left: 0;">
  <li><a href="./rtl/">rtl/</a></li>
  <ul style="list-style-type: none; padding-left: 20px;">
    <li><a href="./rtl/apb_slave.v">apb_slave.v</a></li>
    <li><a href="./rtl/register.v">register.v</a></li>
    <li><a href="./rtl/counter_control.v">counter_control.v</a></li>
    <li><a href="./rtl/counter.v">counter.v</a></li>
    <li><a href="./rtl/interrupt.v">interrupt.v</a></li>
    <li><a href="./rtl/timer.v">timer.v</a></li>
  </ul>
  <li><a href="./tb/">tb/</a></li>
  <ul style="list-style-type: none; padding-left: 20px;">
    <li><a href="./tb/test_bench.v">test_bench.v</a></li>
  </ul>
</ul>
