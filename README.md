# axi_stream_insert_header
1. **Introduction**
   Add the header before the data ，and output the concatenated data stream. Like this：
   ![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/054370b7-a904-4215-8237-a795dc410579)
   Output and Input data have same bit widths

**2.condition**
This module can work under the following transmission timing：
![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/9b9ab810-1c0d-49c7-a76f-c6d673c2125c)
Output data has a 1 clk delay relative to input data

**3. circuit structure**
![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/393c463c-9175-469e-a836-8cfcc7cd6f72)

The data is alternately stored in the upper and lower parts of the register（8 bit Reg  × 8）.The output data is obtained by reading a specific register through a multiplexer.

**4. Result**
![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/c3ddadee-0889-494d-8489-578700c3a638)

