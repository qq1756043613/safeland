class slv_sequence extends uvm_sequence #(transaction);

  `uvm_object_utils(slv_sequence)

  transaction tr;
  bit out_of_order;
  bit [3:0] err_inject;

  function new(string name = "slv_sequence");
    super.new(name);
  endfunction

  function set_ooo(bit iooo);
    out_of_order = iooo;
  endfunction

  function set_err_inject(bit [3:0] ierr);
    err_inject = ierr;
  endfunction

  function set_special();
    tr.out_of_order = out_of_order;
    tr.err_inject = err_inject;
  endfunction

  virtual task body();

    tr = transaction::type_id::create("tr");
    start_item(tr);
    set_special();
    finish_item(tr);
    `uvm_info("slv_sequence","send one transaction",UVM_LOW);
  endtask

endclass