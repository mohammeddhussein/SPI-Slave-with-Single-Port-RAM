module ser #(
    parameter DATA_WIDTH = 8
)
(

    // input ports
    input [DATA_WIDTH-1:0] tx_data,
    input                  tx_valid,
    input                  CLK,
    input                  RST,
    input                  ser_en,

    // output ports
    output                 MISO,
    output                 ser_done

);

reg [7:0] tx_data_reg;
reg [$clog2(DATA_WIDTH)-1:0] counter;

always@(posedge CLK or negedge RST) begin
    if(!RST) begin
        counter <= 0;
        tx_data_reg <= 0;
    end
    else if (tx_valid) begin
        tx_data_reg <= tx_data;
    end
    else if (counter <'b1000 && ser_en) begin
        tx_data_reg <= tx_data_reg << 1;
        counter <= counter + 1;
    end
    else begin
        counter <= 0;
        tx_data_reg <= 0;
    end
end

// Sending bits serially, starting with MSB
assign MISO     = tx_data_reg[7];
assign ser_done = (counter == 3'b111) ? 1 : 0;

endmodule