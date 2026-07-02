class my_base_test extends uvm_test;

  `uvm_component_utils(my_base_test)

  mst_sequence mst_seq;
  slv_sequence slv_seq;
  err_sequence err_seq;
  env env0;


  extern function new(string name="my_base_test",uvm_component parent=null);
  extern task main_phase(uvm_phase phase);
  extern task configure_phase(uvm_phase phase);


endclass

function my_base_test::new(string name="my_base_test",uvm_component parent=null);
  super.new(name,parent);
  `uvm_info("testcase:","-------test_single_cmd_load_mode----------",UVM_LOW);
  env0    = new("env0",this);
  mst_seq = new("mst_seq");
  slv_seq = new("slv_seq");
  err_seq = new("err_seq");
endfunction

task my_base_test::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
  $display("configre in");
  phase.raise_objection(this); //must raise phase
  #100;
  phase.drop_objection(this);
  $display("configre out");
endtask

task my_base_test::main_phase(uvm_phase phase);

  super.main_phase(phase);

endtask