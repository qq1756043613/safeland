// Old version FIFO, synchronous‑FIFO with Hamming ECC
module fifo
#(
    parameter DATA_WIDTH  = 8,
    parameter FIFO_DEPTH  = 32,
    // Do not configure
    parameter ADDR_WIDTH  = $clog2(FIFO_DEPTH)
)
(
    input                         clk,

    input      [DATA_WIDTH - 1:0] data_i,
    output reg [DATA_WIDTH - 1:0] data_o,

    input                         wr_valid_i,
    input                         rd_valid_i,

    output                        empty_o,
    output                        full_o,
    output                        almost_empty_o,
    output                        almost_full_o,

    output     [ADDR_WIDTH:0]     counter,
    input                         rst_n
);

localparam DATA_HAM_WIDTH = (DATA_WIDTH>64) ? DATA_WIDTH : 64;

// Internal variable declaration
genvar addr;

// Internal signal declaration
// wire declaration
wire [ADDR_WIDTH:0]    wr_addr_inc;
wire [ADDR_WIDTH - 1:0] wr_addr_map;
wire [ADDR_WIDTH:0]    rd_addr_inc;
wire [ADDR_WIDTH - 1:0] rd_addr_map;

wire [DATA_HAM_WIDTH+7:0] buffer_nxt [0:FIFO_DEPTH - 1];

// reg declaration
reg [DATA_HAM_WIDTH + 7:0] buffer [0:FIFO_DEPTH - 1];
reg [ADDR_WIDTH:0]         wr_addr;
reg [ADDR_WIDTH:0]         rd_addr;

wire [DATA_HAM_WIDTH-1:0]  data_ham_in;
reg  [DATA_HAM_WIDTH-1:0]  data_ham_out;
wire [DATA_HAM_WIDTH+7:0]  data_ecd;
wire [DATA_HAM_WIDTH+7:0]  data_ecd_o;

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

// combinational logic
assign wr_addr_inc  = wr_addr + 1'b1;
assign rd_addr_inc  = rd_addr + 1'b1;
assign wr_addr_map  = wr_addr[ADDR_WIDTH - 1:0];
assign rd_addr_map  = rd_addr[ADDR_WIDTH - 1:0];

assign data_ecd_o   = buffer[rd_addr_map];

assign empty_o      = wr_addr == rd_addr;
assign almost_empty_o = rd_addr_inc == wr_addr;
assign full_o       = (wr_addr_map == rd_addr_map) && (wr_addr[ADDR_WIDTH] ^ rd_addr[ADDR_WIDTH]);
assign almost_full_o = wr_addr_map + 1'b1 == rd_addr_map;
assign counter      = wr_addr - rd_addr;

generate
    for(addr = 0; addr < FIFO_DEPTH; addr = addr + 1) begin : BUF_NXT_GEN
        assign buffer_nxt[addr] = (wr_addr_map == addr) ? data_ecd : buffer[addr];
    end
endgenerate

// flip‑flop logic
// -- Buffer updater
//VCS coverage off
generate
    for(addr = 0; addr < FIFO_DEPTH; addr = addr + 1) begin : BUF_LOAD
        always @(posedge clk) begin
            if(!rst_n) begin
                buffer[addr] <= {DATA_HAM_WIDTH+8{1'b0}};
            end
            else if(wr_valid_i && !full_o) begin
                buffer[addr] <= buffer_nxt[addr];
            end
        end
    end
endgenerate
//VCS coverage on

// -- Write pointer updater
always @(posedge clk) begin
    if(!rst_n) begin
        wr_addr <= 0;
    end
    else if(wr_valid_i && !full_o) begin
        wr_addr <= wr_addr_inc;
    end
end

// -- Read pointer updater
always @(posedge clk) begin
    if(!rst_n) begin
        rd_addr <= 0;
    end
    else if(rd_valid_i && !empty_o) begin
        rd_addr <= rd_addr_inc;
    end
end

endmodule
