`uvm_analysis_imp_decl(_slv_mon_ch)
`uvm_analysis_imp_decl(_mst_drv_ch)

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp_slv_mon_ch #(transaction,scoreboard) slv_mon_ch;
  uvm_analysis_imp_mst_drv_ch #(transaction,scoreboard) mst_drv_ch;

  uvm_tlm_analysis_fifo #(transaction) slv_fifo;
  uvm_tlm_analysis_fifo #(transaction) mst_fifo;

  function write_slv_mon_ch(transaction tr);
    slv_fifo.write(tr);
    `uvm_info(get_type_name(),"write tr to slv",UVM_LOW)
    debug_info(tr);
  endfunction

  function write_mst_drv_ch(transaction tr);
    mst_fifo.write(tr);
    `uvm_info(get_type_name(),"write tr to mst",UVM_LOW)
    debug_info(tr);
  endfunction

  extern function new(string name, uvm_component parent);
  extern task compare();
  extern task run_phase(uvm_phase phase);
  extern function void debug_info( transaction tr );

endclass

function scoreboard::new(string name,uvm_component parent);
  super.new(name,parent);
  slv_mon_ch = new("slv_mon_ch",this);
  mst_drv_ch = new("mst_drv_ch",this);

  slv_fifo = new("slv_fifo",this);
  mst_fifo = new("mst_fifo",this);

endfunction

task scoreboard::run_phase(uvm_phase phase);
  compare();
endtask

task scoreboard::compare();
  transaction tr1;
  transaction tr2;

  while(1) begin
    mst_fifo.get(tr1);
    slv_fifo.get(tr2);
    `uvm_info("scoreboard","ready to compare",UVM_LOW);
    //debug_info();
    if(tr2.awcomp==1) begin
      if((tr1.m_AWLEN & {{4{tr1.m_AWVALID[2]}},{4{tr1.m_AWVALID[1]}},{4{tr1.m_AWVALID[0]}}}) == (tr2.m_AWLEN & {{4{tr1.m_AWVALID[2]}},{4{tr1.m_AWVALID[1]}},{4{tr1.m_AWVALID[0]}}})) begin
        `uvm_info("scoreboard","compare PASS",UVM_LOW);
      end else begin
        `uvm_info("scoreboard","compare FAIL",UVM_LOW);
      end
    end
    if(tr2.arcomp==1) begin
      if((tr1.m_ARLEN & {{4{tr1.m_ARVALID[2]}},{4{tr1.m_ARVALID[1]}},{4{tr1.m_ARVALID[0]}}}) == (tr2.m_ARLEN & {{4{tr1.m_ARVALID[2]}},{4{tr1.m_ARVALID[1]}},{4{tr1.m_ARVALID[0]}}})) begin
        `uvm_info("scoreboard","compare PASS",UVM_LOW);
      end else begin
        `uvm_info("scoreboard","compare FAIL",UVM_LOW);
        `uvm_info("scoreboard",$sformatf("tr1.m_ARLEN = %b",tr1.m_ARLEN),UVM_LOW);
        `uvm_info("scoreboard",$sformatf("tr2.m_ARLEN = %b",tr2.m_ARLEN),UVM_LOW);
      end
    end
    if(tr2.wcomp==1) begin
      if((tr1.m_WDATA & {{64{tr1.m_WVALID[2]}},{64{tr1.m_WVALID[1]}},{64{tr1.m_WVALID[0]}}}) == (tr2.m_WDATA & {{64{tr1.m_WVALID[2]}},{64{tr1.m_WVALID[1]}},{64{tr1.m_WVALID[0]}}})) begin
        `uvm_info("scoreboard","compare PASS",UVM_LOW);
      end else begin
        `uvm_info("scoreboard","compare FAIL",UVM_LOW);
        `uvm_info("scoreboard",$sformatf("tr1.m_WDATA = %b",tr1.m_WDATA),UVM_LOW);
        `uvm_info("scoreboard",$sformatf("tr2.m_WDATA = %b",tr2.m_WDATA),UVM_LOW);
      end
    end
  end
endtask

function void scoreboard::debug_info( transaction tr );
  `uvm_info("scoreboard","send a transaction",UVM_LOW);
  `uvm_info("scoreboard",$sformatf("awlen = %h",tr.m_AWLEN),UVM_LOW);
endfunction