`timescale 1ns / 1ps

module RAM (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wData,
    output logic [31:0] rData,
    input  logic [ 3:0] Byte_Enable
);
    logic [31:0] mem[0:9];

    always_ff @(posedge clk) begin
        if(we) begin
            for(int i = 0; i < 4; i++) begin
                if(Byte_Enable[i]) begin
                    mem[addr[31:2]][(i*8)+:8] <= wData[(i*8)+:8];
                end
            end
        end
    end

    assign rData = mem[addr[31:2]];

endmodule