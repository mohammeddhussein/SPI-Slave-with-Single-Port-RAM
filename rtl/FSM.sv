module FSM (

    // input ports
    input wire MOSI,
    input wire SS_n,
    input wire CLK,
    input wire RST,
    input wire rx_valid,
    input wire ser_done,
    input wire tx_valid,

    // output ports
    output reg deser_en,
    output reg ser_en
);

localparam NO_OF_STATES = 5;

// States Encoding
typedef enum logic [$clog2(NO_OF_STATES)-1:0] {
    IDLE =      3'b000,
    CHK_CMD =   3'b001,
    WRITE =     3'b011,
    READ_ADD =  3'b010,
    READ_DATA = 3'b110
 } state;

state current_state, next_state;
reg READ_ADDR_DONE;

// States Functionality
always@(*) begin
    deser_en = 0;
    ser_en = 0;    
    case (current_state)
        WRITE: begin
            deser_en = 1;
        end
        READ_ADD: begin
            deser_en = 1;
        end
        READ_DATA: begin
            deser_en = 1;
            ser_en   = 1;
        end
    endcase
end

// States Transition
always@(*) begin
    case (current_state)
        IDLE: begin
            if(!SS_n) begin
                next_state = CHK_CMD;
            end
            else begin
                next_state = IDLE;
            end
        end

        CHK_CMD: begin
            if(~MOSI && ~SS_n) begin     // First bit in MOSI is a control bit, if it's 0 then WRITE (then 10 bits followed)
                next_state = WRITE;
            end
            else if(MOSI && ~SS_n && !READ_ADDR_DONE)
                next_state = READ_ADD;
            else if(MOSI && !SS_n && READ_ADDR_DONE)
                next_state = READ_DATA;
            else
                next_state = IDLE;
        end
        
        WRITE: begin
            if(!SS_n) begin
                if(rx_valid) begin
                    next_state = IDLE;
                end
                else
                    next_state = WRITE;
            end
            else
                next_state = IDLE;
                
        end

        READ_ADD: begin
            if(!SS_n) begin
                if(rx_valid) begin
                    next_state = IDLE;
                end
                else
                    next_state = READ_ADD;
            end
            else
                next_state = IDLE;            
        end

        READ_DATA: begin
            if(!SS_n) begin
                if(SS_n && ser_done)
                    next_state = IDLE;
                else
                    next_state = READ_DATA;
            end
            else
                next_state = IDLE;
        end

        default: next_state = IDLE;
    endcase

end

// Checking whether it's ADDRESS/DATA state
always@(posedge CLK or negedge RST) begin
    if(!RST)
        READ_ADDR_DONE <= 0;
    else if(current_state == READ_ADD)
        READ_ADDR_DONE <= 1;
    else if(current_state == READ_DATA)
        READ_ADDR_DONE <= 0;
end

// Assigning Current State
always@(posedge CLK or negedge RST) begin
    if(!RST) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

endmodule