module moore(
    input clk,
    input in,
    input rst,
    output reg out
);

parameter A = 3'b000;
parameter B = 3'b001;
parameter C = 3'b010;
parameter D = 3'b011;
parameter E = 3'b100;
parameter F = 3'b101;

reg [2:0] state, next_state;

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
                next_state = F;
            else 
                next_state = E;
        end
        E: begin
            if (in) 
                next_state = D;
            else 
                next_state = A;
        end
        F: begin
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
        C: out = 0;
        D: out = 1;
        E: out = 1;
        F: out = 1;
        default: out = 0;
    endcase
end

endmodule