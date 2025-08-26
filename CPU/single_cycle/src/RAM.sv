`timescale 1ns / 1ps

module RAM (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wData,
    output logic [31:0] rData,
    input  logic [ 3:0] Byte_Enable
);
    logic [31:0] mem[0:2**8-1];     // 0x00 ~ 0x0F => 0x10 * 4 => 0x40
                                    // 0x00 ~ 0x3FF => 0x400

    always_ff @(posedge clk) begin
        if(we) begin
            mem[addr[31:2]] <= wData;
        end
    end

    assign rData = mem[addr[31:2]];

endmodule
