`include "uvm_pkg.sv"

`timescale 1ns/1ns

module simtop();
  import uvm_pkg::*;
  `include "uvm_macros.svh"

logic clk,rst_n;
reg [15:0] dbg_cnt;

initial begin
  force simtop.u_axi_voter.s_AWADDR_o = 0;

  clk = 0;
  rst_n = 0;
  #80ns;
  release simtop.u_axi_voter.s_AWADDR_o;
  rst_n = 1;
end

always #50 clk = ~clk;

mst_if mst_sig(clk,rst_n);
slv_if slv_sig(clk,rst_n);
always @(posedge clk) begin
  //mst_sig.m_RREADY <= mst_sig.m_RVALID;
  mst_sig.m_RREADY <= 3'b111;
  slv_sig.s_ARREADY <= 4'b1111;
end

axi_voter u_axi_voter(
  .ACLK_i(clk),
  .ARESETn_i(rst_n),
  // -- To Master (slave interface of the interconnect)
  // ---- Write address channel
  .m_AWID_i(mst_sig.m_AWID),
  .m_AWADDR_i(mst_sig.m_AWADDR),
  .m_AWBURST_i(mst_sig.m_AWBURST),
  .m_AWLEN_i(mst_sig.m_AWLEN),
  .m_AWSIZE_i(mst_sig.m_AWSIZE),
  .m_AWPROT_i(mst_sig.m_AWPROT),
  .m_AWVALID_i(mst_sig.m_AWVALID),
  // ---- Write data channel
  .m_WDATA_i(mst_sig.m_WDATA),
  .m_WLAST_i(mst_sig.m_WLAST),
  .m_WVALID_i(mst_sig.m_WVALID),
  // ---- Write response channel
  .m_BREADY_i(mst_sig.m_BREADY),
  // ---- Read address channel
  .m_ARID_i(mst_sig.m_ARID),
  .m_ARADDR_i(mst_sig.m_ARADDR),
  .m_ARBURST_i(mst_sig.m_ARBURST),
  .m_ARLEN_i(mst_sig.m_ARLEN),
  .m_ARSIZE_i(mst_sig.m_ARSIZE),
  .m_ARPROT_i(mst_sig.m_ARPROT),
  .m_ARVALID_i(mst_sig.m_ARVALID),
  // ---- Read data channel
  .m_RREADY_i(mst_sig.m_RREADY),
  .m_AWREADY_o(mst_sig.m_AWREADY),
  // ---- Write data channel (master)
  .m_WREADY_o(mst_sig.m_WREADY),
  // ---- Write response channel (master)
  .m_BID_o(mst_sig.m_BID),
  .m_BRESP_o(mst_sig.m_BRESP),
  .m_BVALID_o(mst_sig.m_BVALID),
  // ---- Read address channel (master)
  .m_ARREADY_o(mst_sig.m_ARREADY),
  // ---- Read data channel (master)
  .m_RID_o(mst_sig.m_RID),
  .m_RDATA_o(mst_sig.m_RDATA),
  .m_RRESP_o(mst_sig.m_RRESP),
  .m_RLAST_o(mst_sig.m_RLAST),
  .m_RVALID_o(mst_sig.m_RVALID),
  // ---- Write data channel (master)
  .s_AWREADY_i(slv_sig.s_AWREADY),
  .s_WREADY_i(slv_sig.s_WREADY),

  .s_BID_i(slv_sig.s_BID),
  .s_BRESP_i(slv_sig.s_BRESP),
  .s_BVALID_i(slv_sig.s_BVALID),

  .s_ARREADY_i(slv_sig.s_ARREADY),

  .s_RID_i(slv_sig.s_RID),
  .s_RDATA_i(slv_sig.s_RDATA),
  .s_RRESP_i(slv_sig.s_RRESP),
  .s_RLAST_i(slv_sig.s_RLAST),
  .s_RVALID_i(slv_sig.s_RVALID),
  .s_AWID_o(slv_sig.s_AWID),
  .s_AWADDR_o(slv_sig.s_AWADDR),

  .s_AWBURST_o(slv_sig.s_AWBURST),
  .s_AWLEN_o(slv_sig.s_AWLEN),
  .s_AWSIZE_o(slv_sig.s_AWSIZE),
  .s_AWVALID_o(slv_sig.s_AWVALID),

  .s_WDATA_o(slv_sig.s_WDATA),
  .s_WLAST_o(slv_sig.s_WLAST),
  .s_WVALID_o(slv_sig.s_WVALID),

  .s_BREADY_o(slv_sig.s_BREADY),

  .s_ARID_o(slv_sig.s_ARID),
  .s_ARADDR_o(slv_sig.s_ARADDR),
  .s_ARBURST_o(slv_sig.s_ARBURST),
  .s_ARLEN_o(slv_sig.s_ARLEN),
  .s_ARSIZE_o(slv_sig.s_ARSIZE),
  .s_ARVALID_o(slv_sig.s_ARVALID),

  .s_RREADY_o(slv_sig.s_RREADY),
  .WSAFE_o(mst_sig.WSAFE),
  .RSAFE_o(mst_sig.RSAFE)
);

initial begin
  uvm_config_db#(virtual mst_if)::set(null,"uvm_test_top.env0.mst_agent0.drv","mst_if",mst_sig);
  uvm_config_db#(virtual mst_if)::set(null,"uvm_test_top.env0.err_agent0.drv","mst_if",mst_sig);
  uvm_config_db#(virtual mst_if)::set(null,"uvm_test_top.env0.mst_agent0.mon","mst_if",mst_sig);
  uvm_config_db#(virtual slv_if)::set(null,"uvm_test_top.env0.slv_agent0.mon","slv_if",slv_sig);
  uvm_config_db#(virtual slv_if)::set(null,"uvm_test_top.env0.slv_agent0.drv","slv_if",slv_sig);

  mst_sig.m_AWID = 0;
  mst_sig.m_AWVALID = 0;
  mst_sig.m_AWADDR = 0;
  mst_sig.m_AWBURST = 0;
  mst_sig.m_AWLEN = 0;
  mst_sig.m_AWSIZE = 0;

  mst_sig.m_ARID = 0;
  mst_sig.m_ARVALID = 0;
  mst_sig.m_ARADDR = 0;
  mst_sig.m_ARBURST = 0;
  mst_sig.m_ARLEN = 0;
  mst_sig.m_ARSIZE = 0;

  slv_sig.s_RDATA = 0;
  slv_sig.s_RRESP = 0;
  slv_sig.s_RLAST = 0;
  slv_sig.s_RID = 0;
  //mst_sig.m_AWADDR = 0;
  slv_sig.s_AWREADY = 0;
  mst_sig.m_WLAST = 0;
  //slv_sig.s_AWSIZE = 0;
  //slv_sig.s_AWLEN = 0;
  run_test();
  #100ns;
end

initial begin
  //#10;
  //if(outstanding ==1) begin
  //    slv_sig.s_ARREADY = 0;
  //    #2700;
  //    slv_sig.s_ARREADY = 4'b1111;
  //end else begin
  //    slv_sig.s_ARREADY = 4'b1111;
  //end
end

initial begin
  $fsdbDumpfile("simtop.fsdb");
  $fsdbDumpvars;
  $fsdbDumpSVA;
end

endmodule