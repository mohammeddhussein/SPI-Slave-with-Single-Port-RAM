`timescale 1ns/1ps

module SPI_TB ();


/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////

parameter  CLK_PER     = 10;
localparam WRITE       = 1'b0;
localparam READ        = 1'b1;
localparam WR_ADDR     = 2'b00;
localparam WR_DATA     = 2'b01;
localparam RD_ADDR     = 2'b10;
localparam RD_DATA     = 2'b11;

/////////////////////////////////////////////////////////
//////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////

logic MOSI;
logic SS_n;
logic CLK ;
logic RST ;

logic MISO;

logic [7:0] DATA_SENT = $random;

////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////

initial begin

    // System Functions
    $dumpfile("SPI_DUMP.vcd") ;       
    $dumpvars; 

    initialize();

    reset();
    
    // $readmemb("ram.dat", u_DUT.u_RAM.mem);  // BIN File
    $readmemh("ram.hex", u_DUT.u_RAM.mem);  // HEX File

    ////////////////// TEST CASE 1 //////////////////

    repeat (15) write_and_read($urandom_range(0,255),$urandom_range(0,255));

    ///////////////// TEST CASE 2 ///////////////////

    data_in('d0,"RD_ADDR");

    data_in('ha2,"RD_DATA");

    #50;

    $stop;

end


/////////////////////////////////////////////////////////
/////////////////////// TASKS ///////////////////////////
/////////////////////////////////////////////////////////

/////////////// Signals Initialization //////////////////
task initialize;
begin
    MOSI=0;
    SS_n=1;
    CLK=0;
    RST=1;
end
endtask

///////////////////////// RESET /////////////////////////
task reset;
begin
    RST=0;
    #CLK_PER;
    RST=1;
end
endtask

/////////////////////// Data IN /////////////////////////
task data_in;
input logic [7:0] DATA;
input string      MODE;
integer i;
begin
    logic [10:0] register;
    if(MODE == "WR_ADDR") begin
        register = {WRITE,WR_ADDR,DATA};
    end
    else if(MODE == "WR_DATA")
        register = {WRITE,WR_DATA,DATA};
    else if(MODE == "RD_ADDR")
        register = {READ,RD_ADDR,DATA};
    else if(MODE == "RD_DATA")
        register = {READ,RD_DATA,DATA};
    else begin
        $display("INPUT DATA ERROR!!!");
    end

    // $display("%b", register);

    @(negedge CLK);
    SS_n=0;

    for(i=10;i>=0;i=i-1) begin
        @(negedge CLK);
        MOSI=register[i];
    end

    if(u_DUT.u_FSM.current_state == u_DUT.u_FSM.READ_DATA) begin    // If current state is RD_DATA then read MISO "Output"
        // chk_spi_out(DATA);
        chk_spi_out(u_DUT.u_RAM.mem[u_DUT.u_RAM.addr_reg]);
    end

    @(negedge CLK);
    SS_n=1;
end
endtask

//////////////////  Check Output  ////////////////////
task chk_spi_out;
input [7:0] expected_out;
integer i;
begin
    logic [7:0] real_out;
    fork 
        // Thread 1: Checking Output
        begin
            @(negedge u_DUT.tx_valid);
            for(i=7;i>=0;i=i-1) begin
                @(negedge CLK);     
                real_out[i] = MISO;
            end
            if(expected_out==real_out)
                $display("DATA has been SUCCESSFULLY transmitted! Its Value: 0x%h", real_out);
            else
                $display("!!!ERROR - TRANSMISSION FAILED | Expected: 0x%h | Got: 0x%h", expected_out, real_out);
        end

        // Thread 2: Timeout Watchdog
        begin
            #10000;  // wait for a maximum allowed simulation time
            $display("!!!TIMEOUT!!! NO DATA FOUND!!!");
        end
    join_any
    disable fork;
end
endtask

//////////////////  WRITE AND READ  ////////////////////
task write_and_read;
input logic [7:0] address;
input logic [7:0] data;
begin

    data_in(address,"WR_ADDR");

    data_in(data,"WR_DATA");

    data_in(address,"RD_ADDR");

    data_in(data,"RD_DATA");

end
endtask


//////////////////////////////////////////////////////// 
///////////////////// Clock Generator //////////////////
//////////////////////////////////////////////////////// 

always #(CLK_PER/2) CLK = ~ CLK;


//////////////////////////////////////////////////////// 
///////////////// Design Instaniation //////////////////
////////////////////////////////////////////////////////

SPI_TOP u_DUT (.*);

endmodule