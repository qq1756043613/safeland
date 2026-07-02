class err_agent extends uvm_agent;
  err_sequencer sqr;
  err_driver    drv;


  extern function new( string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

  `uvm_component_utils_begin( err_agent )
    `uvm_field_object( sqr, UVM_ALL_ON )
    `uvm_field_object( drv, UVM_ALL_ON )
  `uvm_component_utils_end


endclass

function err_agent::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction

function void err_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  sqr = err_sequencer::type_id::create("sqr",this);
  drv = err_driver::type_id::create("drv",this);
endfunction

function void err_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  drv.seq_item_port.connect(sqr.seq_item_export);
  `uvm_info("err_agent","connect ok",UVM_LOW);

endfunction