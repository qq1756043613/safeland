module edgedet
#(
    parameter RISING_EDGE = 1
)
(
    input        clk,
    input        i,
    input        en,
    output reg   o,
    input        rst_n
);

reg prev_i;

always @(posedge clk) begin
    if(~rst_n)
        prev_i <= 1'b0;
    else if(en)
        prev_i <= i;
end

generate
    if(RISING_EDGE) begin
        assign o = ~prev_i & i;
    end
    else begin
        assign o = prev_i & ~i;
    end
endgenerate

endmodule
