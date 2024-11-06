# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_tt_um_murmann_group(dut):
    dut._log.info("Starting test for tt_um_murmann_group")

    # Clock setup (50 MHz)
    clock = Clock(dut.clk, 10, units="ns")  # 50 MHz clock -> 10 ns period
    cocotb.start_soon(clock.start())

    # Initialize signals
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1
    dut.rst_n.value = 0  # Initially apply reset

    # Apply reset and release after 2 clock cycles
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    dut._log.info("Released main reset")

    # Apply global reset at t=0 using ui_in[2]
    dut.ui_in[2].value = 1
    await ClockCycles(dut.clk, 1)
    dut.ui_in[2].value = 0  # Release global reset
    dut._log.info("Released global reset")

    # Type 1 Decimation (incremental DSM mode)
    dut._log.info("Testing Type 1 Decimation (Incremental DSM)")
    dut.ui_in[1].value = 0  # Set to Type 1 mode
    for i in range(32):
        await ClockCycles(dut.clk, 1)
        dut.ui_in[0].value = not dut.ui_in[0].value  # Toggle ADC input

        # Apply main reset at specific cycles (simulate reset pulses)
        if i == 11 or i == 25:
            dut._log.info(f"Asserting main reset at cycle {i}")
            dut.rst_n.value = 0
            await ClockCycles(dut.clk, 2)
            dut.rst_n.value = 1

        # Check expected output at specific cycles
        if i == 12:
            expected_output = 30
            output_value = int(dut.uo_out.value) << 8 | int(dut.uio_out.value)
            assert output_value == expected_output, f"Unexpected output {output_value} (expected {expected_output})"
        
        if i == 26:
            expected_output = 42
            output_value = int(dut.uo_out.value) << 8 | int(dut.uio_out.value)
            assert output_value == expected_output, f"Unexpected output {output_value} (expected {expected_output})"

    # Delay to let decimation process complete
    await ClockCycles(dut.clk, 10)

    # Type 2 Decimation (regular DSM mode)
    dut._log.info("Testing Type 2 Decimation (Regular DSM)")
    dut.ui_in[1].value = 1  # Set to Type 2 mode
    for i in range(64):
        await ClockCycles(dut.clk, 1)
        dut.ui_in[0].value = not dut.ui_in[0].value  # Toggle ADC input

        if i == 45:
            expected_output = 56
            output_value = int(dut.uo_out.value) << 8 | int(dut.uio_out.value)
            assert output_value == expected_output, f"Unexpected output {output_value} (expected {expected_output})"

    # Wait for output to settle
    await ClockCycles(dut.clk, 10)

    dut._log.info("Test completed successfully")
