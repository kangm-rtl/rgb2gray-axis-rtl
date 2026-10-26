\# RGB to Grayscale RTL with AXI4-Stream



\## Overview



This project implements an RGB-to-grayscale pixel conversion module using Verilog RTL and an AXI4-Stream-style ready/valid interface.



The project is intended as an entry-level RTL/FPGA portfolio project.



\## Design



\- Input pixel: 24-bit RGB

\- Output pixel: 8-bit grayscale

\- Red channel: `s\_axis\_tdata\[23:16]`

\- Green channel: `s\_axis\_tdata\[15:8]`

\- Blue channel: `s\_axis\_tdata\[7:0]`

\- Input/output flow control: `TVALID` and `TREADY`

\- End-of-line marker: `TLAST` (project convention)



Grayscale calculation:



`Y = (77\*R + 150\*G + 29\*B) / 256`



The fractional part is discarded.



\## Files



\- `rtl/rgb2gray\_axis.v` — RTL implementation

\- `sim/rgb2gray\_axis\_tb.v` — simulation testbench



\## Simulation Tests



The following test cases have passed in Vivado behavioral simulation:



\- Black pixel: RGB `(0, 0, 0)` → grayscale `0`

\- White pixel: RGB `(255, 255, 255)` → grayscale `255`

\- Red pixel: RGB `(255, 0, 0)` → grayscale `76`

\- Green pixel: RGB `(0, 255, 0)` → grayscale `149`

\- Blue pixel: RGB `(0, 0, 255)` → grayscale `28`

\- Basic output hold test during backpressure

\- `TLAST` propagation test

\- Four consecutive pixel tests



\## Tools



\- Verilog HDL

\- AMD Xilinx Vivado

\- Behavioral simulation



\## Current Limitations and Next Steps



\- Expand AXI4-Stream verification, including more complex backpressure scenarios.

\- Verify reset behavior and additional input cases.

\- Run synthesis and record FPGA resource utilization.

\- Review timing reports after synthesis/implementation.



Synthesis results, timing results, and hardware-board validation have not yet been documented in this repository.

