<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Decimation filter used to reduce the sample frequency of an incremental and a regular Delta-Sigma Modulator by a factor of 16.

Input: 2 bit
  * Input 1: ADC input bit
  * Input 2: Decimation mode
Output: 16 bits
  * Dedicated output pins: Most significant 8 bits
  * General-purpose IO pins: Less significant 8 bits

Put mode for decimation according
  * Incremental DSM (type 1): Input 2 low
  * Regulat DSM (type 2) Input 2 high
  * 

Clock is set to 50MHz

Connect an ADC with a 1 bit output 
After oversampling, the output of a Delta-Sigma modulator is at a much higher data rate than necessary. The decimation filter not only removes unwanted high-frequency noise but also reduces the data rate, making the ADC’s output usable for further processing.

Decimaiton filter removes high-frequency quantization noise introduced during oversampling. As well as reduces the sampling rate by downsampling the data, making it easier to handle and process while maintaining signal integrity.

Without the decimation filter, the oversampled output of the Delta-Sigma ADC would have too much noise and an unnecessarily high data rate, making it inefficient and difficult to process further.

With the decimation filter you are able to take your ADC oversample frequency to a lower frequency.

When ADC is an incremental delta-sigma modulator, there is a 16 decimation factor. Meaning that the output changes every 16 input bits from the ADC.
When ADC is a regular delta-sigma modulator, output changes every time the reset button is set to high. 

## How to test
Connect an ADC with a 1 bit output to input 1.
Put mode for decimation according
  * Incremental DSM (type 1): Input 2 low
  * Regulat DSM (type 2) Input 2 high

#### Incremental DSM
Select type 1 by setting input 2 low
Connect a clock to the reset input of the decimation filter with the desired decimated frequency.
Ex: ADC oversample frequency: 50MHz
    Desired decimated frequency: 25MHz
    Reset frequency: 25MHz
    Decimation factor: 2

#### Regular DSM
Select type 2 by setting input 2 high
The decimation factor for a regular ADC is set to 16
If wanting to do a different decimation factor follow the steps for an incremental DSM

Get 16 bit output where
  * Most significant 8 bits: Dedicated output pins
  * Less significant 8 bits: General-purpose IO pins

## External hardware

Incremental or Regular Delta Sigma Modulator ADC
