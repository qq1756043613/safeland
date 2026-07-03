class slv_driver extends uvm_driver #(transaction);
  transaction req;
  int erri;
  int errj;
  int len;
  int cnt;
  bit [3:0] rhandshake;
  bit slv1,slv2,slv3,slv4;
  bit [255:0] rdata;
  bit [47:0] ar [255:0];
  int arrptr;
  int arwptr;
  bit [27:0] wbid [255:0];
  int wrptr;
  int wwptr;
  int ocnt;
  virtual slv_if vif;

  `uvm_component_utils( slv_driver )


  extern function new(string name,uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task main_phase( uvm_phase phase);
  extern        task monitor_bus();
  extern        task monitor_bus_out_of_order();
  extern        task debug_info();

endclass

function slv_driver::new(string name,uvm_component parent);
  super.new(name,parent);
  for(int i=0;i<255;i++) wbid[i] = 0;
  for(int i=0;i<255;i++) ar[i] = 0;
  erri = 0;
  errj = 1;
  arrptr = 0;
  arwptr = 0;
  rdata = 0;
  wrptr = 0;
  wwptr = 0;
  cnt = 0;
  ocnt = 0;
endfunction


function void slv_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  //get virtual interface
  if( !uvm_config_db #(virtual slv_if) :: get(this,"","slv_if",vif))
    `uvm_fatal("slv_monitor","Error in getting interface");

endfunction

task slv_driver::main_phase(uvm_phase phase);
  super.main_phase(phase);
  seq_item_port.get_next_item(req);
  seq_item_port.item_done();

  while(1) begin
    if(req.out_of_order != 1) begin
      monitor_bus();
      debug_info();
    end else begin
      if(ocnt == 0) begin
        monitor_bus_out_of_order();
        ocnt = 1;
      end
      debug_info();
      @vif.drv_cb;
    end
    uvm_hdl_release($sformatf("simtop.u_axi_voter.AXI_GEN[0].u_axi_interconnect.s_ECD_RDATA[%0d][%0d]",errj,erri));
    //if(!vif.s_RVALID==1)
    erri = erri+1;
    if(erri == 64) begin
      erri = 0;
      errj = errj + 1;
    end
    if(errj == 3) begin
      errj = 0;
    end
  end
endtask


task slv_driver::debug_info();
  //`uvm_info("slv_driver","send a transaction",UVM_LOW);
  //`uvm_info("slv_driver",$sformatf("ar = %p",ar),UVM_LOW);
  //`uvm_info("slv_driver",$sformatf("wbid = %p",wbid),UVM_LOW);
endtask


