`include "../pattern_common.svh"

class my_test extends pattern_common_test;

  `uvm_component_utils(my_test)

  function new(string name = "my_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void configure_pattern();
    pattern_err_driver = 4'hf;
    pattern_done_delay = 12000;
  endfunction

  virtual task run_pattern();
    do_write(0, 3, 4);
  endtask

endclass
