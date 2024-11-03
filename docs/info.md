<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Decimation filter used to reduce the sample frequency of an incremental and a regular Delta-Sigma Modulator by a factor of 16.

Input: 1 bit
Output: 16 bits

Connect an ADC with a 1 bit output 
After oversampling, the output of a Delta-Sigma modulator is at a much higher data rate than necessary. The decimation filter not only removes unwanted high-frequency noise but also reduces the data rate, making the ADC’s output usable for further processing.

Decimaiton filter removes high-frequency quantization noise introduced during oversampling. As well as reduces the sampling rate by downsampling the data, making it easier to handle and process while maintaining signal integrity.

Without the decimation filter, the oversampled output of the Delta-Sigma ADC would have too much noise and an unnecessarily high data rate, making it inefficient and difficult to process further.


## How to test

Connect an ADC with a 1 bit output and get the 16 bit output

## External hardware

Incremental Delta Sigma ADC
