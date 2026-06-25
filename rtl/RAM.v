module RAM #(
    parameter MEM_DEPTH = 256,
              ADDR_SIZE = 8
)
(

    // input declaration
    input [9:0]       rx_data,
    input             rx_valid,
    input             CLK,
    input             RST,

    // output declaration
    output reg [7:0]  tx_data,
    output reg        tx_valid
);

reg [7:0] mem [MEM_DEPTH-1:0];
reg [ADDR_SIZE-1:0] addr_reg;
integer i;


// Sequential Block For Writing
always@(posedge CLK or negedge RST) begin
    if(!RST) begin
        addr_reg <= 0;
        for (i=0;i<MEM_DEPTH;i=i+1) begin
            mem[i] <= 0;
        end
    end
    else if((rx_data[9:8]=='b00 || rx_data[9:8]=='b10) && rx_valid) begin
        addr_reg <= rx_data[7:0];
    end
    else if(rx_data[9:8]=='b01 && rx_valid) begin
        mem[addr_reg] <= rx_data[7:0];
    end
end

// Combinational Block For Reading
always@(*) begin
    if(rx_data[9:8]=='b11 && rx_valid) begin
        tx_data  = mem[addr_reg];
        tx_valid = 1;
    end
    else begin
        tx_data  = 0;
        tx_valid = 0;
    end
end

endmodule