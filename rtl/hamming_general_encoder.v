module hamming_general_encoder#(
    parameter DATA_WIDTH
)(
    input [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH+7:0] encoded_data
);
reg [DATA_WIDTH+7:0] encoded_data1;

always@(*) begin
    encoded_data1               = 128'b0;
    encoded_data1[3]            = data_in[0];
    encoded_data1[7:5]          = data_in[3:1];
    encoded_data1[15:9]         = data_in[10:4];
    encoded_data1[31:17]        = data_in[25:11];
    encoded_data1[63:33]        = data_in[56:26];
    encoded_data1[DATA_WIDTH+7:65] = data_in[DATA_WIDTH-1:57];
    encoded_data1[1]            = ^(encoded_data1&128'haaaaaaaa_aaaaaaaa_aaaaaaaa_aaaaaaaa);
    encoded_data1[2]            = ^(encoded_data1&128'hcccccccc_cccccccc_cccccccc_cccccccc);
    encoded_data1[4]            = ^(encoded_data1&128'hf0f0f0f0_f0f0f0f0_f0f0f0f0_f0f0f0f0);
    encoded_data1[8]            = ^(encoded_data1&128'hff00ff00_ff00ff00_ff00ff00_ff00ff00);
    encoded_data1[16]           = ^(encoded_data1&128'hffff0000_ffff0000_ffff0000_ffff0000);
    encoded_data1[32]           = ^(encoded_data1&128'hffffffff_00000000_ffffffff_00000000);
    encoded_data1[64]           = ^(encoded_data1&128'hffffffff_ffffffff_00000000_00000000);
    encoded_data1[0]            = ^encoded_data1;
end

assign encoded_data = encoded_data1;
endmodule