# axi_stream_insert_header
1. **Introduction**
   Add the header before the data ，and output the concatenated data stream. Like this：
   ![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/054370b7-a904-4215-8237-a795dc410579)
   Output and Input data have same bit widths

**2.condition**
1. This module can work under the following transmission timing：
![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/92451e97-f0d7-45d1-8f76-d9eef6a743de)
Because the output circuit is combinational logic, output data and input data change near the same rising edge. Due to the setup and hold time, the output data can only be registered in the input register of the next level on the next rising edge, just like a shift register.
2. Size of packet must be even.

**3. circuit structure**
![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/73b30536-f05c-4050-9e2c-48e3cda718cb)
The data is alternately stored in the upper and lower parts of the register.The output data is obtained by reading specific the specific part of the register through two multiplexers.

**4. Result**
![image](https://github.com/BIG-melon-xx/axi_stream_insert_header/assets/125166958/be477763-6f1f-4ead-bfcc-edb759dbd13f)



