module dsp_W_channel
#(
    // Dispatcher configuration
    parameter SLV_AMT = 2,

    // Transaction configuration
    parameter DATA_WIDTH = 32,

    // Slave configuration
    parameter SLV_ID_W = $clog2(SLV_AMT),
    parameter SLV_ID_MSB_IDX = 30,
    parameter SLV_ID_LSB_IDX = 30
)
(
    input ACLK_i,
    input ARESETn_i,

    // Write data channel (master)
    input [DATA_WIDTH-1:0] m_WDATA_i,
    input m_WLAST_i,
    input m_WVALID_i,

    // To Slave Arbitration
    input [SLV_AMT-1:0] sa_WREADY_i,

    // From AW channel
    input [SLV_ID_W-1:0] dsp_AW_slv_id_i,
    input dsp_AW_disable_i,

    // Outputs to master
    output m_WREADY_o,

    // To slave arbitration
    output [DATA_WIDTH*SLV_AMT-1:0] sa_WDATA_o,
    output [SLV_AMT-1:0]            sa_WLAST_o,
    output [SLV_AMT-1:0]            sa_WVALID_o,

    // To AW channel dispatcher
    output dsp_AW_WVALID_o,
    output dsp_AW_WREADY_o
);

// localparam
localparam SLV_ID_VALID_W = SLV_ID_W + 1;
localparam W_INFO_W = DATA_WIDTH + 1;

// internal
genvar slv_idx;

wire [SLV_ID_VALID_W-1:0] slv_id_valid;
wire [SLV_AMT-1:0] slv_sel;

// skid buffer
wire [W_INFO_W-1:0] msb_bwd_data;
wire msb_bwd_valid;
wire msb_bwd_ready;

wire [W_INFO_W-1:0] msb_fwd_data;
wire msb_fwd_valid;
wire msb_fwd_ready;

wire [DATA_WIDTH-1:0] msb_fwd_WDATA;
wire msb_fwd_WLAST;

// Hamming
wire [64:0] data_in;
wire [79:0] data_encoded;
wire [64:0] data_decoded;
wire wrong;

wire [79:0] origin_encoded_data;
wire [79:0] msb_bwd_data_ecd;
wire [79:0] msb_fwd_data_ecd;

// decoder
onehot_decoder #(
    .INPUT_W(SLV_ID_VALID_W),
    .OUTPUT_W(SLV_AMT)
) slave_id_decoder (
    .i(slv_id_valid),
    .o(slv_sel)
);

// skid buffer
skid_buffer #(
    .SBUF_TYPE(1),
    .DATA_WIDTH(80)
) mst_skid_buffer (
    .clk(ACLK_i),
    .rst_n(ARESETn_i),
    .bwd_data_i(msb_bwd_data_ecd),
    .bwd_valid_i(msb_bwd_valid),
    .fwd_ready_i(msb_fwd_ready),
    .fwd_data_o(msb_fwd_data_ecd),
    .bwd_ready_o(msb_bwd_ready),
    .fwd_valid_o(msb_fwd_valid)
);

// Hamming encoder/decoder
hamming_W_encoder u_hwe (
    .data_in(data_in),
    .encoded_data(origin_encoded_data)
);

hamming_W_decoder u_hwd (
    .received_data(data_encoded),
    .wrong(wrong),
    .decoded_data(data_decoded)
);

// ID valid
assign slv_id_valid = {dsp_AW_disable_i, dsp_AW_slv_id_i};

// master ready
assign m_WREADY_o = msb_bwd_ready;

// generate outputs to slaves
generate
for (slv_idx = 0; slv_idx < SLV_AMT; slv_idx = slv_idx + 1) begin : SLV_LOGIC
    assign sa_WDATA_o[DATA_WIDTH*(slv_idx+1)-1 -: DATA_WIDTH] = msb_fwd_WDATA;
    assign sa_WLAST_o[slv_idx] = msb_fwd_WLAST;
    assign sa_WVALID_o[slv_idx] = msb_fwd_valid & slv_sel[slv_idx];
end
endgenerate

// AW interface
assign dsp_AW_WVALID_o = msb_fwd_valid;
assign dsp_AW_WREADY_o = msb_fwd_ready;

// master skid mapping
assign msb_bwd_data = {m_WDATA_i, m_WLAST_i};
assign msb_bwd_valid = m_WVALID_i;
assign msb_fwd_ready = (~dsp_AW_disable_i) & sa_WREADY_i[dsp_AW_slv_id_i];

// hamming datapath
assign data_in = msb_bwd_data;
assign msb_bwd_data_ecd = origin_encoded_data;
assign data_encoded = msb_fwd_data_ecd;
assign msb_fwd_data = data_decoded;

assign {msb_fwd_WDATA, msb_fwd_WLAST} = msb_fwd_data;

endmodule