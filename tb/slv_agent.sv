class slv_agent extends uvm_agent;
  slv_sequencer  sqr;
  slv_driver     drv;
  slv_monitor    mon;

  uvm_analysis_port #(transaction ) ap; // connect to scoreboard

  extern function new( string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

  `uvm_component_utils_begin( slv_agent )
    `uvm_field_object( sqr, UVM_ALL_ON )
    `uvm_field_object( mon, UVM_ALL_ON )
    `uvm_field_object( drv, UVM_ALL_ON )
  `uvm_component_utils_end


endclass

function slv_agent::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction

function void slv_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  sqr = slv_sequencer::type_id::create("sqr",this);
  mon = slv_monitor::type_id::create("mon",this);
  drv = slv_driver::type_id::create("drv",this);
endfunction

function void slv_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  drv.seq_item_port.connect(sqr.seq_item_export);
  this.ap = mon.ap;
  `uvm_info("slv_agent","connect ok",UVM_LOW);

endfunction