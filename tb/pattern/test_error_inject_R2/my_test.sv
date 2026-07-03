`include "../pattern_common.svh"

class my_test extends pattern_common_test;

  `uvm_component_utils(my_test)

  function new(string name = "my_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void configure_pattern();
    pattern_slv_err = 4'h2;
  endfunction

  virtual task run_pattern();
    do_read(1, 3, 4);
  endtask

endclass
