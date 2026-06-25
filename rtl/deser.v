module deser #(
    parameter BUS_WIDTH = 10
) 
(
    // input ports
    input wire                  MOSI,
    input wire                  CLK,
    input wire                  RST,
    input wire                  SS_n,
    input wire                  deser_en,

    // output ports
    output reg [BUS_WIDTH-1:0]  rx_data,
    output wire                 rx_valid
);

reg [$clog2(BUS_WIDTH)-1:0] counter;

always@(posedge CLK or negedge RST) begin
    if(!RST) begin
        rx_data <=  'b0;
        counter <=  'b0;
    end
    else if(SS_n==0 && (counter < BUS_WIDTH) && deser_en) begin
        rx_data[BUS_WIDTH-counter-1] <= MOSI;
        counter <= counter + 'b1;
    end
    else begin
        counter  <= 'b0;
    end
end

assign rx_valid = (counter == 'b1010) ? 'b1 : 'b0;

endmodule