class pattern_common_test extends my_base_test;

  bit       pattern_out_of_order;
  bit [3:0] pattern_slv_err;
  bit [3:0] pattern_err_driver;
  int       pattern_done_delay;

  function new(string name = "pattern_common_test", uvm_component parent = null);
    super.new(name, parent);
    pattern_out_of_order = 0;
    pattern_slv_err      = 4'h0;
    pattern_err_driver   = 4'h0;
    pattern_done_delay   = 5000;
  endfunction

  virtual function void configure_pattern();
  endfunction

  virtual task run_pattern();
  endtask

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this);

    configure_pattern();
    slv_seq.set_ooo(pattern_out_of_order);
    slv_seq.set_err_inject(pattern_slv_err);
    slv_seq.start(env0.slv_agent0.sqr);

    if(pattern_err_driver != 4'h0) begin
      err_seq.set_err_mode(pattern_err_driver);
      err_seq.start(env0.err_agent0.sqr);
    end

    #50;
    run_pattern();
    #(pattern_done_delay);
    phase.drop_objection(this);
  endtask

  function bit [2:0] mst_valid(input int mst);
    bit [2:0] valid;
    valid = 3'b001;
    return (valid << mst);
  endfunction

  function bit [95:0] addr_pack(input int mst, input int slv, input int offset = 0);
    bit [95:0] addr;
    bit [31:0] one_addr;

    case(slv)
      0: one_addr = 32'h0000_1000 + offset;
      1: one_addr = 32'h4000_1000 + offset;
      2: one_addr = 32'h8000_1000 + offset;
      default: one_addr = 32'hc000_1000 + offset;
    endcase

    addr = '0;
    case(mst)
      0: addr[31:0]  = one_addr;
      1: addr[63:32] = one_addr;
      default: addr[95:64] = one_addr;
    endcase
    return addr;
  endfunction

  function bit [14:0] id_pack(input int mst, input int id);
    bit [14:0] ids;
    ids = '0;
    case(mst)
      0: ids[4:0]   = id[4:0];
      1: ids[9:5]   = id[4:0];
      default: ids[14:10] = id[4:0];
    endcase
    return ids;
  endfunction

  function bit [5:0] burst_pack(input int mst);
    bit [5:0] burst;
    burst = '0;
    case(mst)
      0: burst[1:0] = 2'b01;
      1: burst[3:2] = 2'b01;
      default: burst[5:4] = 2'b01;
    endcase
    return burst;
  endfunction

  function bit [8:0] size_pack(input int mst);
    bit [8:0] size;
    size = '0;
    case(mst)
      0: size[2:0] = 3'b011;
      1: size[5:3] = 3'b011;
      default: size[8:6] = 3'b011;
    endcase
    return size;
  endfunction

  function bit [11:0] len_pack(input int mst, input int beats);
    bit [11:0] len;
    bit [3:0]  axi_len;

    axi_len = (beats > 0) ? beats - 1 : 0;
    len = '0;
    case(mst)
      0: len[3:0]   = axi_len;
      1: len[7:4]   = axi_len;
      default: len[11:8] = axi_len;
    endcase
    return len;
  endfunction

  function bit [8:0] prot_pack(input int mst);
    prot_pack = '0;
  endfunction

  function bit [191:0] data_pack(input int mst, input int seed);
    bit [191:0] data;
    bit [63:0]  one_data;

    one_data = 64'h5a5a_0000_0000_0000 | seed[31:0];
    data = '0;
    case(mst)
      0: data[63:0]    = one_data;
      1: data[127:64]  = one_data;
      default: data[191:128] = one_data;
    endcase
    return data;
  endfunction

  task automatic do_write(
    input int mst,
    input int slv,
    input int beats,
    input int id = 0,
    input int offset = 0,
    input bit [3:0] err = 4'h0
  );
    mst_seq.set_err_inject(err);
    mst_seq.set_awmode(
      (`AW | `W),
      1'b1,
      addr_pack(mst, slv, offset),
      mst_valid(mst),
      burst_pack(mst),
      id_pack(mst, id),
      size_pack(mst),
      len_pack(mst, beats),
      prot_pack(mst),
      1'b1,
      mst_valid(mst),
      data_pack(mst, offset + id),
      mst_valid(mst)
    );
    mst_seq.start(env0.mst_agent0.sqr);
    #100;
  endtask

  task automatic do_write_aw(
    input int mst,
    input int slv,
    input int beats,
    input int id = 0,
    input int offset = 0
  );
    mst_seq.set_err_inject(4'h0);
    mst_seq.set_awmode(
      `AW,
      1'b1,
      addr_pack(mst, slv, offset),
      mst_valid(mst),
      burst_pack(mst),
      id_pack(mst, id),
      size_pack(mst),
      len_pack(mst, beats),
      prot_pack(mst),
      1'b0,
      3'b000,
      '0,
      3'b000
    );
    mst_seq.start(env0.mst_agent0.sqr);
    #50;
  endtask

  task automatic do_write_w(
    input int mst,
    input int beats,
    input int id = 0,
    input int offset = 0
  );
    mst_seq.set_err_inject(4'h0);
    mst_seq.set_wmode(
      `W,
      1'b0,
      '0,
      3'b000,
      '0,
      id_pack(mst, id),
      size_pack(mst),
      len_pack(mst, beats),
      prot_pack(mst),
      1'b1,
      mst_valid(mst),
      data_pack(mst, offset + id),
      mst_valid(mst)
    );
    mst_seq.start(env0.mst_agent0.sqr);
    #100;
  endtask

  task automatic do_read(
    input int mst,
    input int slv,
    input int beats,
    input int id = 0,
    input int offset = 0
  );
    mst_seq.set_err_inject(4'h0);
    mst_seq.set_armode(
      `AR,
      1'b1,
      addr_pack(mst, slv, offset),
      mst_valid(mst),
      burst_pack(mst),
      id_pack(mst, id),
      size_pack(mst),
      len_pack(mst, beats),
      prot_pack(mst)
    );
    mst_seq.start(env0.mst_agent0.sqr);
    #100;
  endtask

  task automatic do_write_outstanding(
    input int mst,
    input int slv,
    input int beats,
    input int count
  );
    for(int i = 0; i < count; i++) begin
      do_write_aw(mst, slv, beats, i, i * 64);
    end
    for(int i = 0; i < count; i++) begin
      do_write_w(mst, beats, i, i * 64);
    end
  endtask

  task automatic do_read_outstanding(
    input int mst,
    input int slv,
    input int beats,
    input int count
  );
    for(int i = 0; i < count; i++) begin
      do_read(mst, slv, beats, i, i * 64);
    end
  endtask

  function int rand_beats();
    case($urandom_range(0, 4))
      0: rand_beats = 1;
      1: rand_beats = 2;
      2: rand_beats = 4;
      3: rand_beats = 8;
      default: rand_beats = 16;
    endcase
  endfunction

  task automatic do_random_writes(input int count);
    for(int i = 0; i < count; i++) begin
      do_write($urandom_range(0, 2), $urandom_range(0, 3), rand_beats(), i, i * 128);
    end
  endtask

  task automatic do_random_reads(input int count);
    for(int i = 0; i < count; i++) begin
      do_read($urandom_range(0, 2), $urandom_range(0, 3), rand_beats(), i, i * 128);
    end
  endtask

endclass
