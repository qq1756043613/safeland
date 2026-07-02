class mst_driver extends uvm_driver #(transaction);
  transaction req;
  int len;
  int erri;
  int errj;
  bit [2:0] awhandshake;
  bit [2:0] awhandshakeflag;
  bit awhigh, awmid, awlow;
  bit [2:0] whandshake;
  bit whigh, wmid, wlow;
  bit [2:0] bhandshake;
  bit bhigh, bmid, blow;
  bit [2:0] arhandshake;
  bit arhigh, armid, arlow;
  bit [2:0] rhandshake;
  bit rhigh, rmid, rlow;

  virtual mst_if vif; //connect to simtop/interface
  uvm_analysis_port #(transaction) ap;
  `uvm_component_utils( mst_driver )

  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task main_phase( uvm_phase phase);
  extern task driver_bus();
  extern task debug_info();

endclass

function mst_driver::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction


function void mst_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  //get virtual interface
  if( !uvm_config_db #(virtual mst_if) :: get(this, "", "mst_if", vif))
    `uvm_fatal("mst_driver","Error in getting interface");
  ap = new("ap",this);
endfunction

task mst_driver::main_phase(uvm_phase phase);
  super.main_phase(phase);
  while(1) begin
    seq_item_port.get_next_item( req );
    driver_bus();
    debug_info();
    ap.write(req);
    seq_item_port.item_done();
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ECD_WDATA[%0d][%0d]",errj,erri));
    if(!req.m_WVALID==1)
      erri = erri+1;
    if(erri == 64) begin
      erri = 0;
      errj = errj + 1;
    end
    if(errj == 4) begin
      errj = 0;
    end
    `uvm_info("mst_driver","drive one transaction",UVM_LOW);
  end
endtask


task mst_driver::debug_info();
  `uvm_info("mst_driver","send a transaction",UVM_LOW);
  `uvm_info("mst_driver",$sformatf("id=%h",req.m_AWID),UVM_LOW);
  `uvm_info("mst_driver",$sformatf("awaddr=%h",req.m_AWADDR),UVM_LOW);
  `uvm_info("mst_driver",$sformatf("awvalid=%h",req.m_AWVALID),UVM_LOW);
  `uvm_info("mst_driver",$sformatf("awsize=%h",req.m_AWSIZE),UVM_LOW);
  `uvm_info("mst_driver",$sformatf("awlen=%h",req.m_AWLEN),UVM_LOW);
  `uvm_info("mst_driver",$sformatf("awprot=%h",req.m_AWPROT),UVM_LOW);
  `uvm_info("mst_driver",$sformatf("awburst=%h",req.m_AWBURST),UVM_LOW);
  `uvm_info("mst_driver",$sformatf("wdata=%h",req.m_WDATA),UVM_LOW);
  `uvm_info("mst_driver",$sformatf("whandshake=%b",whandshake),UVM_LOW);
  `uvm_info("mst_driver",$sformatf("whigh=%b",whigh),UVM_LOW);
  `uvm_info("mst_driver",$sformatf("wmid=%b",wmid),UVM_LOW);
  `uvm_info("mst_driver",$sformatf("wlow=%b",wlow),UVM_LOW);
endtask

