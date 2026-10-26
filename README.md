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



Hardware-board validation have not yet been documented in this repository.

## Synthesis and Timing Results

### Clock Constraint
- Clock name: `aclk`
- Clock period: 10.000 ns
- Clock frequency: 100 MHz (constraint setting)

### Synthesis Resource Utilization
- Slice LUTs: 90
- Slice Registers: 10

### Timing Summary
- Worst Negative Slack (WNS): +7.572 ns
- Total Negative Slack (TNS): 0.000 ns
- Worst Hold Slack (WHS): +0.480 ns
- Total Hold Slack (THS): 0.000 ns
- Setup failing endpoints: 0
- Hold failing endpoints: 0

### Limitations
- Timing results are based on the current 100 MHz clock constraint.
- Input and output delay constraints have not yet been fully defined.
- These results are from synthesis-stage timing analysis.
- Post-implementation timing analysis and hardware validation remain future work.
