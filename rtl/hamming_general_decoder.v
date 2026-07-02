module hamming_general_decoder#(
    parameter DATA_WIDTH
)(
    input  [DATA_WIDTH+7:0] received_data  ,
    output reg [1:0]        wrong          ,
    output reg [6:0]        syn,
    output reg [DATA_WIDTH-1:0] decoded_data
);
//VCS coverage off
integer i;
reg [DATA_WIDTH + 7:0] data;
wire [6:0] syndrome;
wire p1 = ^(received_data&128'haaaaaaaa_aaaaaaaa_aaaaaaaa_aaaaaaaa);
wire p2 = ^(received_data&128'hcccccccc_cccccccc_cccccccc_cccccccc);
wire p3 = ^(received_data&128'hf0f0f0f0_f0f0f0f0_f0f0f0f0_f0f0f0f0);
wire p4 = ^(received_data&128'hff00ff00_ff00ff00_ff00ff00_ff00ff00);
wire p5 = ^(received_data&128'hffff0000_ffff0000_ffff0000_ffff0000);
wire p6 = ^(received_data&128'hffffffff_00000000_ffffffff_00000000);
wire p7 = ^(received_data&128'hffffffff_00000000_ffffffff_00000000);
wire p0 = ^(received_data&128'hffffffff_ffffffff_ffffffff_fffffffe);

assign syndrome = {p7,p6,p5,p4,p3,p2,p1};
always @(*) begin
    syn = syndrome;
    data = received_data;
    if(syndrome == 0) begin
        decoded_data[0]       = data[3]   ;
        decoded_data[3:1]     = data[7:5]   ;
        decoded_data[10:4]    = data[15:9]  ;
        decoded_data[25:11]   = data[31:17] ;
        decoded_data[56:26]   = data[63:33] ;
        decoded_data[DATA_WIDTH-1:57] = data[DATA_WIDTH+7:65];
        wrong = 0;
    end else if((syndrome != 0)&&(p0^received_data[0])==1) begin
        for(i = 0;i<DATA_WIDTH+8;i=i+1)begin
            if (i==syndrome)
                data[i] = ~received_data[i];
        end
        decoded_data[0]       = data[3]   ;
        decoded_data[3:1]     = data[7:5]   ;
        decoded_data[10:4]    = data[15:9]  ;
        decoded_data[25:11]   = data[31:17] ;
        decoded_data[56:26]   = data[63:33] ;
        decoded_data[DATA_WIDTH-1:57] = data[DATA_WIDTH+7:65];
        wrong = 1;
    end else if((syndrome != 0)&&(p0^received_data[0])==0) begin
        wrong = 2;
        decoded_data[0]       = data[3]   ;
        decoded_data[3:1]     = data[7:5]   ;
        decoded_data[10:4]    = data[15:9]  ;
        decoded_data[25:11]   = data[31:17] ;
        decoded_data[56:26]   = data[63:33] ;
        decoded_data[DATA_WIDTH-1:57] = data[DATA_WIDTH+7:65];
    end else begin
        wrong = 3;
        decoded_data[0]       = data[3]   ;
        decoded_data[3:1]     = data[7:5]   ;
        decoded_data[10:4]    = data[15:9]  ;
        decoded_data[25:11]   = data[31:17] ;
        decoded_data[56:26]   = data[63:33] ;
        decoded_data[DATA_WIDTH-1:57] = data[DATA_WIDTH+7:65];
    end
end
//VCS coverage on
endmodule