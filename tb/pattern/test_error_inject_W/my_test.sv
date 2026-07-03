`include "../pattern_common.svh"

class my_test extends pattern_common_test;

  `uvm_component_utils(my_test)

  function new(string name = "my_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_pattern();
    do_write(0, 3, 4, 0, 0, 4'h1);
  endtask

endclass
