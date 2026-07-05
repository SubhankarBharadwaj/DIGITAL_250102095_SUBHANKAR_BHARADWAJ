module serial_input(
    input clk,
    input rst,
    input serial_in,
    output reg done,
    output reg [7:0] data_out,
    output reg parity_err,
    output reg frame_err

);

parameter IDLE = 2'b00;
parameter DATA = 2'b01;
parameter PARITY = 2'b10;
parameter STOP = 2'b11;

reg [1:0] state,next_state;
reg [7:0] shift_reg;

reg [2:0] bit_count; // To count the number of bits received

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
                next_state = DATA;
            else 
                next_state = IDLE;
        end
        DATA: begin
            if (bit_count == 7)  // All data bits received
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

reg parity_failed;

always @(posedge clk) begin
    if (rst) begin
        shift_reg <= 8'b0;
        bit_count <= 3'b0;
        data_out <= 8'b0;
        done <= 0;
        parity_err <= 0;
        frame_err <= 0;
        parity_failed <= 0;
    end else begin
        case (state)
            IDLE: begin
                done <= 0;
                parity_err <= 0;
                frame_err <= 0;
                bit_count <= 3'b0; 
                parity_failed <= 0;
            end
            DATA: begin
                shift_reg[bit_count] <= serial_in; //Assuming that first recieved bit is the least significant bit
                bit_count <= bit_count + 1;
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
                parity_err <=0;// Clear parity error for next cycle
                frame_err <= (serial_in != 1); // Check for frame error (stop bit should be 1)
                if(!parity_failed && serial_in == 1) begin// Indicate that reception is complete
                    done <= 1;
                    data_out <= shift_reg; 
                end
                else begin
                    data_out <= 0;
                    done <= 0;
                end 
            end
            default: begin
                done <= 0;
                parity_err <= 0;
                frame_err <= 0;
                bit_count <= 3'b0;
                parity_failed <= 0;
            end
        endcase
    end
end

endmodule
