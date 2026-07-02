class slv_monitor extends uvm_monitor;

  virtual slv_if vif; //connect to simtop/interface
  uvm_analysis_port #(transaction ) ap; // connect to scoreboard

  transaction req; // transaction
  bit [1:0] mst_id;

  `uvm_component_utils( slv_monitor )

  extern function new(string name,uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task main_phase( uvm_phase phase);
  extern        task monitor_bus();
  extern        task debug_info();

endclass

function slv_monitor::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction

function void slv_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  //get virtual interface
  if( !uvm_config_db #(virtual slv_if) :: get(this,"","slv_if",vif))
    `uvm_fatal("slv_monitor","Error in getting interface");

  ap = new("ap",this);
  req = new();
endfunction

task slv_monitor::main_phase(uvm_phase phase);
  super.main_phase(phase);

  while(1) begin
    monitor_bus();
    debug_info();
    ap.write(req);
  end

endtask

task slv_monitor::debug_info();
  `uvm_info("slv_monitor","send a transaction",UVM_LOW);
  `uvm_info("slv_monitor",$sformatf("mst_id = %b",mst_id),UVM_LOW);
endtask

task slv_monitor::monitor_bus();
  while(1) begin
    @vif.drv_cb;

    //W channel monitor
    if(vif.drv_cb.s_AWVALID[0]==1) begin
      req.awcomp = 1;
      case(vif.drv_cb.s_AWID[0][6:5])
        2'b00: begin
          req.m_AWLEN[3:0] = vif.drv_cb.s_AWLEN[0][3:0];
          mst_id = 0;
          `uvm_info("slv_monitor","slave 1 to master 1",UVM_LOW);
        end
        2'b01: begin
          req.m_AWLEN[7:4] = vif.drv_cb.s_AWLEN[0][3:0];
          mst_id = 1;
        end
        2'b10: begin
          req.m_AWLEN[11:8] = vif.drv_cb.s_AWLEN[0][3:0];
          mst_id = 2;
        end
        2'b11: begin
          `uvm_info("slv_monitor","FAIL:impossible m2s situation, a uncreated master!",UVM_LOW);
        end
        default: begin
          `uvm_info("slv_monitor","FAIL default:impossible m2s situation, a uncreated master!",UVM_LOW);
          `uvm_info("slv_monitor",$sformatf("real awid = %b ",vif.drv_cb.s_AWID[0][6:5]),UVM_LOW);
        end
      endcase

      break;
    end else if(vif.drv_cb.s_AWVALID[1]==1) begin
      req.awcomp = 1;
      case(vif.drv_cb.s_AWID[1][6:5])
        2'b00: begin
          req.m_AWLEN[3:0] = vif.drv_cb.s_AWLEN[1][3:0];
          mst_id = 0;
          `uvm_info("slv_monitor","slave 1 to master 1",UVM_LOW);
        end
        2'b01: begin
          req.m_AWLEN[7:4] = vif.drv_cb.s_AWLEN[1][3:0];
          mst_id = 1;
        end
        2'b10: begin
          req.m_AWLEN[11:8] = vif.drv_cb.s_AWLEN[1][3:0];
          mst_id = 2;
        end
        2'b11: begin
          `uvm_info("slv_monitor","FAIL:impossible m2s situation, a uncreated master!",UVM_LOW);
        end
        default: begin
          `uvm_info("slv_monitor","FAIL default:impossible m2s situation, a uncreated master!",UVM_LOW);
          `uvm_info("slv_monitor",$sformatf("real awid = %b ",vif.drv_cb.s_AWID[1][6:5]),UVM_LOW);
        end
      endcase

      break;
    end else if(vif.drv_cb.s_AWVALID[2]==1) begin
      req.awcomp = 1;
      case(vif.drv_cb.s_AWID[2][6:5])
        2'b00: begin
          req.m_AWLEN[3:0] = vif.drv_cb.s_AWLEN[2][3:0];
          mst_id = 0;
          `uvm_info("slv_monitor","slave 1 to master 1",UVM_LOW);
        end
        2'b01: begin
          req.m_AWLEN[7:4] = vif.drv_cb.s_AWLEN[2][3:0];
          mst_id = 1;
        end
        2'b10: begin
          req.m_AWLEN[11:8] = vif.drv_cb.s_AWLEN[2][3:0];
          mst_id = 2;
        end
        2'b11: begin
          `uvm_info("slv_monitor","FAIL:impossible m2s situation, a uncreated master!",UVM_LOW);
        end
        default: begin
          `uvm_info("slv_monitor","FAIL default:impossible m2s situation, a uncreated master!",UVM_LOW);
          `uvm_info("slv_monitor",$sformatf("real awid = %b ",vif.drv_cb.s_AWID[2][6:5]),UVM_LOW);
        end
      endcase

      break;
    end else if(vif.drv_cb.s_AWVALID[3]==1) begin
      req.awcomp = 1;
      case(vif.drv_cb.s_AWID[3][6:5])
        2'b00: begin
          req.m_AWLEN[3:0] = vif.drv_cb.s_AWLEN[3][3:0];
          mst_id = 0;
          `uvm_info("slv_monitor","slave 1 to master 1",UVM_LOW);
        end
        2'b01: begin
          req.m_AWLEN[7:4] = vif.drv_cb.s_AWLEN[3][3:0];
          mst_id = 1;
        end
        2'b10: begin
          req.m_AWLEN[11:8] = vif.drv_cb.s_AWLEN[3][3:0];
          mst_id = 2;
        end
        2'b11: begin
          `uvm_info("slv_monitor","FAIL:impossible m2s situation, a uncreated master!",UVM_LOW);
        end
        default: begin
          `uvm_info("slv_monitor","FAIL default:impossible m2s situation, a uncreated master!",UVM_LOW);
          `uvm_info("slv_monitor",$sformatf("real awid = %b ",vif.drv_cb.s_AWID[3][6:5]),UVM_LOW);
        end
      endcase

      break;
    end else begin
      req.awcomp = 0;
    end

    //R channel monitor
    if(vif.drv_cb.s_ARVALID[0]==1) begin
      //if(vif.drv_cb.s_ARID[6:5]==2'b00)
      req.arcomp = 1;
      case(vif.drv_cb.s_ARID[0][6:5])
        2'b00: begin
          req.m_ARLEN[3:0] = vif.drv_cb.s_ARLEN[0][3:0];
          `uvm_info("slv_monitor","slave 1 to master 1",UVM_LOW);
        end
        2'b01: begin
          req.m_ARLEN[7:4] = vif.drv_cb.s_ARLEN[0][3:0];
        end
        2'b10: begin
          req.m_ARLEN[11:8] = vif.drv_cb.s_ARLEN[0][3:0];
        end
        2'b11: begin
          `uvm_info("slv_monitor","FAIL:impossible m2s situation, a uncreated master!",UVM_LOW);
        end
        default: begin
          `uvm_info("slv_monitor","FAIL default:impossible m2s situation, a uncreated master!",UVM_LOW);
          `uvm_info("slv_monitor",$sformatf("real awid = %b ",vif.drv_cb.s_ARID[0][6:5]),UVM_LOW);
        end
      endcase

      break;
    end else if(vif.drv_cb.s_ARVALID[1]==1) begin
      req.arcomp = 1;
      case(vif.drv_cb.s_ARID[1][6:5])
        2'b00: begin
          req.m_ARLEN[3:0] = vif.drv_cb.s_ARLEN[1][3:0];
          `uvm_info("slv_monitor","slave 1 to master 1",UVM_LOW);
        end
        2'b01: begin
          req.m_ARLEN[7:4] = vif.drv_cb.s_ARLEN[1][3:0];
        end
        2'b10: begin
          req.m_ARLEN[11:8] = vif.drv_cb.s_ARLEN[1][3:0];
        end
        2'b11: begin
          `uvm_info("slv_monitor","FAIL:impossible m2s situation, a uncreated master!",UVM_LOW);
        end
        default: begin
          `uvm_info("slv_monitor","FAIL default:impossible m2s situation, a uncreated master!",UVM_LOW);
          `uvm_info("slv_monitor",$sformatf("real awid = %b ",vif.drv_cb.s_ARID[1][6:5]),UVM_LOW);
        end
      endcase

      break;
    end else if(vif.drv_cb.s_ARVALID[2]==1) begin
      req.arcomp = 1;
      case(vif.drv_cb.s_ARID[2][6:5])
        2'b00: begin
          req.m_ARLEN[3:0] = vif.drv_cb.s_ARLEN[2][3:0];
          `uvm_info("slv_monitor","slave 1 to master 1",UVM_LOW);
        end
        2'b01: begin
          req.m_ARLEN[7:4] = vif.drv_cb.s_ARLEN[2][3:0];
        end
        2'b10: begin
          req.m_ARLEN[11:8] = vif.drv_cb.s_ARLEN[2][3:0];
        end
        2'b11: begin
          `uvm_info("slv_monitor","FAIL:impossible m2s situation, a uncreated master!",UVM_LOW);
        end
        default: begin
          `uvm_info("slv_monitor","FAIL default:impossible m2s situation, a uncreated master!",UVM_LOW);
          `uvm_info("slv_monitor",$sformatf("real awid = %b ",vif.drv_cb.s_ARID[2][6:5]),UVM_LOW);
        end
      endcase

      break;
    end else if(vif.drv_cb.s_ARVALID[3]==1) begin
      req.arcomp = 1;
      case(vif.drv_cb.s_ARID[3][6:5])
        2'b00: begin
          req.m_ARLEN[3:0] = vif.drv_cb.s_ARLEN[3][3:0];
          `uvm_info("slv_monitor","slave 1 to master 1",UVM_LOW);
        end
        2'b01: begin
          req.m_ARLEN[7:4] = vif.drv_cb.s_ARLEN[3][3:0];
        end
        2'b10: begin
          req.m_ARLEN[11:8] = vif.drv_cb.s_ARLEN[3][3:0];
        end
        2'b11: begin
          `uvm_info("slv_monitor","FAIL:impossible m2s situation, a uncreated master!",UVM_LOW);
        end
        default: begin
          `uvm_info("slv_monitor","FAIL default:impossible m2s situation, a uncreated master!",UVM_LOW);
          `uvm_info("slv_monitor",$sformatf("real awid = %b ",vif.drv_cb.s_ARID[3][6:5]),UVM_LOW);
        end
      endcase

      break;
    end else begin
      req.arcomp = 0;
    end

    if(vif.drv_cb.s_WVALID[0]) begin
      req.wcomp = 1;
      `uvm_info("slv_monitor","slv0",UVM_LOW);
      case(mst_id)
        0: begin
          req.m_WDATA[63:0] = vif.drv_cb.s_WDATA[0];
          `uvm_info("slv_monitor","mst0->slv0",UVM_LOW);
        end
        1: begin
          req.m_WDATA[127:64] = vif.drv_cb.s_WDATA[0];
          `uvm_info("slv_monitor","mst1->slv0",UVM_LOW);
        end
        2: begin
          req.m_WDATA[191:128] = vif.drv_cb.s_WDATA[0];
          `uvm_info("slv_monitor","mst2->slv0",UVM_LOW);
        end
      endcase
      break;
      // if(vif.drv_cb.s_WDATA)
    end
    else if(vif.drv_cb.s_WVALID[1]) begin
      `uvm_info("slv_monitor","slv1",UVM_LOW);
      req.wcomp = 1;
      case(mst_id)
        0: begin
          req.m_WDATA[63:0] = vif.drv_cb.s_WDATA[1];
          `uvm_info("slv_monitor","mst0->slv1",UVM_LOW);
          `uvm_info("slv_monitor",$sformatf("vif.drv_cb.s_WDATA = %h",vif.drv_cb.s_WDATA[1]),UVM_LOW);
          `uvm_info("slv_monitor",$sformatf("req.m_WDATA = %h",req.m_WDATA),UVM_LOW);
        end
        1: begin
          req.m_WDATA[127:64] = vif.drv_cb.s_WDATA[1];
          `uvm_info("slv_monitor","mst1->slv1",UVM_LOW);
        end
        2: begin
          req.m_WDATA[191:128] = vif.drv_cb.s_WDATA[1];
          `uvm_info("slv_monitor","mst2->slv1",UVM_LOW);
        end
      endcase
      break;
      // if(vif.drv_cb.s_WDATA)
    end
    else if(vif.drv_cb.s_WVALID[2]) begin
      `uvm_info("slv_monitor","slv2",UVM_LOW);
      req.wcomp = 1;
      case(mst_id)
        0: begin
          req.m_WDATA[63:0] = vif.drv_cb.s_WDATA[2];
        end
        1: begin
          req.m_WDATA[127:64] = vif.drv_cb.s_WDATA[2];
        end
        2: begin
          req.m_WDATA[191:128] = vif.drv_cb.s_WDATA[2];
        end
      endcase
      break;
      // if(vif.drv_cb.s_WDATA)
    end
    else if(vif.drv_cb.s_WVALID[3]) begin
      req.wcomp = 1;
      case(mst_id)
        0: begin
          req.m_WDATA[63:0] = vif.drv_cb.s_WDATA[3];
        end
        1: begin
          req.m_WDATA[127:64] = vif.drv_cb.s_WDATA[3];
        end
        2: begin
          req.m_WDATA[191:128] = vif.drv_cb.s_WDATA[3];
        end
      endcase
      break;
      // if(vif.drv_cb.s_WDATA)
    end
    else begin
      req.wcomp = 0;
      `uvm_info("slv_monitor","no wdata comp",UVM_LOW);
    end

  end
endtask