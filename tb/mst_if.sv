interface mst_if#(
  // Interconnect configuration
  int                         MST_AMT          = 3,
  int                         SLV_AMT          = 4,
  int                         OUTSTANDING_AMT  = 8,
  int                         MST_ID_W         = $clog2(MST_AMT),
  int                         SLV_ID_W         = $clog2(SLV_AMT),
  // Transaction configuration
  int                         DATA_WIDTH       = 64,
  int                         ADDR_WIDTH       = 32,
  int                         TRANS_MST_ID_W   = 5,                         // Bus width of master transaction ID
  int                         TRANS_SLV_ID_W   = TRANS_MST_ID_W + MST_ID_W, // Bus width of slave transaction ID
  int                         TRANS_BURST_W    = 2,                         // Width of xBURST
  int                         TRANS_DATA_LEN_W = 4,                         // Bus width of xLEN
  int                         TRANS_DATA_SIZE_W= 3,                         // Bus width of xSIZE
  int                         TRANS_WR_RESP_W  = 2,
  int                         PROT_WIDTH       = 3
)(
  input clk,
  input rst_n
);

  logic [MST_AMT-1:0] [TRANS_MST_ID_W-1:0]    m_AWID;
  logic [MST_AMT-1:0] [ADDR_WIDTH-1:0]         m_AWADDR;
  logic [MST_AMT-1:0] [TRANS_BURST_W-1:0]      m_AWBURST;
  logic [MST_AMT-1:0] [TRANS_DATA_LEN_W-1:0]   m_AWLEN;
  logic [MST_AMT-1:0] [TRANS_DATA_SIZE_W-1:0]  m_AWSIZE;
  logic [MST_AMT-1:0]                          m_AWVALID;
  logic [MST_AMT-1:0] [PROT_WIDTH-1:0]         m_AWPROT;
  logic [MST_AMT-1:0] [DATA_WIDTH-1:0]         m_WDATA;
  logic [MST_AMT-1:0]                          m_WLAST;
  logic [MST_AMT-1:0]                          m_WVALID;
  // -- -- -- Write response channel
  logic [MST_AMT-1:0]                          m_BREADY;
  // -- -- -- Read address channel
  logic [MST_AMT-1:0] [TRANS_MST_ID_W-1:0]     m_ARID;
  logic [MST_AMT-1:0] [ADDR_WIDTH-1:0]         m_ARADDR;
  logic [MST_AMT-1:0] [TRANS_BURST_W-1:0]      m_ARBURST;
  logic [MST_AMT-1:0] [TRANS_DATA_LEN_W-1:0]   m_ARLEN;
  logic [MST_AMT-1:0] [TRANS_DATA_SIZE_W-1:0]  m_ARSIZE;
  logic [MST_AMT-1:0] [PROT_WIDTH-1:0]         m_ARPROT;
  logic [MST_AMT-1:0]                          m_ARVALID;
  // -- -- -- Read data channel
  logic [MST_AMT-1:0]                          m_RREADY;
  // -- -- Output
  // -- -- -- Write address channel (master)
  logic [MST_AMT-1:0]                          m_AWREADY;
  // -- -- -- Write data channel (master)
  logic [MST_AMT-1:0]                          m_WREADY;
  // -- -- -- Write response channel (master)
  logic [MST_AMT-1:0] [TRANS_MST_ID_W-1:0]     m_BID;
  logic [MST_AMT-1:0] [TRANS_WR_RESP_W-1:0]    m_BRESP;
  logic [MST_AMT-1:0]                          m_BVALID;
  // -- -- -- Read address channel (master)
  logic [MST_AMT-1:0]                          m_ARREADY;
  // -- -- -- Read data channel (master)
  logic [MST_AMT-1:0] [TRANS_MST_ID_W-1:0]     m_RID;
  logic [MST_AMT-1:0] [DATA_WIDTH-1:0]         m_RDATA;
  logic [MST_AMT-1:0] [TRANS_WR_RESP_W-1:0]    m_RRESP;
  logic [MST_AMT-1:0]                          m_RLAST;
  logic [MST_AMT-1:0]                          m_RVALID;
  logic [5:0]                                  RERR;
  logic [2:0]                                  WSAFE;
  logic [2:0]                                  RSAFE;


  clocking drv_cb @(posedge clk);
    default input #1 output #1;
      output m_AWID;
      output m_AWADDR;
      output m_AWVALID;
      input  m_AWREADY;
      output m_AWSIZE;
      output m_AWLEN;
      output m_AWPROT;
      output m_AWBURST;
      output m_WDATA;
      output m_WVALID;
      output m_WLAST;
      input  m_WREADY;
      output m_ARID;
      output m_ARADDR;
      output m_ARVALID;
      input  m_ARREADY;
      output m_ARSIZE;
      output m_ARLEN;
      output m_ARPROT;
      output m_ARBURST;
      output m_BREADY;
      output m_RREADY;
  endclocking

endinterface