task mst_driver::driver_bus();
  //case(req.mode)
  //AW begin
  fork
    if((req.mode & `AW)) begin
      //@vif.drv_cb;
      while(1) begin
        awhandshake = req.m_AWVALID & vif.m_AWREADY;
        if((!awhandshake)==1) begin
          `uvm_info("mst_driver","awhandshake OK",UVM_LOW);
          break;
        end
        `uvm_info("mst_driver","no awhandshake",UVM_LOW);
        @vif.drv_cb;
      end
      awhigh = (awhandshake & 3'b100)==3'b100;
      awmid  = (awhandshake & 3'b010)==3'b010;
      awlow  = (awhandshake & 3'b001)==3'b001;
      vif.drv_cb.m_AWID     <= req.m_AWID & {{`DMST_ID_W{awhigh}},{`DMST_ID_W{awmid}},{`DMST_ID_W{awlow}}};
      vif.drv_cb.m_AWADDR   <= req.m_AWADDR & {{`DADDR_WIDTH{awhigh}},{`DADDR_WIDTH{awmid}},{`DADDR_WIDTH{awlow}}};
      vif.drv_cb.m_AWSIZE   <= req.m_AWSIZE & {{`DTRANS_DATA_SIZE_W{awhigh}},{`DTRANS_DATA_SIZE_W{awmid}},{`DTRANS_DATA_SIZE_W{awlow}}};
      vif.drv_cb.m_AWLEN    <= req.m_AWLEN & {{`DTRANS_DATA_LEN_W{awhigh}},{`DTRANS_DATA_LEN_W{awmid}},{`DTRANS_DATA_LEN_W{awlow}}};
      vif.drv_cb.m_AWPROT   <= req.m_AWPROT & {{`DPROT_WIDTH{awhigh}},{`DPROT_WIDTH{awmid}},{`DPROT_WIDTH{awlow}}};
      vif.drv_cb.m_AWBURST  <= req.m_AWBURST & {{`DTRANS_BURST_W{awhigh}},{`DTRANS_BURST_W{awmid}},{`DTRANS_BURST_W{awlow}}};
      @vif.drv_cb;
      vif.drv_cb.m_AWVALID <= req.m_AWVALID;
      @vif.drv_cb;
      vif.drv_cb.m_AWVALID <= 0;
    end
    //end

    //'W:begin
    //@vif.drv_cb;
    //begin
    if((req.mode & `W)) begin
      whandshake = req.m_WVALID & vif.m_WREADY;
      whigh = (whandshake & 3'b100)==3'b100;
      wmid  = (whandshake & 3'b010)==3'b010;
      wlow  = (whandshake & 3'b001)==3'b001;
      case(whandshake)
        3'b001: len = req.m_AWLEN[3:0];
        3'b010: len = req.m_AWLEN[7:4];
        3'b100: len = req.m_AWLEN[11:8];
      endcase
      while(1) begin
        if((!whandshake)==1)
          break;
        @vif.drv_cb;
        `uvm_info("mst_driver","no whandshake",UVM_LOW);
      end
      if(req.err_inject == 1) begin
        `uvm_info("mst_driver","injecting!",UVM_LOW);
        uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ECD_WDATA[%0d][%0d]",errj,erri),1);
      end
      else if(req.err_inject == 2) begin
        `uvm_info("mst_driver","R injecting!",UVM_LOW);
        uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_ECD_RDATA[%0d][%0d]",errj,erri),1);
      end

      for(int i = 0; i<=len; i++) begin
        vif.drv_cb.m_WLAST <=0;
        //@vif.drv_cb;
        vif.drv_cb.m_WDATA <= (req.m_WDATA+i*{1,{64{0}}}+i*{1,{128{0}}}) & {{`DDATA_WIDTH{whigh}},{`DDATA_WIDTH{wmid}},{`DDATA_WIDTH{wlow}}};
        if(i == 0) begin
          @vif.drv_cb;
        end
        vif.drv_cb.m_WVALID <= req.m_WVALID;
        //@vif.drv_cb;
        if(i == len ) begin
          vif.drv_cb.m_WLAST <= req.m_WLAST & whandshake;
          awhandshake = 0;
        end
        @vif.drv_cb;
      end
      //@vif.drv_cb;
      vif.drv_cb.m_WLAST <=0;
      vif.drv_cb.m_WVALID <= 0;
      //vif.drv_cb.m_BREADY <= whandshake;
      vif.drv_cb.m_BREADY <= 3'b111;
      //@vif.drv_cb;
      bhandshake = whandshake & vif.m_BVALID;
      if((whandshake==bhandshake)&&(bhandshake==1)) begin
        req.m_BRESP <= vif.m_BRESP;
        req.m_BID   <= vif.m_BID;
        whandshake = 0;
        bhandshake = 0;
        vif.drv_cb.m_BREADY <= 0;
      end else begin
        req.m_BRESP <= 0;
        req.m_BID   <= 0;
      end
    end
    if((!req.mode & `AR)) begin
      //@vif.drv_cb;
      while(1) begin
        arhandshake = req.m_ARVALID & vif.m_ARREADY;
        if((!arhandshake)==1)
          break;
        @vif.drv_cb;
        `uvm_info("mst_driver","no arhandshake",UVM_LOW);
      end
      //vif.drv_cb.m_RREADY <= 3'b111;
      arhigh = (arhandshake & 3'b100)==3'b100;
      armid  = (arhandshake & 3'b010)==3'b010;
      arlow  = (arhandshake & 3'b001)==3'b001;
      vif.drv_cb.m_ARID    <= req.m_ARID & {{`DMST_ID_W{arhigh}},{`DMST_ID_W{armid}},{`DMST_ID_W{arlow}}};
      vif.drv_cb.m_ARADDR  <= req.m_ARADDR & {{`DADDR_WIDTH{arhigh}},{`DADDR_WIDTH{armid}},{`DADDR_WIDTH{arlow}}};
      vif.drv_cb.m_ARSIZE  <= req.m_ARSIZE & {{`DTRANS_DATA_SIZE_W{arhigh}},{`DTRANS_DATA_SIZE_W{armid}},{`DTRANS_DATA_SIZE_W{arlow}}};
      vif.drv_cb.m_ARLEN   <= req.m_ARLEN & {{`DTRANS_DATA_LEN_W{arhigh}},{`DTRANS_DATA_LEN_W{armid}},{`DTRANS_DATA_LEN_W{arlow}}};
      vif.drv_cb.m_ARPROT  <= req.m_ARPROT & {{`DPROT_WIDTH{arhigh}},{`DPROT_WIDTH{armid}},{`DPROT_WIDTH{arlow}}};
      vif.drv_cb.m_ARBURST <= req.m_ARBURST & {{`DTRANS_BURST_W{arhigh}},{`DTRANS_BURST_W{armid}},{`DTRANS_BURST_W{arlow}}};
      @vif.drv_cb;
      vif.drv_cb.m_ARVALID <= req.m_ARVALID;
      @vif.drv_cb;
      vif.drv_cb.m_ARVALID <= 0;
    end
  join

endtask