module sb_fifo
#(
    parameter DATA_WIDTH  = 8,
    parameter FIFO_DEPTH  = 2,
    // Do not configure
    parameter ADDR_WIDTH  = $clog2(FIFO_DEPTH)
)
(
    input                         clk,

    input      [DATA_WIDTH - 1:0] data_i,
    output reg [DATA_WIDTH - 1:0] data_o,

    input                         wr_valid_i,
    input                         rd_valid_i,

    output                        wr_ready_o,
    output                        rd_ready_o,

    input                         rst_n
);

localparam DATA_HAM_WIDTH = (DATA_WIDTH>=64) ? DATA_WIDTH : 64;

// Internal variable declaration
genvar addr;

wire [DATA_HAM_WIDTH-1:0]  data_ham_in;
reg  [DATA_HAM_WIDTH-1:0]  data_ham_out;
wire [DATA_HAM_WIDTH+7:0]  data_ecd;
reg  [DATA_HAM_WIDTH+7:0]  data_ecd_o;

assign data_ham_in = {{(DATA_HAM_WIDTH-DATA_WIDTH){1'b0}}, data_i} & {DATA_HAM_WIDTH{1'b1}};
assign data_o      = data_ham_out[DATA_WIDTH-1:0];

hamming_general_encoder
#(
    .DATA_WIDTH(DATA_HAM_WIDTH)
) u_he(
    .data_in(data_ham_in),
    .encoded_data(data_ecd)
);

hamming_general_decoder
#(
    .DATA_WIDTH(DATA_HAM_WIDTH)
) u_hd(
    .received_data(data_ecd_o),
    .decoded_data(data_ham_out)
);

// Internal signal
// -- wire
wire rd_handshake;
wire wr_handshake;
// -- reg
reg [DATA_HAM_WIDTH+7:0] mem [0:FIFO_DEPTH-1];
reg [ADDR_WIDTH:0] rd_ptr;
reg [ADDR_WIDTH:0] wr_ptr;

// Combination logic
assign data_ecd_o       = mem[rd_ptr[ADDR_WIDTH-1:0]];
assign wr_ready_o       = ~((rd_ptr[ADDR_WIDTH]^wr_ptr[ADDR_WIDTH]) && (~(rd_ptr[ADDR_WIDTH-1:0]^wr_ptr[ADDR_WIDTH-1:0])));
assign rd_ready_o       = |(rd_ptr^wr_ptr);
assign rd_handshake     = rd_valid_i & rd_ready_o;
assign wr_handshake     = wr_valid_i & wr_ready_o;

// Flip‑flop/RAM
always @(posedge clk) begin
    if(wr_handshake) begin
        mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_ecd;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        wr_ptr <= {(ADDR_WIDTH+1){1'b0}};
    end
    else if(wr_handshake) begin
        wr_ptr <= wr_ptr + 1'b1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        rd_ptr <= {(ADDR_WIDTH+1){1'b0}};
    end
    else if(rd_handshake) begin
        rd_ptr <= rd_ptr + 1'b1;
    end
end

endmodule
