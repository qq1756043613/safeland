class err_driver extends uvm_driver #(transaction);
  transaction req;
  int iaw0;
  int jaw0;
  int iaw1;
  int iaw2;
  virtual mst_if vif; //connect to simtop/interface
  `uvm_component_utils( err_driver )

  extern function new(string name,uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task main_phase( uvm_phase phase);
  extern task driver_bus();
  extern task debug_info();

endclass

function err_driver::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction


function void err_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  //get virtual interface
  if( !uvm_config_db #(virtual mst_if) :: get(this, "", "mst_if", vif))
    `uvm_fatal("err_driver","Error in getting interface");
endfunction

task err_driver::main_phase(uvm_phase phase);
  super.main_phase(phase);
  iaw0 = 1;
  jaw0 = 0;
  iaw1 = 1;
  iaw2 = 1;
  seq_item_port.get_next_item( req );
  seq_item_port.item_done();
  while(1) begin

    driver_bus();
    debug_info();
    `uvm_info("err_driver","drive one transaction",UVM_LOW);
  end
endtask

task err_driver::debug_info();

endtask

task err_driver::driver_bus();
  @vif.drv_cb;
  if(req.err_inject==4'b1000) begin
    `uvm_info("err_driver","fifo err inject!!!",UVM_LOW);
    if(vif.m_AWVALID == 1) begin
      if(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[0].dispatcher.write_channel.AW_channel.fifo_xaddr_order.data_ecd[iaw0]==0)
        uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[0].dispatcher.write_channel.AW_channel.fifo_xaddr_order.buffer[%0d][%0d]",jaw0,iaw0),1);
      else
        uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[0].dispatcher.write_channel.AW_channel.fifo_xaddr_order.buffer[%0d][%0d]",jaw0,iaw0),1);

      @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[0].dispatcher.write_channel.AW_channel.fifo_xaddr_order.rfer[%0d][%0d]",jaw0,iaw0));
      iaw0 = iaw0+1;
      if(iaw0==64) begin
        iaw0 = 0;
        jaw0 = jaw0+1;
      end
      if(jaw0 == 8)
        jaw0 = 0;

    end else if(vif.m_AWVALID == 3'b010) begin
      if(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[1].dispatcher.write_channel.AW_channel.fifo_xaddr_order.data_ecd[iaw0]==0)
        uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[1].dispatcher.write_channel.AW_channel.fifo_xaddr_order.buffer[%0d][%0d]",jaw0,iaw0),1);
      else
        uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[1].dispatcher.write_channel.AW_channel.fifo_xaddr_order.buffer[%0d][%0d]",jaw0,iaw0),1);

      @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[1].dispatcher.write_channel.AW_channel.fifo_xaddr_order.rfer[%0d][%0d]",jaw0,iaw0));
      iaw0 = iaw0+1;
      if(iaw0==64) begin
        iaw0 = 0;
        jaw0 = jaw0+1;
      end
      if(jaw0 == 8)
        jaw0 = 0;

    end else if(vif.m_AWVALID == 3'b100) begin
      if(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[2].dispatcher.write_channel.AW_channel.fifo_xaddr_order.data_ecd[iaw0]==0)
        uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[2].dispatcher.write_channel.AW_channel.fifo_xaddr_order.buffer[%0d][%0d]",jaw0,iaw0),1);
      else
        uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[2].dispatcher.write_channel.AW_channel.fifo_xaddr_order.buffer[%0d][%0d]",jaw0,iaw0),1);

      @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[2].dispatcher.write_channel.AW_channel.fifo_xaddr_order.rfer[%0d][%0d]",jaw0,iaw0));
      iaw0 = iaw0+1;
      if(iaw0==64) begin
        iaw0 = 0;
        jaw0 = jaw0+1;
      end
      if(jaw0 == 8)
        jaw0 = 0;
    end
  end

  if(req.err_inject==4'b101) begin
    `uvm_info("err_driver","comb err inject!!!",UVM_LOW);
    if(vif.m_AWVALID == 1) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[0].dispatcher.write_channel.AW_channel.msb_fwd_ready"),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[0].dispatcher.write_channel.AW_channel.msb_fwd_ready"));
    end
    else if(vif.m_AWVALID == 3'b010) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[1].dispatcher.write_channel.AW_channel.msb_fwd_ready"),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[1].dispatcher.write_channel.AW_channel.msb_fwd_ready"));
    end
    else if(vif.m_AWVALID == 3'b100) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[2].dispatcher.write_channel.AW_channel.msb_fwd_ready"),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.DSP_GEN[2].dispatcher.write_channel.AW_channel.msb_fwd_ready"));
    end
  end

  if(req.err_inject==4'b110) begin
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.AR_channel.x_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.AR_channel.x_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.AR_channel.x_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.AR_channel.x_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.AW_channel.x_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.AW_channel.x_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.AW_channel.x_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.AW_channel.x_channel_shift_en"),0);

    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.W_channel.WDATA_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.W_channel.WDATA_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.W_channel.WDATA_channel_shift_en"),0);

    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.R_channel.RDATA_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.R_channel.RDATA_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.R_channel.RDATA_channel_shift_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.R_channel.RDATA_channel_shift_en"),0);

    repeat(2)
      @vif.drv_cb;
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.AR_channel.x_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.AR_channel.x_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.AR_channel.x_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.AR_channel.x_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.AW_channel.x_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.AW_channel.x_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.AW_channel.x_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.AW_channel.x_channel_shift_en"));

    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.W_channel.WDATA_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.W_channel.WDATA_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.W_channel.WDATA_channel_shift_en"));

    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.R_channel.RDATA_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.R_channel.RDATA_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.R_channel.RDATA_channel_shift_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.R_channel.RDATA_channel_shift_en"));
  end

  if(req.err_inject==4'b111) begin
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.AR_channel.xDATA_fifo_order_wr_en_o"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.AR_channel.xDATA_fifo_order_wr_en_o"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.AR_channel.xDATA_fifo_order_wr_en_o"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.AR_channel.xDATA_fifo_order_wr_en_o"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.AW_channel.xDATA_fifo_order_wr_en_o"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.AW_channel.xDATA_fifo_order_wr_en_o"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.AW_channel.xDATA_fifo_order_wr_en_o"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.AW_channel.xDATA_fifo_order_wr_en_o"),0);

    repeat(2)
      @vif.drv_cb;
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.AR_channel.xDATA_fifo_order_wr_en_o"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.AR_channel.xDATA_fifo_order_wr_en_o"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.AR_channel.xDATA_fifo_order_wr_en_o"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.AR_channel.xDATA_fifo_order_wr_en_o"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.AW_channel.xDATA_fifo_order_wr_en_o"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.AW_channel.xDATA_fifo_order_wr_en_o"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.AW_channel.xDATA_fifo_order_wr_en_o"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.AW_channel.xDATA_fifo_order_wr_en_o"));
  end

  if(req.err_inject==4'b1000) begin
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.R_channel.fifo_filter_wr_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.R_channel.fifo_filter_wr_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.R_channel.fifo_filter_wr_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.R_channel.fifo_filter_wr_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.R_channel.fifo_filter_rd_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.R_channel.fifo_filter_rd_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.R_channel.fifo_filter_rd_en"),0);
    uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.R_channel.fifo_filter_rd_en"),0);
    repeat(2)
      @vif.drv_cb;
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.R_channel.fifo_filter_wr_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.R_channel.fifo_filter_wr_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.R_channel.fifo_filter_wr_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.R_channel.fifo_filter_wr_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[0].genblk1.slave_arbitration.R_channel.fifo_filter_rd_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[1].genblk1.slave_arbitration.R_channel.fifo_filter_rd_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[2].genblk1.slave_arbitration.R_channel.fifo_filter_rd_en"));
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.SA_GEN[3].genblk1.slave_arbitration.R_channel.fifo_filter_rd_en"));
  end

  if(req.err_inject==4'b1111) begin
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWID_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWID_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWID_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARID_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARID_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARID_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_AWID_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWID_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWID_i[%0d]",i));
    end

    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_ARID_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARID_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARID_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWADDR_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWADDR_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWADDR_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARADDR_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARADDR_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARADDR_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_AWADDR_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWLEN_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWLEN_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARLEN_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARLEN_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARLEN_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_AWLEN_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_AWLEN_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_AWLEN_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_ARLEN_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_ARLEN_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_ARLEN_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_WDATA_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_WDATA_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_WDATA_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_WLAST_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_WLAST_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_WLAST_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_WDATA_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_WDATA_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_WDATA_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_WLAST_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_WLAST_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_WLAST_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RDATA_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RDATA_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RDATA_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RLAST_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RLAST_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RLAST_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_BID_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_BID_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_BID_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_BRESP_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_BRESP_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_BRESP_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RID_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RID_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RID_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RRESP_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RRESP_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RRESP_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWVALID_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWVALID_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWVALID_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_AWVALID_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_AWVALID_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_AWVALID_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWREADY_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWVALID_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWVALID_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_AWREADY_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWREADY_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_AWREADY_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_WREADY_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_WREADY_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_WREADY_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_WREADY_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_WREADY_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_WREADY_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RREADY_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RREADY_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RREADY_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_RREADY_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_RREADY_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_RREADY_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARVALID_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARVALID_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_ARVALID_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_ARVALID_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_ARVALID_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_ARVALID_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_BVALID_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_BVALID_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_BVALID_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_BVALID_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_BVALID_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_BVALID_o[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_RVALID_i[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_RVALID_i[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_RVALID_i[%0d]",i));
    end
    foreach(simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RVALID_o[i]) begin
      uvm_hdl_force($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RVALID_o[%0d]",i),0);
      repeat(2)
        @vif.drv_cb;
      uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.m_RVALID_o[%0d]",i));
    end
  end
endtask