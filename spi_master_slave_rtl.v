module spi_master(
    input clk, newd, rst,
    input [11:0] din, 
    output reg sclk, cs, mosi
);

    // State Encoding
    parameter IDLE = 2'b00, ENABLE = 2'b01, SEND = 2'b10, COMP = 2'b11;
    reg [1:0] state;
    
    integer countc = 0;
    integer count = 0;
    reg [11:0] temp;
    
    // Generation of sclk
    always @(posedge clk) begin
        if (rst) begin
            countc <= 0;
            sclk <= 1'b0;
        end else begin 
            if (countc < 10)
                countc <= countc + 1;
            else begin
                countc <= 0;
                sclk <= ~sclk;
            end
        end
    end
    
    // State Machine
    always @(posedge sclk) begin
        if (rst) begin
            cs <= 1'b1; 
            mosi <= 1'b0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (newd) begin
                        state <= SEND;
                        temp <= din; 
                        cs <= 1'b0;
                    end else begin
                        state <= IDLE;
                        temp <= 12'h000;
                    end
                end
                
                SEND: begin
                    if (count <= 11) begin
                        mosi <= temp[count]; 
                        count <= count + 1;
                    end else begin
                        count <= 0;
                        state <= IDLE;
                        cs <= 1'b1;
                        mosi <= 1'b0;
                    end
                end
                
                default: state <= IDLE; 
            endcase
        end 
    end
    
endmodule

/////////////////////////////
module spi_slave (
    input sclk, cs, mosi,
    output [11:0] dout,
    output reg done
);
 
    // State Encoding
    parameter DETECT_START = 1'b0, READ_DATA = 1'b1;
    reg state;
 
    reg [11:0] temp = 12'h000;
    integer count = 0;
 
    always @(posedge sclk) begin
        case (state)
            DETECT_START: begin
                done <= 1'b0;
                if (cs == 1'b0)
                    state <= READ_DATA;
                else
                    state <= DETECT_START;
            end
 
            READ_DATA: begin
                if (count <= 11) begin
                    count <= count + 1;
                    temp <= {mosi, temp[11:1]};
                end else begin
                    count <= 0;
                    done <= 1'b1;
                    state <= DETECT_START;
                end
            end
        endcase
    end
    
    assign dout = temp;
 
endmodule

