interface slv_if#(
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
  // -- To Slave
  // -- -- Input
  // -- -- -- Write address channel (master)
  logic [SLV_AMT-1:0]                          s_AWREADY;
  // -- -- -- Write data channel (master)
  logic [SLV_AMT-1:0]                          s_WREADY;
  // -- -- -- Write response channel (master)
  logic [SLV_AMT-1:0] [TRANS_SLV_ID_W-1:0]     s_BID;
  logic [SLV_AMT-1:0] [TRANS_WR_RESP_W-1:0]    s_BRESP;
  logic [SLV_AMT-1:0]                          s_BVALID;
  // -- -- -- Read address channel (master)
  logic [SLV_AMT-1:0]                          s_ARREADY;
  // -- -- -- Read data channel (master)
  logic [SLV_AMT-1:0] [TRANS_SLV_ID_W-1:0]     s_RID;
  logic [SLV_AMT-1:0] [DATA_WIDTH-1:0]         s_RDATA;
  logic [SLV_AMT-1:0] [TRANS_WR_RESP_W-1:0]    s_RRESP;
  logic [SLV_AMT-1:0]                          s_RLAST;
  logic [SLV_AMT-1:0]                          s_RVALID;
  // -- -- Output
  // -- -- -- Write address channel
  logic [SLV_AMT-1:0] [TRANS_SLV_ID_W-1:0]     s_AWID;
  logic [SLV_AMT-1:0] [ADDR_WIDTH-1:0]         s_AWADDR;
  logic [SLV_AMT-1:0] [TRANS_BURST_W-1:0]      s_AWBURST;
  logic [SLV_AMT-1:0] [TRANS_DATA_LEN_W-1:0]   s_AWLEN;
  logic [SLV_AMT-1:0] [TRANS_DATA_SIZE_W-1:0]  s_AWSIZE;
  logic [SLV_AMT-1:0] [PROT_WIDTH-1:0]         s_AWPROT;
  logic [SLV_AMT-1:0]                          s_AWVALID;
  // -- -- -- Write data channel
  logic [SLV_AMT-1:0] [DATA_WIDTH-1:0]         s_WDATA;
  logic [SLV_AMT-1:0]                          s_WLAST;
  logic [SLV_AMT-1:0]                          s_WVALID;
  // -- -- -- Write response channel
  logic [SLV_AMT-1:0]                          s_BREADY;
  // -- -- -- Read address channel
  logic [SLV_AMT-1:0] [TRANS_SLV_ID_W-1:0]     s_ARID;
  logic [SLV_AMT-1:0] [ADDR_WIDTH-1:0]         s_ARADDR;
  logic [SLV_AMT-1:0] [TRANS_BURST_W-1:0]      s_ARBURST;
  logic [SLV_AMT-1:0] [TRANS_DATA_LEN_W-1:0]   s_ARLEN;
  logic [SLV_AMT-1:0] [TRANS_DATA_SIZE_W-1:0]  s_ARSIZE;
  logic [SLV_AMT-1:0] [PROT_WIDTH-1:0]         s_ARPROT;
  logic [SLV_AMT-1:0]                          s_ARVALID;
  // -- -- -- Read data channel
  logic [SLV_AMT-1:0]                          s_RREADY;
  logic [7:0]                                  WERR;


  clocking drv_cb @(posedge clk);
    default input #1 output #1;
      output s_AWREADY;
      input  s_AWVALID;
      input  s_AWLEN;
      input  s_AWID;
      output s_WREADY;
      input  s_WVALID;
      input  s_WDATA;
      input  s_WLAST;
      output s_BID;
      output s_BRESP;
      output s_BVALID;
      input  s_BREADY;
      output s_RID;
      output s_RRESP;
      output s_RVALID;
      output s_RDATA;
      output s_RLAST;
      input  s_ARID;
      output s_ARREADY;
      input  s_ARVALID;
      input  s_ARLEN;
  endclocking

endinterface