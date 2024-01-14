
module axi_stream_insert_header #(
parameter DATA_WD = 32,
parameter DATA_BYTE_WD = DATA_WD / 8,
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)) 
(
input wire clk,
input wire rst_n,
// AXI Stream input original data
input wire valid_in,
input wire [DATA_WD-1 : 0] data_in,
input wire [DATA_BYTE_WD-1 : 0] keep_in,
input wire last_in,
output reg ready_in,
// AXI Stream output with header inserted
output reg valid_out,
output reg [DATA_WD-1 : 0] data_out,
output reg [DATA_BYTE_WD-1 : 0] keep_out,
output reg last_out,
input wire ready_out,
// The header to be inserted to AXI Stream input
input wire valid_insert,
input wire [DATA_WD-1 : 0] data_insert,
input wire [DATA_BYTE_WD-1 : 0] keep_insert,  // keep_insert and keep_in correspond to each other
input wire [BYTE_CNT_WD-1 : 0] byte_insert_cnt,
output reg ready_insert
);
// Your code here
//    reg ready_in,valid_out,last_out,ready_insert;
//    wire clk,rst_n,valid_in,last_in,ready_out,valid_insert;
//    wire data_in,keep_in,data_insert,keep_insert,byte_insert_cnt;
//    reg data_out,keep_out;

    reg [2*DATA_WD-1 : 0] I_reg;  // register data and header
    reg tag;  // Control the storage location of data, 1 for I_reg[2*DATA_WD-1 : DATA_WD]
    reg out_state,data_state; // store input data and header 
    // Header and data
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready_insert <= 0;
            ready_in <= 0;
            I_reg <= 0;
            out_state <= 0;
            tag <= 1;  
            last_out <= 0;
            valid_out <= 0;
            data_state <= 0;
        end      
        else begin

            if(valid_insert) 
                ready_insert <= ~ready_insert;         // handshake
            else 
                ready_insert <= ready_insert; 

            if(valid_in) 
                ready_in <= ~ready_in;
            else 
                ready_in <= ready_in ; 

            if (valid_insert) data_state <= 1;  // data/header input state
            else if (last_in) data_state <= 0;
            else data_state <= data_state;

            if(data_state) tag <= !tag; // register
            else tag <= tag ;
            if(tag && data_state)  begin
                if(valid_insert) I_reg[2*DATA_WD-1 : DATA_WD] <= data_insert; 
                else I_reg[2*DATA_WD-1 : DATA_WD] <= data_in;
            end
            else if(!tag && data_state) begin
                if(valid_insert) I_reg[DATA_WD-1 : 0] <= data_insert;
                else I_reg[DATA_WD-1 : 0] <= data_in;
            end
            else I_reg <= I_reg;

            last_out <= last_in;  //  output 
            valid_out <= valid_in;
            if (valid_out) out_state <= 1;
            else if(last_out)out_state <= 0;
            else out_state <= out_state;

        end
        
    end
    
    // output data
    // Assuming that the packet size of the input data is the same as the packet size of the output data, 
    // so keep_insert and keep_in are correspond to each other and output has 4 register combination.
    always @(*) begin
        if(out_state) begin
            if (tag) begin  // output has 1 clk latency
                if(keep_insert == 4'b1111)
                    data_out = I_reg[2*DATA_WD-1 : DATA_WD];
                else if(keep_insert == 4'b0111)
                    data_out = I_reg[2*DATA_WD-9 : DATA_WD-8];
                else if(keep_insert == 4'b0011)
                    data_out = I_reg[2*DATA_WD-17 : DATA_WD-16];
                else if(keep_insert == 4'b0001)
                    data_out = I_reg[2*DATA_WD-25 : DATA_WD-24];
            end
            else begin
                if(keep_insert == 4'b1111)
                    data_out = I_reg[DATA_WD-1 : 0];
                else if(keep_insert == 4'b0111)
                    data_out = {I_reg[DATA_WD-9 :0],I_reg[2*DATA_WD-1 :2*DATA_WD-8]};
                else if(keep_insert == 4'b0011)
                    data_out = {I_reg[DATA_WD-17 :0],I_reg[2*DATA_WD-1 :2*DATA_WD-16]};
                else if(keep_insert == 4'b0001)
                    data_out = {I_reg[DATA_WD-25 :0],I_reg[2*DATA_WD-1 :2*DATA_WD-24]};
            end
        end
        else data_out = 32'bz;

        if(last_out) begin     // keep_in
            if(keep_in == 4'b1110)
                keep_out = 4'b1111;
            else if(keep_in == 4'b1100) begin
                if(byte_insert_cnt == 1)
                    keep_out = 4'b1110 ;
                else keep_out = 4'b1111;
            end
            else if(keep_in == 4'b1000) begin
                if(byte_insert_cnt == 1) keep_out = 4'b1100;
                else if(byte_insert_cnt == 2) keep_out = 4'b1110;
                else keep_out = 4'b1111;
            end
            else 
                keep_out = 4'bz;  
        end 
        else keep_out = 4'bz;
            
    end

endmodule
