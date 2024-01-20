// One special testbench

`timescale 1ns/1ps
`include "axi_stream_insert_header.v"

module tb();
    parameter DATA_WD = 32;
    parameter DATA_BYTE_WD = DATA_WD / 8;
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);
    parameter packet_size = 16; // length of stream
    parameter data_size =  32'd4294967295; // data range
    parameter byte_size = 4; // header byte range

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
    reg [DATA_BYTE_WD-1 : 0] keep_insert; 
    reg [BYTE_CNT_WD-1 : 0] byte_insert_cnt;
    wire ready_insert;

    always #5 clk = ~clk;

    // Initialize
    initial begin
        clk = 0;
        rst_n = 1;
        #5  rst_n = 0;
        #10 rst_n = 1;
        
    end 

    wire [BYTE_CNT_WD-1:0] random;
    //  Header stimulus
    initial  begin
        #20
        #4  valid_insert = 1; 
            data_insert = {$random} % data_size; 
            byte_insert_cnt = {$random} % (byte_size-1);
            if (byte_insert_cnt == 3 ) 
                keep_insert = 4'b1111;
            else if (byte_insert_cnt == 2)
                keep_insert = 4'b0111;
            else if (byte_insert_cnt == 1)
                keep_insert = 4'b0011;
            else
                keep_insert = 4'b0001;
        #15 valid_insert = 0; 
            keep_insert = 'bx; 
            data_insert = 'bx; 

        #15 ready_out = 1;
        #10 ready_out = 0;
        
    end

    reg [1:0] random_in;
    initial  begin
        // data input
        #20
        #14  valid_in = 1; 
        #15  valid_in = 0;  
    end

    integer i;
    initial begin
        #20
        #14

        for (i = 0; i < packet_size-1; i = i + 1) begin
            #10
            data_in = {$random} % (data_size);
            keep_in = -1;   
        end
        #10
        last_in = 1;
        data_in = {$random} % (data_size);
        random_in = {$random} % byte_size;
        if (byte_insert_cnt == 3 ) 
            keep_in = 4'b0;
        else if (byte_insert_cnt == 2)
            keep_insert = 4'b1000;
        else if (byte_insert_cnt == 1) begin
            if (random_in % 2)
                keep_in = 4'b1000;
            else
                keep_in = 4'b1100;
        end          
        else begin
            if (random_in % 3 == 0)
                keep_in = 4'b1000;
            else if (random_in % 3 == 1)
                keep_in = 4'b1100;
            else 
                keep_in = 4'b1110;
        end

        #10 last_in = 0;
          
    end
         
    axi_stream_insert_header axi0 (clk,rst_n,valid_in,data_in,keep_in, last_in,ready_in,valid_out,data_out,keep_out,last_out,ready_out, valid_insert,data_insert,keep_insert,byte_insert_cnt,ready_insert);

endmodule