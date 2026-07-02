module ai_slave_arbitration
#(
    // Interconnect configuration
    parameter MST_AMT = 4,
    parameter OUTSTANDING_AMT = 8,

    parameter [0:(MST_AMT*32)-1] MST_WEIGHT = {32'd5, 32'd3, 32'd2, 32'd1},
    parameter MST_ID_W = $clog2(MST_AMT),

    // Transaction configuration
    parameter DATA_WIDTH        = 32,
    parameter ADDR_WIDTH        = 32,
    parameter TRANS_MST_ID_W    = 5,
    parameter TRANS_SLV_ID_W    = TRANS_MST_ID_W + $clog2(MST_AMT),
    parameter TRANS_BURST_W     = 2,
    parameter TRANS_DATA_LEN_W  = 3,
    parameter TRANS_DATA_SIZE_W = 3,
    parameter TRANS_WR_RESP_W   = 2,

    // Slave info configuration
    parameter SLV_ID           = 0,
    parameter SLV_ID_MSB_IDX   = 30,
    parameter SLV_ID_LSB_IDX   = 30
)
(
    // ============================================================
    // Global signals
    // ============================================================
    input ACLK_i,
    input ARESETN_i,

    // ============================================================
    // From Dispatcher (write address)
    // ============================================================
    input [TRANS_MST_ID_W*MST_AMT-1:0] dsp_AWID_i,
    input [ADDR_WIDTH*MST_AMT-1:0]      dsp_AWADDR_i,
    input [TRANS_BURST_W*MST_AMT-1:0]   dsp_AWBURST_i,
    input [TRANS_DATA_LEN_W*MST_AMT-1:0] dsp_AWLEN_i,
    input [TRANS_DATA_SIZE_W*MST_AMT-1:0] dsp_AWSIZE_i,
    input [MST_AMT-1:0]                 dsp_AWVALID_i,
    input [MST_AMT-1:0]                 dsp_AW_outst_full_i,

    // Write data
    input [DATA_WIDTH*MST_AMT-1:0]      dsp_WDATA_i,
    input [MST_AMT-1:0]                 dsp_WLAST_i,
    input [MST_AMT-1:0]                 dsp_WVALID_i,
    input [MST_AMT-1:0]                 dsp_slv_sel_i,

    // Write response
    input [MST_AMT-1:0]                 dsp_BREADY_i,

    // Read address
    input [TRANS_MST_ID_W*MST_AMT-1:0]  dsp_ARID_i,
    input [ADDR_WIDTH*MST_AMT-1:0]      dsp_ARADDR_i,
    input [TRANS_BURST_W*MST_AMT-1:0]   dsp_ARBURST_i,
    input [TRANS_DATA_LEN_W*MST_AMT-1:0] dsp_ARLEN_i,
    input [TRANS_DATA_SIZE_W*MST_AMT-1:0] dsp_ARSIZE_i,
    input [MST_AMT-1:0]                 dsp_ARVALID_i,
    input [MST_AMT-1:0]                 dsp_AR_outst_full_i,

    // Read data
    input [MST_AMT-1:0]                 dsp_RREADY_i,

    // ============================================================
    // Slave side inputs
    // ============================================================
    input s_AWREADY_i,
    input s_WREADY_i,

    input [TRANS_SLV_ID_W-1:0]          s_BID_i,
    input [TRANS_WR_RESP_W-1:0]         s_BRESP_i,
    input                               s_BVALID_i,

    input s_ARREADY_i,

    input [TRANS_SLV_ID_W-1:0]          s_RID_i,
    input [DATA_WIDTH-1:0]              s_RDATA_i,
    input [TRANS_WR_RESP_W-1:0]         s_RRESP_i,
    input                               s_RLAST_i,
    input                               s_RVALID_i,

    // ============================================================
    // Outputs to Dispatcher (master side back)
    // ============================================================
    output [MST_AMT-1:0]                dsp_AWREADY_o,
    output [MST_AMT-1:0]                dsp_WREADY_o,

    output [TRANS_MST_ID_W*MST_AMT-1:0] dsp_BID_o,
    output [TRANS_WR_RESP_W*MST_AMT-1:0] dsp_BRESP_o,
    output [MST_AMT-1:0]                dsp_BVALID_o,

    output [MST_AMT-1:0]                dsp_ARREADY_o,

    output [TRANS_MST_ID_W*MST_AMT-1:0] dsp_RID_o,
    output [DATA_WIDTH*MST_AMT-1:0]     dsp_RDATA_o,
    output [TRANS_WR_RESP_W*MST_AMT-1:0] dsp_RRESP_o,
    output [MST_AMT-1:0]                dsp_RLAST_o,
    output [MST_AMT-1:0]                dsp_RVALID_o,

    // ============================================================
    // Outputs to Slave (after arbitration)
    // ============================================================
    output                              s_AWREADY_o,
    output                              s_WREADY_o,

    output [TRANS_SLV_ID_W-1:0]         s_AWID_o,
    output [ADDR_WIDTH-1:0]            s_AWADDR_o,
    output [TRANS_BURST_W-1:0]         s_AWBURST_o,
    output [TRANS_DATA_LEN_W-1:0]      s_AWLEN_o,
    output [TRANS_DATA_SIZE_W-1:0]     s_AWSIZE_o,
    output                              s_AWVALID_o,

    output [DATA_WIDTH-1:0]            s_WDATA_o,
    output                              s_WLAST_o,
    output                              s_WVALID_o,

    output                              s_BREADY_o,

    output [TRANS_SLV_ID_W-1:0]       s_ARID_o,
    output [ADDR_WIDTH-1:0]           s_ARADDR_o,
    output [TRANS_BURST_W-1:0]        s_ARBURST_o,
    output [TRANS_DATA_LEN_W-1:0]     s_ARLEN_o,
    output [TRANS_DATA_SIZE_W-1:0]    s_ARSIZE_o,
    output                              s_ARVALID_o,

    output                              s_RREADY_o
);

    // ============================================================
    // Internal signals
    // ============================================================
    wire [TRANS_SLV_ID_W-1:0] AWID_valid_nxt;
    wire [TRANS_DATA_LEN_W-1:0] AWLEN_valid_nxt;
    wire [MST_ID_W-1:0] AW_mst_valid_nxt;

    wire AW_crossing_flag;
    wire AW_shift_en;

    wire AW_stall;
    wire AW_stall_WDATA;
    wire AW_stall_WRESP;

    wire AR_crossing_flag;
    wire AR_shift_en;
    wire AR_stall;
    wire AR_stall_RDATA;

    assign AW_stall = AW_stall_WDATA | AW_stall_WRESP;
    assign AR_stall = AR_stall_RDATA;

    // ============================================================
    // Write Address arbitration channel
    // ============================================================
    sa_Ax_channel #(
        .MST_AMT(MST_AMT),
        .OUTSTANDING_AMT(OUTSTANDING_AMT),
        .MST_WEIGHT(MST_WEIGHT),
        .MST_ID_W(MST_ID_W),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .TRANS_MST_ID_W(TRANS_MST_ID_W),
        .TRANS_SLV_ID_W(TRANS_SLV_ID_W),
        .TRANS_BURST_W(TRANS_BURST_W),
        .TRANS_DATA_LEN_W(TRANS_DATA_LEN_W),
        .TRANS_DATA_SIZE_W(TRANS_DATA_SIZE_W),
        .SLV_ID(SLV_ID),
        .SLV_ID_MSB_IDX(SLV_ID_MSB_IDX),
        .SLV_ID_LSB_IDX(SLV_ID_LSB_IDX)
    ) AW_channel (
        .ACLK_i(ACLK_i),
        .ARESETN_i(ARESETN_i),

        .xDATA_stall_i(AW_stall),

        .dsp_AxID_i(dsp_AWID_i),
        .dsp_AxADDR_i(dsp_AWADDR_i),
        .dsp_AxBURST_i(dsp_AWBURST_i),
        .dsp_AxLEN_i(dsp_AWLEN_i),
        .dsp_AxSIZE_i(dsp_AWSIZE_i),
        .dsp_AxVALID_i(dsp_AWVALID_i),
        .dsp_dispatcher_full_i(dsp_AW_outst_full_i),

        .s_AxREADY_i(s_AWREADY_i),

        .s_AxREADY_o(dsp_AWREADY_o),
        .s_AxID_o(s_AWID_o),
        .s_AxADDR_o(s_AWADDR_o),
        .s_AxBURST_o(s_AWBURST_o),
        .s_AxLEN_o(s_AWLEN_o),
        .s_AxSIZE_o(s_AWSIZE_o),
        .s_AxVALID_o(s_AWVALID_o),

        .xDATA_AxID_o(AWID_valid_nxt),
        .xDATA_mst_id_o(AW_mst_valid_nxt),
        .xDATA_crossing_flag_o(AW_crossing_flag),
        .xDATA_AxLEN_o(AWLEN_valid_nxt),
        .xDATA_fifo_order_wr_en_o(AW_shift_en)
    );

endmodule