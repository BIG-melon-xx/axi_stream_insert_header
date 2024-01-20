//
// Insert a AXI-stream header 
//
// Add header before the first beat of input data, delete possible invalid byte in header,
// and output the processed data in the form of protocol AXI-stream
//

module axi_stream_insert_header #(
    parameter DATA_WD = 32,  // must even
    parameter DATA_BYTE_WD = DATA_WD / 8,
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
)(
    input   wire                       clk,
    input   wire                       rst_n,

    // AXI Stream input original data
    input   wire                       valid_in,
    input   wire       [DATA_WD-1 : 0] data_in,
    input   wire  [DATA_BYTE_WD-1 : 0] keep_in,
    input   wire                       last_in,
    output  reg                        ready_in,

    // AXI Stream output with header inserted
    output  reg                        valid_out,
    output  reg        [DATA_WD-1 : 0] data_out,
    output  reg   [DATA_BYTE_WD-1 : 0] keep_out,
    output  reg                        last_out,
    input   wire                       ready_out,

    // The header to be inserted to AXI Stream input
    input   wire                       valid_insert,
    input   wire       [DATA_WD-1 : 0] data_insert,
    input   wire  [DATA_BYTE_WD-1 : 0] keep_insert,  
    input   wire   [BYTE_CNT_WD-1 : 0] byte_insert_cnt,
    output  reg                        ready_insert
);
    // Your code here

    reg     [2*DATA_WD-1 : 0] input_reg;      // Register input (data_in and data_insert)
    reg                       input_reg_tag;  // Indicates the different parts of the register
    reg                       output_state;   // Output or not
    reg                       input_state;    // Input or not 

    reg  [DATA_BYTE_WD-1 : 0] keep_insert_reg;// Register keep_insert

    // Control for header and original data(input)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready_insert <= 0;
            ready_in <= 0;
            input_reg <= 0;
            input_reg_tag <= 1;  
            input_state <= 0;
            keep_insert_reg <= 0;
        end      
        else begin
            //Register keep_insert
            if (keep_insert)
                keep_insert_reg <= keep_insert;
            else 
                keep_insert_reg <= keep_insert_reg; 

            // Handshake for header and original data
            if(valid_insert) 
                ready_insert <= ~ready_insert;         
            else 
                ready_insert <= ready_insert; 
            if(valid_in) 
                ready_in <= ~ready_in;
            else 
                ready_in <= ready_in ; 

            // Input state
            if (valid_insert) 
                input_state <= 1;  
            else if (last_in) 
                input_state <= 0;
            else 
                input_state <= input_state;

            // Input register
            if(input_state || output_state) // width always even, put input_reg_tag = 1 when last output over
                input_reg_tag <= !input_reg_tag; 
            else 
                input_reg_tag <= input_reg_tag ;

            if(input_reg_tag && input_state)  begin
                if(valid_insert) 
                    input_reg [2*DATA_WD-1 : DATA_WD] <= data_insert; 
                else 
                    input_reg [2*DATA_WD-1 : DATA_WD] <= data_in;
            end
            else if(!input_reg_tag && input_state) begin
                if(valid_insert) 
                    input_reg [DATA_WD-1 : 0] <= data_insert;
                else 
                    input_reg [DATA_WD-1 : 0] <= data_in;
            end
            else 
                input_reg <= input_reg;
        end
    end

    // Control for output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            last_out <= 0;
            valid_out <= 0;
            output_state <= 0;
        end
        else begin
            // Handshake for output
            last_out <= last_in;
            if (ready_out)  
                valid_out <= 0;
            else 
                valid_out <= valid_in;

            // Output state
            if (valid_out) 
                output_state <= 1;
            else if(last_out)
                output_state <= 0;
            else 
                output_state <= output_state;
        end
    end

    // Logic for output data
    genvar i;
    wire [DATA_WD-1 : 0] data_out_dummy [DATA_BYTE_WD - 2 : 0];
    wire [DATA_WD-1 : 0] data_out_reg [DATA_BYTE_WD - 2 : 0];
    wire [DATA_BYTE_WD-1 : 0] keep_out_dummy [DATA_BYTE_WD - 2 : 0];
    // MUX for output data and keep_out
    generate
         for(i = 0; i < DATA_BYTE_WD -1 ; i = i + 1)
             begin:MUX_OUTPUT
                assign data_out_reg [i] = input_reg_tag ? input_reg [DATA_WD + 7 + 8*i : 8 + 8*i] : {input_reg [i*8 + 7 : 0] , input_reg [2*DATA_WD-1 : DATA_WD + 8 + 8*i]}; 
                assign data_out_dummy [i] = (byte_insert_cnt == i) ? data_out_reg [i] : 0;

                assign keep_out_dummy [i] = {keep_insert_reg [i : 0] , keep_in [DATA_BYTE_WD-1 : i + 1]};
    end
    endgenerate

    always @(*) begin
        // output data
        if (output_state) begin
            if (byte_insert_cnt == 3) begin  // In reality, byte_insert_cnt == 3 does not exist under assumptions
                if (input_reg_tag)
                    data_out = input_reg [2*DATA_WD-1 : DATA_WD];
                else 
                    data_out = input_reg [DATA_WD-1 : 0];
            end
            else
                data_out = data_out_dummy [byte_insert_cnt];
        end
        else 
            data_out = 'bz;
        
        // keep_out
        if(last_out)      
            keep_out = keep_out_dummy [byte_insert_cnt];
        else
            keep_out = 'bz;
    end
    
endmodule
