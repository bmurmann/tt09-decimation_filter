# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_tt_um_murmann_group(dut):
    dut._log.info("Start test for tt_um_murmann_group")

    # Clock setup (50 MHz)
    clock = Clock(dut.clk, 5, units="ns")  # 50 MHz -> 5 ns period
    cocotb.start_soon(clock.start())

    # Initialize signals
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1
    dut.rst_n.value = 0  # Reset initially low

    # Apply reset and release after 20 clock cycles
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    dut._log.info("Release reset")

    # Type 1 Decimation (incremental DSM mode)
    dut._log.info("Testing Type 1 Decimation")
    dut.ui_in[1].value = 0  # Type 1 mode
    for i in range(32):
        # Toggle ADC input every 10ns
        await ClockCycles(dut.clk, 1)
        dut.ui_in[0].value = not dut.ui_in[0].value
        # Apply reset at specific times (11 and 25 cycles)
        if i == 11 or i == 25:
            dut._log.info(f"Resetting at cycle {i}")
            dut.rst_n.value = 0
            await ClockCycles(dut.clk, 2)  # Hold reset for 2 cycles
            dut.rst_n.value = 1


        if  i == 12:
            expected_output = 30
            output_string = f'{dut.uo_out.value}' + f'{dut.uio_out.value}'
            actual_output = int(output_string,2)
            assert actual_output == expected_output, f"Unexpected output {actual_output} (expected {expected_output})"

        if  i == 26:
            expected_output = 42
            output_string = f'{dut.uo_out.value}' + f'{dut.uio_out.value}'
            actual_output = int(output_string,2)
            assert actual_output == expected_output, f"Unexpected output {actual_output} (expected {expected_output})"

    # Delay for decimation to complete
    await ClockCycles(dut.clk, 10)

    # Type 2 Decimation (regular DSM mode)
    dut._log.info("Testing Type 2 Decimation")
    dut.ui_in[1].value = 1  # Type 2 mode
    for i in range(64):
        await ClockCycles(dut.clk, 1)
        dut.ui_in[0].value = not dut.ui_in[0].value
        if i == 45:
            expected_output = 56
            output_string = bin(dut.uo_out.value)[2:] + bin(dut.uio_out.value)[2:]
            actual_output = int(output_string,2)
            assert actual_output == expected_output, f"Unexpected output {actual_output} (expected {expected_output})"

    # Wait for output to settle
    await ClockCycles(dut.clk, 10)

    dut._log.info("Test completed successfully")
