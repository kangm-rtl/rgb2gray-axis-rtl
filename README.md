# RGB to Grayscale RTL with AXI4-Stream

## Overview

This project implements an RGB-to-grayscale pixel conversion module using Verilog RTL and an AXI4-Stream-style ready/valid interface.

The project is intended as an entry-level RTL/FPGA portfolio project.

## Design

- Input pixel: 24-bit RGB
- Output pixel: 8-bit grayscale
- Red channel: `s_axis_tdata[23:16]`
- Green channel: `s_axis_tdata[15:8]`
- Blue channel: `s_axis_tdata[7:0]`
- Input/output flow control: `TVALID` and `TREADY`
- End-of-line marker: `TLAST` (project convention)
- Reset: Active-low `aresetn`

### Grayscale Calculation

`Y = floor((77*R + 150*G + 29*B) / 256)`

The fractional part is discarded, and the result is represented as an 8-bit unsigned value.

## Files

- `rtl/rgb2gray_axis.v` — RTL implementation
- `sim/rgb2gray_axis_tb.v` — simulation testbench

## Tools

- Verilog HDL
- AMD Xilinx Vivado
- Vivado XSim behavioral simulation

## Verification Results

The following test cases passed in Vivado behavioral simulation.

| Test | Expected result | Status |
|---|---|---|
| Black pixel | 0 | PASS |
| White pixel | 255 | PASS |
| Red pixel | 76 | PASS |
| Green pixel | 149 | PASS |
| Blue pixel | 28 | PASS |
| Output backpressure hold | Output data remains stable while stalled | PASS |
| Input backpressure hold | Input is not accepted while `TREADY` is low | PASS |
| Backpressure recovery | Transfer resumes after the stall | PASS |
| `TLAST` propagation | `TLAST` is propagated to output | PASS |
| Consecutive pixel 1 | Black → 0 | PASS |
| Consecutive pixel 2 | Red → 76 | PASS |
| Consecutive pixel 3 | Green → 149 | PASS |
| Consecutive pixel 4 | Blue → 28 | PASS |

- Simulator: Vivado XSim
- Testbench: `sim/rgb2gray_axis_tb.v`
- RTL: `rtl/rgb2gray_axis.v`
- Simulation completed at 230 ns.

These tests cover the listed cases only; exhaustive input-space verification has not been performed.

## Synthesis Results

- Target device: `xc7z020clg400-1`
- Synthesis status: Completed successfully

### Resource Utilization

| Resource | Used |
|---|---:|
| Slice LUTs | 90 |
| Slice Registers | 10 |

## Timing Summary

- Clock name: `aclk`
- Clock period constraint: 10.000 ns
- Clock frequency constraint: 100 MHz
- Worst Negative Slack (WNS): +7.572 ns
- Total Negative Slack (TNS): 0.000 ns
- Worst Hold Slack (WHS): +0.480 ns
- Total Hold Slack (THS): 0.000 ns
- Setup failing endpoints: 0
- Hold failing endpoints: 0

### Timing Limitations

- These results are from synthesis-stage timing analysis.
- Input and output delay constraints have not yet been fully defined.
- Post-implementation timing analysis has not been completed.
- Hardware-board validation remains future work.

## Current Status and Next Steps

Completed:
- RTL implementation
- Behavioral simulation of the listed test cases
- Synthesis
- Synthesis resource utilization review
- Synthesis-stage timing report review

Next steps:
- Expand AXI4-Stream verification with additional backpressure scenarios.
- Add more reset and input corner-case tests.
- Define appropriate input and output timing constraints.
- Run implementation and review post-implementation timing.
- Validate the design on hardware.
