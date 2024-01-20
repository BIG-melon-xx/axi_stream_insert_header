# axi_stream_insert_header
1. **Introduction**
   Add the header before the data ，and output the concatenated data stream. Like this：
   ![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/054370b7-a904-4215-8237-a795dc410579)
   Output and Input data have same bit widths

**2.condition**
1. This module can work under the following transmission timing：
![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/9b9ab810-1c0d-49c7-a76f-c6d673c2125c)
Output data has a 1 clk delay relative to input data
3. Size of packet must be even.

**3. circuit structure**
![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/73b30536-f05c-4050-9e2c-48e3cda718cb)
The data is alternately stored in the upper and lower parts of the register.The output data is obtained by reading specific the specific part of the register through two multiplexers.

**4. Result**
![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/e1e231e2-6649-4229-a392-3ac82711e2a5)


