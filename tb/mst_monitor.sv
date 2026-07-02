class mst_monitor extends uvm_monitor;

  virtual mst_if vif; //connect to simtop/interface
  uvm_analysis_port #(transaction ) ap; // connect to scoreboard

  transaction req; // transaction


  `uvm_component_utils( mst_monitor )


  extern function new(string name,uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern        task monitor_bus();
  extern        task debug_info();

endclass

function mst_monitor::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction

function void mst_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  //get virtual interface
  if( !uvm_config_db #(virtual mst_if) :: get(this,"","mst_if",vif))
    `uvm_fatal("mst_monitor","Error in getting interface");

  ap = new("ap",this);
  req = new();
endfunction

task mst_monitor::main_phase(uvm_phase phase);
  super.main_phase(phase);

  //while(1) begin
  //end

endtask

task mst_monitor::debug_info();
  `uvm_info("mst_driver","send a transaction",UVM_LOW);
endtask

task mst_monitor::monitor_bus();
endtask