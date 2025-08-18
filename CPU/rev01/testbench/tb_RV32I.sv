`timescale 1ns / 1ps

`include "opcode.vh"
`include "mem_path.vh"

module tb_RV32I();

    logic clk;
    logic reset;

    logic all_passed = 1'b0;

    MCU U_MCU (
      .clk  (clk),
      .reset(reset)
    );

    always#5 clk = ~clk;

    task init;
        int i;
        for (int i = 0; i < 62; i++) begin
            `INSTR_PATH.rom[i] = 32'h00000000;
        end
        for (int i = 0; i < 32; i++) begin
            `RF_PATH.mem[i] = 32'h00000000;
        end
    endtask

    task reset_cpu; 
        repeat(3) begin
            @(posedge clk);
            reset = 1;
        end
        @(posedge clk);
        reset = 0;
    endtask

    logic [31:0] cycle;
    logic done;
    logic [31:0]  current_test_id = 0;
    logic [127:0] current_test_type;
    logic [31:0]  current_output;
    logic [31:0]  current_result;
    logic all_tests_passed = 0;

    wire [31:0] timeout_cycle = 25;

    initial begin
        while (all_tests_passed === 0) begin
        @(posedge clk);
            if (cycle === timeout_cycle) begin
                $display("[Failed] Timeout at [%d] test %s, expected_result = %h, got = %h", current_test_id, current_test_type, current_result, current_output);
                $finish();
            end
        end
    end

    always_ff @(posedge clk) begin
        if (done === 0)
            cycle <= cycle + 1;
        else
            cycle <= 0;
    end

    task check_result (input logic [4:0] addr, input [31:0] expect_value, input [127:0] test_type);
        done = 0;
        current_test_id   = current_test_id + 1;
        current_test_type = test_type;
        current_result    = expect_value;
        while (`RF_PATH.mem[addr] !== expect_value) begin
            current_output = `RF_PATH.mem[addr];
            @(posedge clk);
        end
        cycle = 0;
        done = 1;
        $display("[%d] Test %s passed!", current_test_id, test_type);
    endtask

    logic [ 4:0] RS0, RS1, RS2, RS3, RS4, RS5;
    logic [ 4:0] SHAMT;
    logic [ 4:0] IMM5_0;
    logic [ 6:0] IMM7_0;
    logic [11:0] IMM12_0;
    logic [31:0] RD0, RD1, RD2, RD3, RD4, RD5;

    initial begin
        clk = 0;
        reset = 1;
        #10;
        reset = 0;
        #10;

        // R-Type
        if(1) begin
            init();
            RS0 = 0; RD0 = 32'h0000_0000;
            RS1 = 1; RD1 = 32'h0000_0001;
            RS2 = 2; RD2 = 32'h7FFF_FFFF;
            RS3 = 3; RD3 = 32'hFFFF_FFFF;
            RS4 = 4; RD4 = 32'h8000_0000;
            RS5 = 5; RD5 = 32'h0000_001F;

            `RF_PATH.mem[RS1] = RD1; //x1 data
            `RF_PATH.mem[RS2] = RD2; //x2 data
            `RF_PATH.mem[RS3] = RD3; //x3 data
            `RF_PATH.mem[RS4] = RD4; //x4 data
            `RF_PATH.mem[RS5] = RD5; //x5 data

            // format: {funct7, rs2, rs1, funct3, rd, opcode}
            `INSTR_PATH.rom[0] = {`FNC7_0, RS1, RS2, `FNC_ADD_SUB, 5'd8, `OPC_ARI_RTYPE};  // add  x8, x2, x1
            `INSTR_PATH.rom[1] = {`FNC7_1, RS2, RS1, `FNC_ADD_SUB, 5'd9, `OPC_ARI_RTYPE};  // sub  x9, x1, x2
            `INSTR_PATH.rom[2] = {`FNC7_0, RS4, RS3, `FNC_AND,     5'd10, `OPC_ARI_RTYPE}; // and  x10, x3, x4
            `INSTR_PATH.rom[3] = {`FNC7_0, RS3, RS4, `FNC_OR,      5'd11, `OPC_ARI_RTYPE}; // or   x11, x4, x3
            `INSTR_PATH.rom[4] = {`FNC7_0, RS5, RS1, `FNC_SLL,     5'd12, `OPC_ARI_RTYPE}; // sll  x12, x1, x5
            `INSTR_PATH.rom[5] = {`FNC7_0, RS5, RS4, `FNC_SRL_SRA, 5'd13, `OPC_ARI_RTYPE}; // srl  x13, x4, x5
            `INSTR_PATH.rom[6] = {`FNC7_1, RS5, RS4, `FNC_SRL_SRA, 5'd14, `OPC_ARI_RTYPE}; // sra  x14, x4, x5
            `INSTR_PATH.rom[7] = {`FNC7_0, RS2, RS4, `FNC_SLT,     5'd15, `OPC_ARI_RTYPE}; // slt  x15, x4, x2
            `INSTR_PATH.rom[8] = {`FNC7_0, RS0, RS3, `FNC_SLTU,    5'd16, `OPC_ARI_RTYPE}; // sltu x16, x3, x0
            `INSTR_PATH.rom[9] = {`FNC7_0, RS4, RS3, `FNC_XOR,     5'd17, `OPC_ARI_RTYPE}; // xor  x17, x3, x4

            reset_cpu();

            #10; check_result(8,  32'h8000_0000, "R-Type ADD");
            #10; check_result(9,  32'h8000_0002, "R-Type SUB");
            #10; check_result(10, 32'h8000_0000, "R-Type AND");
            #10; check_result(11, 32'hFFFF_FFFF, "R-Type OR");
            #10; check_result(12, 32'h8000_0000, "R-Type SLL");
            #10; check_result(13, 32'h0000_0001, "R-Type SRL");
            #10; check_result(14, 32'hFFFF_FFFF, "R-Type SRA");
            #10; check_result(15, 32'h0000_0001, "R-Type SLT");
            #10; check_result(16, 32'h0000_0000, "R-Type SLTU");
            #10; check_result(17, 32'h7FFF_FFFF, "R-Type XOR");
        end

        // S-Type
        if (0) begin
            init();

            reset_cpu();

            #10; check_result(8,  32'h8000_0000, "S-Type SB");
            #10; check_result(9,  32'h8000_0002, "S-Type SH");
            #10; check_result(10, 32'h8000_0000, "S-Type SW");
        end

        // L-Type
        if (0) begin
            init();

            reset_cpu();

            #10; check_result(8,  32'h8000_0000, "L-Type LB");
            #10; check_result(9,  32'h8000_0002, "L-Type LH");
            #10; check_result(10, 32'h8000_0000, "L-Type LW");
            #10; check_result(9,  32'h8000_0002, "L-Type LBU");
            #10; check_result(10, 32'h8000_0000, "L-Type LHU");
        end
        
        // I-Type 
        if (0) begin
            init();
            
            IMM12_0 = 12'b0000000001;
            RS1 = 1; RD1 = 32'h0000_1010;
            SHAMT = 5'b00001;
            `RF_PATH.mem[RS1] = RD1;

            // 32'b  imm12 _ rs1 _f3 _ rd _ op // I-Type
            `INSTR_PATH.rom[0] = {IMM12_0, RS1, `FNC_ADD_SUB, 5'd3, `OPC_ARI_ITYPE}; // addi  x3, x1, 1
            `INSTR_PATH.rom[1] = {IMM12_0, RS1, `FNC_AND,     5'd4, `OPC_ARI_ITYPE}; // andi  x4, x1, 1
            `INSTR_PATH.rom[2] = {IMM12_0, RS1, `FNC_OR,      5'd5, `OPC_ARI_ITYPE}; // ori   x5, x1, 1
            `INSTR_PATH.rom[3] = {IMM12_0, RS1, `FNC_SLT,     5'd6, `OPC_ARI_ITYPE}; // slti  x6, x1, 1
            `INSTR_PATH.rom[4] = {IMM12_0, RS1, `FNC_SLTU,    5'd7, `OPC_ARI_ITYPE}; // sltiu x7, x1, 1
            `INSTR_PATH.rom[5] = {IMM12_0, RS1, `FNC_XOR,     5'd8, `OPC_ARI_ITYPE}; // xori  x8, x1, 1
            // 32'b  f7_ shamt _ rs1 _f3 _ rd _ op // I-Type
            `INSTR_PATH.rom[6] = {`FNC7_0, SHAMT, RS1, `FNC_SLL,     5'd9,  `OPC_ARI_ITYPE}; // slli x9  x1 << 1
            `INSTR_PATH.rom[7] = {`FNC7_0, SHAMT, RS1, `FNC_SRL_SRA, 5'd10, `OPC_ARI_ITYPE}; // srli x10 x1 >> 1
            `INSTR_PATH.rom[8] = {`FNC7_1, SHAMT, RS1, `FNC_SRL_SRA, 5'd11, `OPC_ARI_ITYPE}; // srai x11 x1 >>> 1

            reset_cpu();

            #10; check_result(3,  32'h0000_1011, "I-Type ADDI");
            #10; check_result(4,  32'h0000_0000, "I-Type ANDI");
            #10; check_result(5,  32'h0000_1011, "I-Type ORI");
            #10; check_result(6,  32'h0000_0000, "I-Type SLTI");
            #10; check_result(7,  32'h0000_0000, "I-Type SLTIU");
            #10; check_result(8,  32'h0000_1011, "I-Type XORI");
            #10; check_result(9,  32'h0000_2020, "I-Type SLLI");
            #10; check_result(10, 32'h0000_0808, "I-Type SRLI");
            #10; check_result(11, 32'h0000_0808, "I-Type SRAI");
            
        end


    
    all_passed = 1'b1;

    repeat(10) @(posedge clk);
    $display("All tests passed!");
    $finish();

    end

endmodule