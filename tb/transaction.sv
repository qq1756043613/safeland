class transaction #(
  int MST_AMT          = 3,
  int SLV_AMT          = 4,
  int ADDR_WIDTH       = 32,
  int DATA_WIDTH       = 64,
  int TRANS_BURST_W    = 2,
  int TRANS_MST_ID_W   = 5,
  int TRANS_SLV_ID_W   = 7,
  int TRANS_DATA_LEN_W = 4,
  int TRANS_DATA_SIZE_W= 3,
  int TRANS_WR_RESP_W  = 2,
  int PROT_WIDTH       = 3
) extends uvm_sequence_item;

  bit                  wcomp;
  bit                  rcomp;
  bit                  awcomp;
  bit                  arcomp;
  bit                  out_of_order;
  int                  mode;
  rand bit [MST_AMT-1:0]                         m_AWVALID;
  rand bit [ADDR_WIDTH*MST_AMT-1:0]              m_AWADDR;
  bit [TRANS_BURST_W*MST_AMT-1:0]                m_AWBURST;
  rand bit [TRANS_MST_ID_W*MST_AMT-1:0]          m_AWID;
  rand bit [TRANS_DATA_LEN_W*MST_AMT-1:0]        m_AWLEN;
  bit [TRANS_DATA_SIZE_W*MST_AMT-1:0]            m_AWSIZE;
  bit [PROT_WIDTH*MST_AMT-1:0]                   m_AWPROT;
  rand bit [DATA_WIDTH*MST_AMT-1:0]              m_WDATA;
  rand bit [MST_AMT-1:0]                         m_WVALID;
  bit [MST_AMT-1:0]                              m_WLAST;
  bit [SLV_AMT-1:0]                              s_BVALID;
  bit [TRANS_MST_ID_W*MST_AMT-1:0]               m_BID;
  bit [TRANS_WR_RESP_W*MST_AMT-1:0]              m_BRESP;
  bit [TRANS_SLV_ID_W*SLV_AMT-1:0]               s_BID;
  bit [TRANS_WR_RESP_W*SLV_AMT-1:0]              s_BRESP;
  rand bit [MST_AMT-1:0]                         m_ARVALID;
  rand bit [ADDR_WIDTH*MST_AMT-1:0]              m_ARADDR;
  bit [TRANS_BURST_W*MST_AMT-1:0]                m_ARBURST;
  randc bit [TRANS_MST_ID_W*MST_AMT-1:0]         m_ARID;
  rand bit [TRANS_DATA_LEN_W*MST_AMT-1:0]        m_ARLEN;
  bit [TRANS_DATA_SIZE_W*MST_AMT-1:0]            m_ARSIZE;
  bit [PROT_WIDTH*MST_AMT-1:0]                   m_ARPROT;
  bit [3:0]                                      err_inject;


  //register to uvm_factory
  `uvm_object_utils_begin( transaction )
    `uvm_field_int( m_AWVALID , UVM_ALL_ON )
    `uvm_field_int( m_AWADDR  , UVM_ALL_ON )
    `uvm_field_int( m_AWBURST , UVM_ALL_ON )
    `uvm_field_int( m_AWID    , UVM_ALL_ON )
    `uvm_field_int( m_AWLEN   , UVM_ALL_ON )
    `uvm_field_int( m_AWSIZE  , UVM_ALL_ON )
    `uvm_field_int( m_AWPROT  , UVM_ALL_ON )
    `uvm_field_int( m_WDATA   , UVM_ALL_ON )
    `uvm_field_int( m_WVALID  , UVM_ALL_ON )
    `uvm_field_int( m_WLAST   , UVM_ALL_ON )
    `uvm_field_int( s_BVALID  , UVM_ALL_ON )
    `uvm_field_int( s_BID     , UVM_ALL_ON )
    `uvm_field_int( s_BRESP   , UVM_ALL_ON )
  `uvm_object_utils_end

  constraint C_wvalid {
    m_ARVALID inside {3'b001,3'b010,3'b100};
    m_AWVALID inside {3'b001,3'b010,3'b100};
    m_WVALID == m_AWVALID;
    if(m_AWVALID == 3'b001)
      m_AWADDR[31:30] inside {2'b01,2'b11};
    if(m_AWVALID == 3'b010)
      m_AWADDR[63:62] inside {2'b01,2'b11};
    if(m_AWVALID == 3'b100)
      m_AWADDR[95:94] inside {2'b0,2'b10};
    if(m_ARVALID == 3'b001)
      m_ARADDR[31:30] inside {2'b01,2'b11};
    if(m_ARVALID == 3'b010)
      m_ARADDR[63:62] inside {2'b01,2'b11};
    if(m_ARVALID == 3'b100)
      m_ARADDR[95:94] inside {2'b0,2'b10};
  }

  function new(string name="transaction");
    super.new(name);
  endfunction

endclass