task slv_driver::monitor_bus();
  @vif.drv_cb;
  fork
    begin
      if((|vif.s_AWVALID)==1) begin
        wbid[wwptr] = vif.s_AWID;
        wwptr = wwptr+1;
      end
      vif.drv_cb.s_AWREADY <= 4'b1111;
      vif.drv_cb.s_WREADY <= 4'b1111;
      //`uvm_info("slv_driver",$sformatf("wlast = %b",vif.drv_cb.s_WLAST),UVM_LOW);
      if((vif.drv_cb.s_WLAST[0] == 1'b1||vif.drv_cb.s_WLAST[1] == 1||vif.drv_cb.s_WLAST[2] == 1||vif.drv_cb.s_WLAST[3] == 1)&&(|vif.drv_cb.s_WVALID)) begin
        vif.drv_cb.s_BID <= wbid[wrptr];
        if((vif.drv_cb.s_WLAST[0]==1'b1)&&(wbid[wrptr][6:5]==2'b0||wbid[wrptr][6:5]==2'b1)) begin
          vif.drv_cb.s_BRESP <= 8'b00000010;
          `uvm_info("slv_driver","UNSAFETY DATA",UVM_LOW);
        end else if((vif.drv_cb.s_WLAST[2]==1'b1)&&(wbid[wrptr][20:19]==2'b0||wbid[wrptr][20:19]==2'b1)) begin
          vif.drv_cb.s_BRESP <= 8'b00100000;
          `uvm_info("slv_driver","UNSAFETY DATA",UVM_LOW);
        end else if((vif.drv_cb.s_WLAST[1]==1'b1)&&(wbid[wrptr][13:12]==2'b10)) begin
          vif.drv_cb.s_BRESP <= 8'b00001000;
          `uvm_info("slv_driver","UNSAFETY DATA",UVM_LOW);
        end else if((vif.drv_cb.s_WLAST[3]==1'b1)&&(wbid[wrptr][27:26]==2'b10)) begin
          vif.drv_cb.s_BRESP <= 8'b10000000;
          `uvm_info("slv_driver","UNSAFETY DATA",UVM_LOW);
        end else begin
          vif.drv_cb.s_BRESP <= 8'b0;
          `uvm_info("slv_driver","SAFETY DATA!",UVM_LOW);
        end

        vif.drv_cb.s_BVALID <= vif.drv_cb.s_WLAST;
        wrptr = wrptr+1;
        @vif.drv_cb;
        `uvm_info("slv_driver","wlast ok",UVM_LOW);
      end
      vif.drv_cb.s_BID <= 0;
      vif.drv_cb.s_BRESP <= 0;
      vif.drv_cb.s_BVALID <= 0;
      // `uvm_info("slv_driver",$sformatf("wbid = %p",wbid),UVM_LOW);
      if(wwptr==256)
        wwptr = 0;
      if(wrptr == 256)
        wrptr = 0;
    end
    begin
      if((|vif.s_ARVALID)==1) begin
        ar[arwptr] = {vif.s_ARID,vif.s_ARVALID,vif.s_ARLEN};
        arwptr = arwptr + 1;
        if(arwptr == 255)
          arwptr = 0;
      end
    end
    begin
      if(arwptr > arrptr) begin
        case(ar[arrptr][19:16])
          4'b0001:len = ar[arrptr][ 3: 0];
          4'b0010:len = ar[arrptr][ 7: 4];
          4'b0100:len = ar[arrptr][11: 8];
          4'b1000:len = ar[arrptr][15:12];
        endcase
        if(req.err_inject == 2) begin
          `uvm_info("mst_driver","R injecting!",UVM_LOW);
          `uvm_info("mst_driver",$sformatf("erri = %d",erri),UVM_LOW);
          uvm_hdl_force($sformatf("simtop.u_axi_interconnect.s_ECD_RDATA[%0d][%0d]",errj,erri),1);
        end

        //rdata = 256'h5a5a5a5a5a5a5a5a_5a5a5a5a5a5a5a5a_5a5a5a5a5a5a5a5a_5a5a5a5a5a5a5a5a;
        rdata = 256'h0;
        //$display("len = %d",len);
        //$display("ar = %p",ar);
        for(int i=0;i<=len;i++) begin

          vif.drv_cb.s_RID <= ar[arrptr][47:20];
          //`uvm_info("slv_driver",$sformatf("rdata = %h",rdata),UVM_LOW);
          vif.drv_cb.s_RDATA <= rdata;
          rdata = ~rdata;
          vif.drv_cb.s_RLAST <= 0;
          if(cnt == 0) begin
            @vif.drv_cb;
            cnt = 1;
          end
          vif.drv_cb.s_RVALID <= ar[arrptr][19:16];
          if(i==len) begin
            vif.drv_cb.s_RLAST <= ar[arrptr][19:16];
            if(ar[arrptr][16]==1&&((ar[arrptr][26:25]==2'b0)||ar[arrptr][26:25]==2'b1)) begin
              vif.drv_cb.s_RRESP <= 8'b00000010;
              `uvm_info("slv_driver","UNSAFETY DATA!",UVM_LOW);
            end else if(ar[arrptr][18]==1&&((ar[arrptr][40:39]==2'b0)||ar[arrptr][40:39]==2'b1)) begin
              vif.drv_cb.s_RRESP <= 8'b00100000;
              `uvm_info("slv_driver","UNSAFETY DATA!",UVM_LOW);
            end else if(ar[arrptr][17]==1&&(ar[arrptr][33:32]==2'b10)) begin
              vif.drv_cb.s_RRESP <= 8'b00001000;
              `uvm_info("slv_driver","UNSAFETY DATA!",UVM_LOW);
            end else if(ar[arrptr][19]==1&&(ar[arrptr][47:46]==2'b10)) begin
              vif.drv_cb.s_RRESP <= 8'b10000000;
              `uvm_info("slv_driver","UNSAFETY DATA!",UVM_LOW);
            end else begin
              vif.drv_cb.s_RRESP <= 8'b00000000;
              `uvm_info("slv_driver","SAFETY DATA!",UVM_LOW);
            end
          end
          @vif.drv_cb;
        end
        cnt = 0;
        vif.drv_cb.s_RLAST <= 0;
        arrptr = arrptr + 1;
        if(arrptr == 255)
          arrptr = 0;
        vif.drv_cb.s_RVALID <= 0;
        @vif.drv_cb;
      end
    end
  join
endtask


task slv_driver::monitor_bus_out_of_order();
  repeat(7) @vif.drv_cb;
  vif.drv_cb.s_RDATA <= 256'h0005_00000000_00000000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b1000;
  vif.drv_cb.s_RID <= 28'h0000001_000000_0000000_0000000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b0000;
  vif.drv_cb.s_RDATA <= 256'h0009_00000000_00000000_00000000_00000000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b0010;
  vif.drv_cb.s_RID <= 28'h0010_000000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b0000;
  vif.drv_cb.s_RDATA <= 256'h0001_00000000_00000000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b0010;
  vif.drv_cb.s_RID <= 28'h0000_000000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b0000;
  vif.drv_cb.s_RDATA <= 256'h0006_00000000_00000000;
  vif.drv_cb.s_RLAST <= 4'b0000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b1000;
  vif.drv_cb.s_RLAST <= 4'b1000;
  vif.drv_cb.s_RID <= 28'h1_000000_00000000_0000000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b0000;
  vif.drv_cb.s_RLAST <= 4'b0000;
  vif.drv_cb.s_RDATA <= 256'h000a_00000000_00000000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b0010;
  vif.drv_cb.s_RLAST <= 4'b0010;
  vif.drv_cb.s_RID <= 28'h0010_000000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b0000;
  vif.drv_cb.s_RLAST <= 4'b0000;
  vif.drv_cb.s_RDATA <= 256'h0002_00000000_00000000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b0010;
  vif.drv_cb.s_RLAST <= 4'b0010;
  vif.drv_cb.s_RID <= 28'h0000_000000;
  @vif.drv_cb;
  vif.drv_cb.s_RVALID <= 4'b0000;
  vif.drv_cb.s_RLAST <= 4'b0000;

endtask
