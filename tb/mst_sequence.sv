class mst_sequence extends uvm_sequence #(transaction);

  `uvm_object_utils(mst_sequence)

  transaction tr;

  bit                  mode;
  bit                  awflag;
  bit [95:0]           awaddr;
  bit [2:0]            awvalid;
  bit [14:0]           awburst;
  bit [14:0]           awid;
  bit [8:0]            awsize;
  bit [11:0]           awlen;
  bit [8:0]            awprot;
  bit                  wflag;
  bit [2:0]            wvalid;
  bit [191:0]          wdata;
  bit [2:0]            wlast;
  bit                  arflag;
  bit [95:0]           araddr;
  bit [2:0]            arvalid;
  bit [14:0]           arburst;
  bit [14:0]           arid;
  bit [8:0]            arsize;
  bit [11:0]           arlen;
  bit [8:0]            arprot;
  bit [3:0]            err;


  function new(string name = "mst_sequence");
    super.new(name);
  endfunction


  function set_err_inject(
    bit [3:0] ierr
  );
    err = ierr;
  endfunction


  function set_awmode(
    int        imode,
    bit        iawflag,
    bit [95:0] iawaddr,
    bit [2:0]  iawvalid,
    bit [5:0]  iawburst,
    bit [14:0] iawid,
    bit [8:0]  iawsize,
    bit [11:0] iawlen,
    bit [8:0]  iawprot,
    bit        iwflag,
    bit [2:0]  iwvalid,
    bit [191:0] iwdata,
    bit [2:0]  iwlast
  );
    mode    = imode;
    awflag  = iawflag;
    awaddr  = iawaddr;
    awvalid = iawvalid;
    awburst = iawburst;
    awid    = iawid;
    awsize  = iawsize;
    awlen   = iawlen;
    awprot  = iawprot;
    wflag   = iwflag;
    wvalid  = iwvalid;
    wdata   = iwdata;
    wlast   = iwlast;
  endfunction


  function set_wmode(
    int        imode,
    bit        iawflag,
    bit [95:0] iawaddr,
    bit [2:0]  iawvalid,
    bit [5:0]  iawburst,
    bit [14:0] iawid,
    bit [8:0]  iawsize,
    bit [11:0] iawlen,
    bit [8:0]  iawprot,
    bit        iwflag,
    bit [2:0]  iwvalid,
    bit [191:0] iwdata,
    bit [2:0]  iwlast
  );
    mode    = imode;
    awflag  = iawflag;
    awaddr  = iawaddr;
    awvalid = iawvalid;
    awburst = iawburst;
    awid    = iawid;
    awsize  = iawsize;
    awlen   = iawlen;
    awprot  = iawprot;
    wflag   = iwflag;
    wvalid  = iwvalid;
    wdata   = iwdata;
    wlast   = iwlast;
  endfunction


  function set_armode(
    int        imode,
    bit        iarflag,
    bit [95:0] iaraddr,
    bit [2:0]  iarvalid,
    bit [5:0]  iarburst,
    bit [14:0] iarid,
    bit [8:0]  iarsize,
    bit [11:0] iarlen,
    bit [8:0]  iarprot
  );
    mode    = imode;
    arflag  = iarflag;
    arid    = iarid;
    araddr  = iaraddr;
    arvalid = iarvalid;

    arburst = iarburst;
    arsize  = iarsize;
    arlen   = iarlen;
    arprot  = iarprot;
  endfunction


  function set_special();
    tr.mode      = mode;
    tr.m_AWADDR  = awaddr;
    tr.m_AWVALID = awvalid;
    tr.m_AWBURST = awburst;
    tr.m_AWID    = awid;
    tr.m_AWLEN   = awlen;
    tr.m_AWSIZE  = awsize;
    tr.m_AWPROT  = awprot;
    tr.m_WDATA   = wdata;
    tr.m_WLAST   = wlast;
    tr.m_WVALID  = wvalid;
    tr.m_ARADDR  = araddr;
    tr.m_ARVALID = arvalid;
    tr.m_ARBURST = arburst;
    tr.m_ARID    = arid;
    tr.m_ARLEN   = arlen;
    tr.m_ARSIZE  = arsize;
    tr.m_ARPROT  = arprot;
    tr.err_inject = err;
  endfunction


  virtual task body();

    tr = transaction::type_id::create("tr");
    start_item(tr);
    if(!(mode % `RAND)==1) begin
      set_special();
      if(tr.mode == `AW + `RAND || tr.mode == `W + `RAND)
        tr.random(tr.m_AWID); //seed
    end
    else begin
      set_special();
    end
    finish_item(tr);
    `uvm_info("mst_sequence","send one transaction",UVM_LOW);
  endtask

endclass