`timescale 1ns / 1ps

module MCU(
    input logic clk,
    input logic reset  
    );

    logic [31:0] instrCode;
    logic [31:0] instrMemAddr;
    logic        busWe;
    logic [31:0] busAddr;
    logic [31:0] busRData;
    logic [31:0] busWData;
    logic [ 3:0] Byte_Enable;

    ROM U_ROM(
        .addr   (instrMemAddr),
        .data   (instrCode)
    );

    CPU_RV32I U_CPU_RV32I (.*);

    RAM U_RAM (
        .clk         (clk),
        .we          (busWe),
        .addr        (busAddr),
        .wData       (busWData),
        .rData       (busRData),
        .Byte_Enable (Byte_Enable)
    );
    
endmodule
