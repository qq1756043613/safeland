`include "../pattern_common.svh"

class my_test extends pattern_common_test;

  `uvm_component_utils(my_test)

  function new(string name = "my_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_pattern();
    do_write_outstanding(0, 3, 1, 2);
  endtask

endclass
