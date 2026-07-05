module mealy(
    input clk,
    input in,
    input rst,
    output reg out

);

parameter A = 2'b00;
parameter B = 2'b01;
parameter C = 2'b10;
parameter D = 2'b11;

reg [1:0] state, next_state;

always @(posedge clk or posedge rst) begin
    if (rst) 
        state <= A;
    else 
        state <= next_state;
    
end

always @(*) begin
    case (state)
        A: begin
            if (in) 
                next_state = B;
            else 
                next_state = A;
        end
        B: begin
            if (in) 
                next_state = B;
            else 
                next_state = C;
        end
        C: begin
            if (in) 
                next_state = D;
            else 
                next_state = A;
        end
        D: begin
            if (in) 
                next_state = B;
            else 
                next_state = C;
        end
        default: next_state = A;
    endcase
end
always @(*) begin
    case (state)
        A: out = 0;
        B: out = 0;
        C: begin
            if (in) 
                out = 1;
            else 
                out = 0;
        end
        D: out = 1;
        default: out = 0;
    endcase
end
    
endmodule