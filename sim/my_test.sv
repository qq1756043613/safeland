class my_test extends my_base_test;
  `uvm_component_utils(my_test)
  extern function new(string name="my_test",uvm_component parent=null);
  extern task main_phase(uvm_phase phase);
endclass

function my_test::new(string name="my_test",uvm_component parent=null);
  super.new(name,parent);
endfunction

task my_test::main_phase(uvm_phase phase);
  bit [8:0] awsize;
  bit [11:0] awlen;
  bit [8:0] awprot;
  awsize = {3'b0,3'b0,3'b0};
  awlen  = {4'b0,4'b0,4'b0};
  awprot = {3'b0,3'b0,3'b0};

  phase.raise_objection(this);

  super.main_phase(phase);
  slv_seq.set_ooo(0);
  slv_seq.start(env0.slv_agent0.sqr);

  repeat (64) begin
    /*set AW channel*/
    mst_seq.set_awmode(
      `AW,                           // imode
      1,                             // iawflag
      96'h4000000a,                  // iawaddr
      3'b1,                          // iawvalid
      6'b1,                          // iawburst
      15'b1,                         // iawid
      awsize,                        // iawsize
      awlen,                         // iawlen
      awprot,                        // iawprot
      1,                             // iwflag
      3'b0,                          // iwvalid
      192'h0,                        // iwdata
      3'b1                           // iwlast
    );
    mst_seq.start(env0.mst_agent0.sqr);

    mst_seq.set_wmode(
      `W,                            // imode
      1,                             // iawflag
      96'h4000000a,                  // iawaddr
      3'b1,                          // iawvalid
      6'b1,                          // iawburst
      15'b1,                         // iawid
      awsize,                        // iawsize
      awlen,                         // iawlen
      awprot,                        // iawprot
      1,                             // iwflag
      3'b1,                          // iwvalid
      192'h0,                        // iwdata
      3'b1                           // iwlast
    );
    mst_seq.set_err_inject(4'b1);
    mst_seq.start(env0.mst_agent0.sqr);
    #1000;
  end
  #5000;

  repeat (64) begin
    /*set AW channel*/
    mst_seq.set_awmode(
      `AW,                           // imode
      1,                             // iawflag
      96'h4000000a4000000a,          // iawaddr
      3'b10,                         // iawvalid
      6'b100,                        // iawburst
      15'b100000,                    // iawid
      awsize,                        // iawsize
      awlen,                         // iawlen
      awprot,                        // iawprot
      1,                             // iwflag
      3'b0,                          // iwvalid
      192'h0,                        // iwdata
      3'b10                          // iwlast
    );
    mst_seq.start(env0.mst_agent0.sqr);

    mst_seq.set_wmode(
      `W,                            // imode
      1,                             // iawflag
      96'h4000000a4000000a,          // iawaddr
      3'b10,                         // iawvalid
      6'b100,                        // iawburst
      15'b100000,                    // iawid
      awsize,                        // iawsize
      awlen,                         // iawlen
      awprot,                        // iawprot
      1,                             // iwflag
      3'b10,                         // iwvalid
      192'h0,                        // iwdata
      3'b10                          // iwlast
    );
    mst_seq.set_err_inject(4'b1);
    mst_seq.start(env0.mst_agent0.sqr);
    #1000;
  end
  #3000;

  `uvm_info("my_base_test","----------------gen transaction----------------",UVM_LOW);
  phase.drop_objection(this);
endtask