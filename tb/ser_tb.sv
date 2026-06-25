`timescale 1ns/1ps

module ser_tb;

parameter CLK_PER=10;

reg [7:0] tx_data;
reg tx_valid;
reg CLK;
reg RST;
// reg ser_en;

wire MISO;
wire ser_done;

initial begin
    tx_data=8'b10110111;
    // ser_en=0;
    tx_valid=0;
    CLK=0;
    RST=0;
    #CLK_PER;
    RST=1;
    // ser_en=1;
    tx_valid=1;
    #CLK_PER;
    tx_valid=0;
    #CLK_PER;
    #50;

    $stop;

end

always#(CLK_PER/2) CLK=~CLK;

ser ser(.*);

endmodule