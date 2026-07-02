module dsp_R_channel
#(
    // Dispatcher configuration
    parameter SLV_AMT = 2,

    // Transaction configuration
    parameter DATA_WIDTH = 32,
    parameter TRANS_MST_ID_W = 5,   // Bus width of master transaction ID
    parameter TRANS_WR_RESP_W = 2,

    // Slave configuration
    parameter SLV_ID_W = $clog2(SLV_AMT),

    // Dispatcher DATA depth configuration
    parameter DSP_RDATA_DEPTH = 16
)
(
    // Input declaration
    input ACLK_i,
    input ARESETn_i,

    // -- To Master (slave interface of the interconnect)
    input m_RREADY_i,

    // -- To Slave Arbitration (read data channel master)
    input [TRANS_MST_ID_W*SLV_AMT-1:0] sa_RID_i,
    input [DATA_WIDTH*SLV_AMT-1:0]     sa_RDATA_i,
    input [TRANS_WR_RESP_W*SLV_AMT-1:0] sa_RRESP_i,
    input [SLV_AMT-1:0]                 sa_RLAST_i,
    input [SLV_AMT-1:0]                 sa_RVALID_i,

    // -- To AR channel Dispatcher
    input [SLV_ID_W-1:0] dsp_AR_slv_id_i,
    input dsp_AR_disable_i,

    // Output declaration
    output [TRANS_MST_ID_W-1:0] m_RID_o,
    output [DATA_WIDTH-1:0]     m_RDATA_o,
    output [TRANS_WR_RESP_W-1:0] m_RRESP_o,
    output m_RLAST_o,
    output m_RVALID_o,

    // To Slave Arbitration
    output [SLV_AMT-1:0] sa_RREADY_o,

    // To DSP AR channel
    output dsp_RVALID_q1_o,
    output dsp_RREADY_q1_o
);

// Local parameter
localparam DATA_INFO_W =
    TRANS_MST_ID_W + DATA_WIDTH + TRANS_WR_RESP_W + 1;

// Internal variable declaration
genvar slv_idx;

// Internal signal declaration
// -- RDATA FIFO
wire [DATA_INFO_W-1:0] data_info [SLV_AMT-1:0];
wire [DATA_INFO_W-1:0] data_info_valid [SLV_AMT-1:0];
wire [SLV_AMT-1:0] fifo_rdata_wr_en;
wire [SLV_AMT-1:0] fifo_rdata_rd_en;
wire [SLV_AMT-1:0] fifo_rdata_empty;
wire [SLV_AMT-1:0] fifo_rdata_full;

// Handshake detector
wire sa_handshake_occurr [SLV_AMT-1:0];
wire m_handshake_occurr;

// Misc
wire [TRANS_MST_ID_W-1:0] sa_RID_valid [SLV_AMT-1:0];
wire [DATA_WIDTH-1:0]     sa_RDATA_valid [SLV_AMT-1:0];
wire [TRANS_WR_RESP_W-1:0] sa_RRESP_valid [SLV_AMT-1:0];
wire sa_RLAST_valid [SLV_AMT-1:0];

// Master skid buffer
wire [DATA_INFO_W-1:0] msb_bwd_data;
wire msb_bwd_valid;
wire msb_bwd_ready;
wire [TRANS_MST_ID_W-1:0] msb_fwd_RID;
wire [DATA_WIDTH-1:0]     msb_fwd_RDATA;
wire [TRANS_WR_RESP_W-1:0] msb_fwd_RRESP;
wire msb_fwd_RLAST;

// ---------------- Module ----------------

// RDATA FIFO
generate
for (slv_idx = 0; slv_idx < SLV_AMT; slv_idx = slv_idx + 1) begin : SLV_FIFO
    fifo #(
        .DATA_WIDTH(DATA_INFO_W),
        .FIFO_DEPTH(DSP_RDATA_DEPTH)
    ) fifo_rdata (
        .clk(ACLK_i),
        .rst_n(ARESETn_i),
        .data_i(data_info[slv_idx]),
        .data_o(data_info_valid[slv_idx]),
        .rd_valid_i(fifo_rdata_rd_en[slv_idx]),
        .wr_valid_i(fifo_rdata_wr_en[slv_idx]),
        .empty_o(fifo_rdata_empty[slv_idx]),
        .full_o(fifo_rdata_full[slv_idx]),
        .almost_empty_o(),
        .almost_full_o(),
        .counter(),
        .rst_n(ARESETn_i)
    );
end
endgenerate

// Master skid buffer
skid_buffer #(
    .SBUF_TYPE(3),
    .DATA_WIDTH(DATA_INFO_W)
) mst_skid_buffer (
    .clk(ACLK_i),
    .rst_n(ARESETn_i),
    .bwd_data_i(msb_bwd_data),
    .bwd_valid_i(msb_bwd_valid),
    .fwd_ready_i(msb_bwd_ready),
    .fwd_data_o({msb_fwd_RID, msb_fwd_RDATA, msb_fwd_RRESP, msb_fwd_RLAST}),
    .bwd_ready_o(msb_bwd_ready),
    .fwd_valid_o(msb_bwd_valid)
);

endmodule