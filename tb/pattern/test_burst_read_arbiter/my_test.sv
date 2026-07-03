`include "../pattern_common.svh"

class my_test extends pattern_common_test;

  `uvm_component_utils(my_test)

  function new(string name = "my_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_pattern();
    do_read(0, 0, 1, 0, 0);
    do_read(1, 0, 1, 1, 64);
    do_read(2, 0, 1, 2, 128);
  endtask

endclass
