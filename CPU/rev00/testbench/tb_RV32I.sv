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

    task check_result_RF (input logic [4:0] addr, input [31:0] expect_value, input [127:0] test_type);
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

    task check_result_DMEM (input logic [14:0] addr, input [31:0] expect_value, input [127:0] test_type);
        done = 0;
        current_test_id   = current_test_id + 1;
        current_test_type = test_type;
        current_result    = expect_value;
        while (`RAM_PATH.mem[addr] !== expect_value) begin
            current_output = `RAM_PATH.mem[addr];
            @(posedge clk);
        end
        cycle = 0;
        done = 1;
        $display("[%d] Test %s passed!", current_test_id, test_type);
    endtask

    logic [ 4:0] RS0, RS1, RS2, RS3, RS4, RS5;
    logic [ 4:0] SHAMT;
    logic [31:0] IMM, IMM0, IMM1, IMM2, IMM3;
    logic [11:0] IMM12_0;
    logic [31:0] RD0, RD1, RD2, RD3, RD4, RD5;
    logic [14:0] DATA_ADDR, DATA_ADDR0, DATA_ADDR1, DATA_ADDR2, DATA_ADDR3;
    logic [14:0] DATA_ADDR4, DATA_ADDR5, DATA_ADDR6, DATA_ADDR7, DATA_ADDR8, DATA_ADDR9;

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

            #10; check_result_RF(8,  32'h8000_0000, "R-Type ADD");
            #10; check_result_RF(9,  32'h8000_0002, "R-Type SUB");
            #10; check_result_RF(10, 32'h8000_0000, "R-Type AND");
            #10; check_result_RF(11, 32'hFFFF_FFFF, "R-Type OR");
            #10; check_result_RF(12, 32'h8000_0000, "R-Type SLL");
            #10; check_result_RF(13, 32'h0000_0001, "R-Type SRL");
            #10; check_result_RF(14, 32'hFFFF_FFFF, "R-Type SRA");
            #10; check_result_RF(15, 32'h0000_0001, "R-Type SLT");
            #10; check_result_RF(16, 32'h0000_0000, "R-Type SLTU");
            #10; check_result_RF(17, 32'h7FFF_FFFF, "R-Type XOR");
        end

        // S-Type
        if (0) begin
            init();
            
            IMM0 = 32'h0000_0100;
            IMM1 = 32'h0000_0101;
            IMM2 = 32'h0000_0102;
            IMM3 = 32'h0000_0103;

            DATA_ADDR0 = (`RF_PATH.mem[ 2] + IMM0[11:0]) >> 2;
            DATA_ADDR1 = (`RF_PATH.mem[ 3] + IMM0[11:0]) >> 2;
            DATA_ADDR2 = (`RF_PATH.mem[ 4] + IMM1[11:0]) >> 2;
            DATA_ADDR3 = (`RF_PATH.mem[ 5] + IMM2[11:0]) >> 2;
            DATA_ADDR4 = (`RF_PATH.mem[ 6] + IMM3[11:0]) >> 2;
            DATA_ADDR5 = (`RF_PATH.mem[ 7] + IMM0[11:0]) >> 2;
            DATA_ADDR6 = (`RF_PATH.mem[ 8] + IMM1[11:0]) >> 2;
            DATA_ADDR7 = (`RF_PATH.mem[ 9] + IMM2[11:0]) >> 2;
            DATA_ADDR8 = (`RF_PATH.mem[10] + IMM3[11:0]) >> 2;

            `RF_PATH.mem[ 1] = 32'h1234_5678;
            `RF_PATH.mem[ 2] = 32'h8765_4321;
            `RF_PATH.mem[ 3] = 32'h3000_0020;
            `RF_PATH.mem[ 4] = 32'h3000_0030;
            `RF_PATH.mem[ 5] = 32'h3000_0040;
            `RF_PATH.mem[ 6] = 32'h3000_0050;
            `RF_PATH.mem[ 7] = 32'h0000_0000;
            `RF_PATH.mem[ 8] = 32'h0000_0000;
            `RF_PATH.mem[ 9] = 32'h0000_0000;
            `RF_PATH.mem[10] = 32'h0000_0000;

            `INSTR_PATH.rom[0] = {IMM0[11:5], 5'd1, 5'd2,  `FNC_SW, IMM0[4:0], `OPC_STORE};

            `INSTR_PATH.rom[1] = {IMM0[11:5], 5'd1, 5'd3,  `FNC_SH, IMM0[4:0], `OPC_STORE};
            //`INSTR_PATH.rom[2] = {IMM1[11:5], 5'd1, 5'd4,  `FNC_SH, IMM1[4:0], `OPC_STORE}; 
            `INSTR_PATH.rom[3] = {IMM2[11:5], 5'd1, 5'd5,  `FNC_SH, IMM2[4:0], `OPC_STORE};
            //`INSTR_PATH.rom[4] = {IMM3[11:5], 5'd1, 5'd6,  `FNC_SH, IMM3[4:0], `OPC_STORE}; 

            `INSTR_PATH.rom[5] = {IMM0[11:5], 5'd1, 5'd7,  `FNC_SB, IMM0[4:0], `OPC_STORE};
            `INSTR_PATH.rom[6] = {IMM1[11:5], 5'd1, 5'd8,  `FNC_SB, IMM1[4:0], `OPC_STORE};
            `INSTR_PATH.rom[7] = {IMM2[11:5], 5'd1, 5'd9,  `FNC_SB, IMM2[4:0], `OPC_STORE};
            `INSTR_PATH.rom[8] = {IMM3[11:5], 5'd1, 5'd10, `FNC_SB, IMM3[4:0], `OPC_STORE};

            `RAM_PATH.mem[DATA_ADDR0] = 0;
            `RAM_PATH.mem[DATA_ADDR1] = 0;
            `RAM_PATH.mem[DATA_ADDR3] = 0;
            `RAM_PATH.mem[DATA_ADDR4] = 0;
            `RAM_PATH.mem[DATA_ADDR5] = 0;
            `RAM_PATH.mem[DATA_ADDR6] = 0;
            `RAM_PATH.mem[DATA_ADDR7] = 0;
            `RAM_PATH.mem[DATA_ADDR8] = 0;
            
            reset_cpu();

            check_result_DMEM(DATA_ADDR0, 32'h12345678, "S-Type SW");
            check_result_DMEM(DATA_ADDR1, 32'h00005678, "S-Type SH 1");
            //check_result_DMEM(DATA_ADDR2, 32'h00005678, "S-Type SH 2");
            check_result_DMEM(DATA_ADDR3, 32'h56780000, "S-Type SH 3");
            //check_result_DMEM(DATA_ADDR4, 32'h56780000, "S-Type SH 4");

            check_result_DMEM(DATA_ADDR5, 32'h00000078, "S-Type SB 1");
            check_result_DMEM(DATA_ADDR6, 32'h00007800, "S-Type SB 2");
            check_result_DMEM(DATA_ADDR7, 32'h00780000, "S-Type SB 3");
            check_result_DMEM(DATA_ADDR8, 32'h78000000, "S-Type SB 4");
        end

        // L-Type
        if (1) begin
            init();

            `RF_PATH.mem[1] = 32'h3000_0100;
            IMM0            = 32'h0000_0000;
            IMM1            = 32'h0000_0001;
            IMM2            = 32'h0000_0002;
            IMM3            = 32'h0000_0003;
            INST_ADDR       = 14'h0000;
            DATA_ADDR       = (`RF_PATH.mem[1] + IMM0[11:0]) >> 2;

            `INSTR_PATH.rom[ 0] = {IMM0[11:0], 5'd1, `FNC_LW,  5'd2,  `OPC_LOAD};
            `INSTR_PATH.rom[ 1] = {IMM0[11:0], 5'd1, `FNC_LH,  5'd3,  `OPC_LOAD};
            //`INSTR_PATH.rom[ 3] = {IMM1[11:0], 5'd1, `FNC_LH,  5'd4,  `OPC_LOAD};
            `INSTR_PATH.rom[ 4] = {IMM2[11:0], 5'd1, `FNC_LH,  5'd5,  `OPC_LOAD};
            //`INSTR_PATH.rom[ 5] = {IMM3[11:0], 5'd1, `FNC_LH,  5'd6,  `OPC_LOAD};
            `INSTR_PATH.rom[ 6] = {IMM0[11:0], 5'd1, `FNC_LB,  5'd7,  `OPC_LOAD};
            `INSTR_PATH.rom[ 7] = {IMM1[11:0], 5'd1, `FNC_LB,  5'd8,  `OPC_LOAD};
            `INSTR_PATH.rom[ 8] = {IMM2[11:0], 5'd1, `FNC_LB,  5'd9,  `OPC_LOAD};
            `INSTR_PATH.rom[ 9] = {IMM3[11:0], 5'd1, `FNC_LB,  5'd10, `OPC_LOAD};
            `INSTR_PATH.rom[10] = {IMM0[11:0], 5'd1, `FNC_LHU, 5'd11, `OPC_LOAD};
            //`INSTR_PATH.rom[11] = {IMM1[11:0], 5'd1, `FNC_LHU, 5'd12, `OPC_LOAD};
            `INSTR_PATH.rom[12] = {IMM2[11:0], 5'd1, `FNC_LHU, 5'd13, `OPC_LOAD};
            //`INSTR_PATH.rom[13] = {IMM3[11:0], 5'd1, `FNC_LHU, 5'd14, `OPC_LOAD};
            `INSTR_PATH.rom[14] = {IMM0[11:0], 5'd1, `FNC_LBU, 5'd15, `OPC_LOAD};
            `INSTR_PATH.rom[15] = {IMM1[11:0], 5'd1, `FNC_LBU, 5'd16, `OPC_LOAD};
            `INSTR_PATH.rom[16] = {IMM2[11:0], 5'd1, `FNC_LBU, 5'd17, `OPC_LOAD};
            `INSTR_PATH.rom[17] = {IMM3[11:0], 5'd1, `FNC_LBU, 5'd18, `OPC_LOAD};

            `RAM_PATH.mem[DATA_ADDR] = 32'hdeadbeef;

            reset_cpu();

            check_result_RF(5'd2,  32'hdeadbeef, "I-Type LW");

            check_result_RF(5'd3,  32'hffffbeef, "I-Type LH 0");
            // check_result_RF(5'd4,  32'hffffbeef, "I-Type LH 1");
            check_result_RF(5'd5,  32'hffffdead, "I-Type LH 2");
            // check_result_RF(5'd6,  32'hffffdead, "I-Type LH 3");

            check_result_RF(5'd7,  32'hffffffef, "I-Type LB 0");
            check_result_RF(5'd8,  32'hffffffbe, "I-Type LB 1");
            check_result_RF(5'd9,  32'hffffffad, "I-Type LB 2");
            check_result_RF(5'd10, 32'hffffffde, "I-Type LB 3");

            check_result_RF(5'd11, 32'h0000beef, "I-Type LHU 0");
            // check_result_RF(5'd12, 32'h0000beef, "I-Type LHU 1");
            check_result_RF(5'd13, 32'h0000dead, "I-Type LHU 2");
            // check_result_RF(5'd14, 32'h0000dead, "I-Type LHU 3");

            check_result_RF(5'd15, 32'h000000ef, "I-Type LBU 0");
            check_result_RF(5'd16, 32'h000000be, "I-Type LBU 1");
            check_result_RF(5'd17, 32'h000000ad, "I-Type LBU 2");
            check_result_RF(5'd18, 32'h000000de, "I-Type LBU 3");
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

            #10; check_result_RF(3,  32'h0000_1011, "I-Type ADDI");
            #10; check_result_RF(4,  32'h0000_0000, "I-Type ANDI");
            #10; check_result_RF(5,  32'h0000_1011, "I-Type ORI");
            #10; check_result_RF(6,  32'h0000_0000, "I-Type SLTI");
            #10; check_result_RF(7,  32'h0000_0000, "I-Type SLTIU");
            #10; check_result_RF(8,  32'h0000_1011, "I-Type XORI");
            #10; check_result_RF(9,  32'h0000_2020, "I-Type SLLI");
            #10; check_result_RF(10, 32'h0000_0808, "I-Type SRLI");
            #10; check_result_RF(11, 32'h0000_0808, "I-Type SRAI");
            
        end

    all_passed = 1'b1;

    repeat(10) @(posedge clk);
    $display("All tests passed!");
    $finish();

    end

endmodule