// One special testbench

`timescale 10ps/1ps
`include "axi_stream_insert_header.v"

module tb();
    parameter DATA_WD = 32;
    parameter DATA_BYTE_WD = DATA_WD / 8;
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);
    reg clk;
    reg rst_n;
// AXI Stream input original data
    reg valid_in;
    reg [DATA_WD-1 : 0] data_in;
    reg [DATA_BYTE_WD-1 : 0] keep_in;
    reg last_in;
    wire ready_in;
// AXI Stream output with header inserted
    wire  valid_out;
    wire  [DATA_WD-1 : 0] data_out;
    wire  [DATA_BYTE_WD-1 : 0] keep_out;
    wire last_out;
    reg  ready_out;
// The header to be inserted to AXI Stream input
    reg valid_insert;
    reg [DATA_WD-1 : 0] data_insert;
    reg [DATA_BYTE_WD-1 : 0] keep_insert; // 和keep——in对应
    reg [BYTE_CNT_WD-1 : 0] byte_insert_cnt;
    wire ready_insert;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        #4 rst_n = 0;
        #10 rst_n = 1;
        #10 valid_insert = 1; data_insert = 32'hcccccccc; keep_insert=4'b0111; byte_insert_cnt = 3;
        #12 valid_insert = 0;
    end 

    initial begin
        #4 
        #10 
        #20 valid_in = 1; data_in = 32'hab34fad1; keep_in=4'b1111; last_in=0;
        #13  data_in = 32'h23497401; keep_in=4'b1111; 
        #2  valid_in = 0;
        #8  data_in = 32'h457fab00; keep_in=4'b1111; 
        #10  data_in = 32'habcdffdf; keep_in=4'b1000; last_in=1;
        
    end 

    initial begin
        #4 
        #10 
        #30 ready_out = 1; 
        #10  ready_out = 0;

    end 

    axi_stream_insert_header axi0 (clk,rst_n,valid_in,data_in,keep_in, last_in,ready_in,valid_out,data_out,keep_out, last_out,ready_out, valid_insert,data_insert,keep_insert,byte_insert_cnt,ready_insert);

endmodule