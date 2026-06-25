module SPI_TOP (

    // input declaration
    input wire MOSI,
    input wire SS_n,
    input wire CLK,
    input wire RST,

    // output declaration
    output wire MISO
    
);

// Internal wires
wire [9:0] rx_data;
wire rx_valid;
wire [7:0] tx_data;
wire tx_valid;
wire ser_en;
wire deser_en;
wire ser_done;

RAM u_RAM (
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .CLK(CLK),
    .RST(RST),

    .tx_data(tx_data),
    .tx_valid(tx_valid)
);

ser u_ser (
    .tx_data(tx_data),
    .tx_valid(tx_valid),
    .CLK(CLK),
    .RST(RST),
    .ser_en(ser_en),

    .MISO(MISO),
    .ser_done(ser_done)
);

deser u_deser (
    .MOSI(MOSI),
    .CLK(CLK),
    .RST(RST),
    .SS_n(SS_n),
    .deser_en(deser_en),

    .rx_data(rx_data),
    .rx_valid(rx_valid)
);

FSM u_FSM (
    .MOSI(MOSI),
    .SS_n(SS_n),
    .CLK(CLK),
    .RST(RST),
    .rx_valid(rx_valid),
    .tx_valid(tx_valid),
    .ser_done(ser_done),

    .deser_en(deser_en),
    .ser_en(ser_en)
);

endmodule