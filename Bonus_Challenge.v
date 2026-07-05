module bonus(
    input clk,
    input serial_in,
    input rst,
    output reg done,
    output reg [7:0] result,
    output reg parity_err,
    output reg frame_err
);

parameter IDLE = 3'b000;
parameter COMMAND = 3'b001;
parameter DATA = 3'b010;
parameter PARITY = 3'b011;
parameter STOP = 3'b100;

reg [2:0] state, next_state;
reg [7:0] A, B;
reg [1:0] command;
reg [7:0] shift_reg; 
reg bit_countA;
reg [2:0] bit_countB;
reg parity_failed;

always @(posedge clk) begin
    if (rst) 
        state <= IDLE;
    else 
        state <= next_state;
end

always @(*) begin
    next_state = state; // Default to current state
    case (state)
        IDLE: begin
            if (serial_in == 0) // Start bit detected
                next_state = COMMAND;
            else 
                next_state = IDLE;
        end
        COMMAND: begin
            if (bit_countA == 1)  // All command bits received
                next_state = DATA;
            else 
                next_state = COMMAND;
        end
        DATA: begin
            if (bit_countB == 7)  // All data bits received
                next_state = PARITY;
            else 
                next_state = DATA;
        end
        PARITY: begin
            next_state = STOP; // Move to stop bit after parity check
        end
        STOP: begin
            next_state = IDLE; // Return to idle after stop bit
        end
        default: next_state = IDLE;
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        bit_countA <= 0;
        bit_countB <= 0;
        parity_failed <= 0;
        done <= 0;
        result <= 8'b0;
        parity_err <= 0;
        frame_err <= 0;
        A<=0;
        B<=0;
        shift_reg <= 8'b0;
        command <= 2'b00;
    end else begin
        case (state)
            IDLE: begin
                done <= 0;
                parity_err <= 0;
                frame_err <= 0;
                bit_countA <= 0;
                bit_countB <= 0;
                parity_failed <= 0;

            end
            COMMAND: begin
                command[1-bit_countA] <= serial_in; // Shift in command bits
                bit_countA <= bit_countA + 1;
            end
            DATA: begin
                shift_reg[bit_countB] <= serial_in; // Shift in data bits
                bit_countB <= bit_countB + 1;

            end 
            PARITY: begin
                 if (^shift_reg != serial_in) begin
                    parity_failed <= 1; // Parity error detected
                    parity_err <= 1; // Parity error detected
                end 
                else begin
                    parity_failed <= 0;
                end
            end
            STOP: begin
                parity_err <= 0;
                if (serial_in != 1) begin
                    frame_err <= 1; // Frame error detected
                end
                if(!parity_failed && serial_in == 1) begin
                    case (command)
                        2'b00: begin
                            result <= shift_reg; 
                            A <= shift_reg; 
                        end// Command 0: Output data as is
                        2'b01: begin
                            result <= shift_reg; // Command 1: Output bitwise NOT of data
                            B <= shift_reg; // Command 1: Output bitwise NOT of data
                        end
                        2'b10: result <= A+B;
                        2'b11: begin
                            result <= 0;
                            A <= 0;
                            B <= 0;
                        end
                        default: begin
                            result <= 8'b0;
                        end
                    endcase
                    done <= 1; // Indicate processing is done
                end else begin
                    result <= 8'b0; // Clear result on error
                    done <= 0;
                end
            end
            default: begin
                done <= 0;
                parity_err <= 0;
                frame_err <= 0;
            end
        endcase
    end
end

endmodule
