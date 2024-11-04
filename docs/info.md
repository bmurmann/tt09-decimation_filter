<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

Here’s an improved version for clarity and conciseness:

---
### Overview
The decimation filter reduces the sample frequency of both **Incremental** and **Regular Delta-Sigma Modulators (DSMs)** by a factor of 16. It removes high-frequency noise and downsamples data, enabling efficient and accurate signal processing from oversampled ADC outputs.

### Specifications
- **Input:** 2 bits
  - **Input 1:** 1-bit ADC data input
  - **Input 2:** Decimation mode selection
- **Output:** 16 bits
  - **Most Significant 8 bits:** Dedicated output pins
  - **Least Significant 8 bits:** General-purpose IO pins
- **Clock Frequency:** 50 MHz

### Mode Selection
Set the decimation mode according to the ADC type:
- **Incremental DSM:** Set Input 2 low.
- **Regular DSM:** Set Input 2 high.

### How It Works
1. **Noise Reduction and Downsampling:** The decimation filter removes high-frequency quantization noise introduced by oversampling in Delta-Sigma Modulators, reducing the output data rate while retaining signal quality.
2. **Adaptive Output Rate:**
   - **Incremental DSM (Input 2 Low):** Output updates every 16 input bits from the ADC.
   - **Regular DSM (Input 2 High):** Output updates each time the reset signal is triggered.
3. **Output Simplification:** Converts the ADC’s oversampled high data rate into a manageable, downsampled rate, maintaining signal integrity and reducing processing complexity.

### Operation
1. **Incremental DSM Mode (Input 2 Low):** 
   - Use the ADC’s oversample frequency as the filter input clock.
   - Set the reset input to the desired decimation frequency.
   - For example, with an ADC frequency of 50 MHz and a target decimation frequency of 25 MHz, configure a reset frequency of 25 MHz (decimation factor: 2).

2. **Regular DSM Mode (Input 2 High):**
   - Set the decimation factor to 16 by configuring the reset frequency to change every 16 cycles.
   - For custom decimation factors, follow the configuration steps for Incremental DSM mode.

### Testing Procedure
1. **Hardware Setup:**
   - Connect a 1-bit ADC output to Input 1.
   - Configure Input 2 for Incremental (low) or Regular DSM (high) mode.
2. **Verification:**
   - **Incremental DSM:** Set Input 2 low, connect a clock to the reset pin, and observe the decimated output at the specified frequency.
   - **Regular DSM:** Set Input 2 high and monitor output changes in line with the reset signal to confirm a 16x decimation.

### Output Configuration
The decimation filter provides a 16-bit output:
- **Most Significant 8 Bits:** Routed to dedicated output pins.
- **Least Significant 8 Bits:** Routed to general-purpose IO pins.

### External Requirements
The filter is compatible with:
- **Incremental or Regular Delta-Sigma Modulator ADCs** (1-bit output). 
