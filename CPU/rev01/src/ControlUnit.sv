`timescale 1ns / 1ps

`include "defines.sv"

module ControlUnit (
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] aluControl,
    output logic        aluSrcMuxSel,
    output logic [ 1:0] RFWDSrcMuxSel,
    output logic        busWe,
    output logic        branch,
    output logic        RD1MuxSel,
    output logic        Jump
);
    wire [6:0] opcode   = instrCode[6:0];
    wire [3:0] operator = {instrCode[30], instrCode[14:12]};
    logic[7:0] signals;

    assign {regFileWe, aluSrcMuxSel, busWe, RFWDSrcMuxSel, RD1MuxSel, branch, Jump} = signals;

    always_comb begin
        signals = 8'b0_0_0_00_0_0_0;
        case (opcode)
            `OP_TYPE_R   : signals = 8'b1_0_0_00_0_0_0;
            `OP_TYPE_L   : signals = 8'b1_1_0_01_0_0_0;
            `OP_TYPE_I   : signals = 8'b1_1_0_00_0_0_0;
            `OP_TYPE_S   : signals = 8'b0_1_1_00_0_0_0;
            `OP_TYPE_B   : signals = 8'b0_0_0_00_0_1_0;
            `OP_TYPE_LU  : signals = 8'b1_1_0_00_1_0_0;
            `OP_TYPE_AU  : signals = 8'b1_0_0_10_0_0_0;
            `OP_TYPE_JAL : signals = 8'b1_0_0_11_0_0_1;
            `OP_TYPE_JALR: signals = 8'b1_1_0_11_0_0_0;
        endcase
    end

    always_comb begin
        aluControl = 4'bx;
        case (opcode)
            `OP_TYPE_R: aluControl = operator;
            `OP_TYPE_S: aluControl = `ADD;
            `OP_TYPE_L: aluControl = `ADD;
            `OP_TYPE_I: begin
                if(operator == 4'b1101)begin
                    aluControl = operator;
                end
                else begin
                    aluControl = {1'b0, operator[2:0]};
                end
            end
            `OP_TYPE_B:  aluControl = operator;
            `OP_TYPE_LU: aluControl = `ADD;
            `OP_TYPE_AU: aluControl = `ADD;
            `OP_TYPE_JAL: aluControl = `ADD;
            `OP_TYPE_JALR:aluControl = `ADD;
        endcase
    end

endmodule
