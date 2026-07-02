class err_sequence extends uvm_sequence #(transaction);

  `uvm_object_utils(err_sequence)

  transaction tr;
  bit [3:0] err_inject;

  function new(string name = "err_sequence");
    super.new(name);
  endfunction

  function set_err_mode(bit [3:0] ierr);
    err_inject = ierr;
  endfunction

  function set_special();
    tr.err_inject = err_inject;
  endfunction

  virtual task body();

    tr = transaction::type_id::create("tr");
    start_item(tr);

      set_special();
    finish_item(tr);
    `uvm_info("err_sequence","send one transaction",UVM_LOW);
  endtask

endclass