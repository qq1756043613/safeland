module dsp_Ax_channel
#(
    // Dispatcher configuration
    parameter SLV_AMT = 2,
    parameter OUTSTANDING_AMT = 8,
    parameter OUTST_CTN_W = $clog2(OUTSTANDING_AMT) + 1,

    // Transaction configuration
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter TRANS_MST_ID_W = 5,   // Bus width of master transaction ID
    parameter TRANS_BURST_W = 2,    // Width of xBURST
    parameter TRANS_DATA_LEN_W = 3, // Bus width of xLEN
    parameter TRANS_DATA_SIZE_W = 3,// Bus width of xSIZE

    // Slave configuration
    parameter SLV_ID_W = $clog2(SLV_AMT),
    parameter SLV_ID_MSB_IDX = 0,
    parameter SLV_ID_LSB_IDX = 0
)
(
    // Input declaration
    // -- Global signals
    input ACLK_i,
    input ARESETn_i,

    // -- To Master (slave interface of the interconnect)
    // ---- Write/Read address channel
    input [TRANS_MST_ID_W-1:0] m_AxID_i,
    input [ADDR_WIDTH-1:0]     m_AxADDR_i,
    input [TRANS_BURST_W-1:0]  m_AxBURST_i,
    input [TRANS_DATA_LEN_W-1:0] m_AxLEN_i,
    input [TRANS_DATA_SIZE_W-1:0] m_AxSIZE_i,
    input m_AxVALID_i,

    // -- To xDATA channel Dispatcher
    input m_xVALID_i,
    input m_xREADY_i,

    // -- To Slave Arbitration
    input [SLV_AMT-1:0] sa_AxREADY_i,

    // Output declaration
    m_AxREADY_o,

    // To Slave Arbitration
    output [TRANS_MST_ID_W*SLV_AMT-1:0] sa_AxID_o,
    output [ADDR_WIDTH*SLV_AMT-1:0]      sa_AxADDR_o,
    output [TRANS_BURST_W*SLV_AMT-1:0]   sa_AxBURST_o,
    output [TRANS_DATA_LEN_W*SLV_AMT-1:0] sa_AxLEN_o,
    output [TRANS_DATA_SIZE_W*SLV_AMT-1:0] sa_AxSIZE_o,
    output [SLV_AMT-1:0] sa_AxVALID_o,
    output [OUTST_CTN_W-1:0] sa_Ax_outst_ctn_o,

    // To xDATA channel Dispatcher
    output [SLV_ID_W-1:0] dsp_xDATA_slv_id_o,
    output dsp_xDATA_disable_o,

    // To WRESP channel Dispatcher
    output [SLV_ID_W-1:0] dsp_WRESP_slv_id_o,
    output dsp_WRESP_shift_en_o
);

// Local parameters initialization
localparam ADDR_INFO_W = SLV_ID_W + TRANS_DATA_LEN_W;
localparam AX_INFO_W   = TRANS_MST_ID_W + ADDR_WIDTH + TRANS_BURST_W + TRANS_DATA_LEN_W + TRANS_DATA_SIZE_W;
localparam SLV_ID_MAP_W = SLV_ID_MSB_IDX - SLV_ID_LSB_IDX + 1;

// Internal variable declaration
genvar slv_idx;

// Internal signal declaration
// -- xADDR order fifo
wire [ADDR_INFO_W-1:0] addr_info;
wire [ADDR_INFO_W-1:0] addr_info_valid;
wire fifo_xa_order_wr_en;
wire fifo_xa_order_rd_en;
wire fifo_xa_order_empty;
wire fifo_xa_order_full;

// -- Handshake detector
wire Ax_handshake_occurr;
wire xDATA_handshake_occurr;

// -- Misc
wire [SLV_ID_W-1:0] slv_id;
wire [SLV_AMT-1:0]   slv_sel;
wire [SLV_ID_MAP_W-1:0] addr_slv_mapping;
wire [TRANS_DATA_LEN_W-1:0] AxLEN_valid;

// Transfer counter
wire [TRANS_DATA_LEN_W-1:0] transfer_ctn_nxt;
wire [TRANS_DATA_LEN_W-1:0] transfer_ctn_incr;
wire [TRANS_DATA_LEN_W-1:0] transfer_ctn_match;

reg  [TRANS_DATA_LEN_W-1:0] transfer_ctn_r;

// Module
// -- xADDR order FIFO
fifo #(
    .DATA_WIDTH(ADDR_INFO_W),
    .FIFO_DEPTH(OUTSTANDING_AMT)
) fifo_xaddr_order (
    .clk(ACLK_i),
    .rst_n(ARESETn_i),
    .data_i(addr_info),
    .data_o(addr_info_valid),
    .rd_valid_i(fifo_xa_order_rd_en),
    .wr_valid_i(fifo_xa_order_wr_en),
    .empty_o(fifo_xa_order_empty),
    .full_o(fifo_xa_order_full)
);

// Master skid buffer
skid_buffer #(
    .DATA_WIDTH(AX_INFO_W)
) mst_skid_buffer (
    .clk(ACLK_i),
    .rst_n(ARESETn_i)
);

endmodule