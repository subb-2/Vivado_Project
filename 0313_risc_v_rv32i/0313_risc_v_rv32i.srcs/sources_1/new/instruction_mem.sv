`timescale 1ns / 1ps

module instruction_mem (
    //rom은 조합 출력
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom [0:127];
 
    initial begin
        $readmemh("riscv_rv32i_rom_data.mem",rom); 

        //hex 값이니까 readmemh로 읽어야 함
        //저장할 위치도 알려줘야 함 : rom 

        //R type 기본
        //rom[0] = 32'h004182b3; // ADD  : rd=x5,  rs1=x3, rs2=x4
        //rom[1] = 32'h40230333; // SUB  : rd=x6,  rs1=x6, rs2=x2
        //rom[2] = 32'h008193b3; // SLL  : rd=x7,  rs1=x3, rs2=x8
        //rom[3] = 32'h0081a433; // SLT  : rd=x8,  rs1=x3, rs2=x8
        //rom[4] = 32'h0081b4b3; // SLTU : rd=x9,  rs1=x3, rs2=x8
        //rom[5] = 32'h00654533; // XOR  : rd=x10, rs1=x10,rs2=x9
        //rom[6] = 32'h0081d5b3; // SRL  : rd=x11, rs1=x3, rs2=x8
        //rom[7] = 32'h4042d633; // SRA  : rd=x12, rs1=x5, rs2=x4
        //rom[8] = 32'h004166b3; // OR   : rd=x13, rs1=x2, rs2=x4
        //rom[9] = 32'h00547733; // AND  : rd=x14, rs1=x4, rs2=x5

        //R type 특수
        // 1. SLL (Shift Left Logical) : 3 << 33(1) = 6
        //rom[0] = 32'h00e697b3; // rd=x15, rs1=x13(3), rs2=x14(33)
//
        //// 2. SLT (Set Less Than - Signed) : -2^31 < 1 이므로 결과 1
        //rom[1] = 32'h00c5a833; // rd=x16, rs1=x11(min), rs2=x12(1)
//
        //// 3. SLTU (Set Less Than - Unsigned) : 큰 양수 < 1 이므로 결과 0
        //rom[2] = 32'h00c5b8b3; // rd=x17, rs1=x11(max), rs2=x12(1)
///
        //// 4. SRL (Shift Right Logical) : 0x80000000 >> 33(1) = 0x40000000
        //rom[3] = 32'h00e5d933; // rd=x18, rs1=x11, rs2=x14(33)
//
        //// 5. SRA (Shift Right Arithmetic) : 0x80000000 >>> 33(1) = 0xc0000000 (부호유지)
        //rom[4] = 32'h40e5d9b3; // rd=x19, rs1=x11, rs2=x14(33)

        //rom[0] = 32'h00d61733;
        //rom[1] = 32'h0107a8b3;
        //rom[2] = 32'h0107b8b3;
        //rom[3] = 32'h0047d933;
        //rom[4] = 32'h4047d9b3;

        //R-type HW
        //rom[0] = 32'h004182b3;
        //rom[1] = 32'h402302b3;
        //rom[2] = 32'h008193b3;
        //rom[3] = 32'h0081a2b3;
        //rom[4] = 32'h0081b2b3;
        //rom[5] = 32'h00954433;
        //rom[6] = 32'h0081d3b3;
        //rom[7] = 32'h4042d333;
        //rom[8] = 32'h004161b3;
        //rom[9] = 32'h005273b3;
//
        //rom[10] = 32'h00d61733;
        //rom[11] = 32'h0107a8b3;
        //rom[12] = 32'h0117b833;
        //rom[13] = 32'h0047d933;
        //rom[14] = 32'h4047d9b3;


        //rom[0] = 32'h004182b3; //ADD X5, X3, X4  
        //rom[1] = 32'h402302b3; //sw x2, 2(x8), sw x2, x8, 2 
        //rom[2] = 32'h008193b3; //LW x7, x2, 2
        //rom[3] = 32'h0081a2b3; //ADDi x8, x7, 4 
//
        //rom[4] = 32'h0081b2b3; //SB x4, x13, 3
        //rom[5] = 32'h00954433; //LB x8, x4, 3
        //rom[6] = 32'h0081d3b3; //SH x5, x14, 5 
        //rom[7] = 32'h4042d333; //LH x9, x5, 5 
        //rom[8] = 32'h004161b3; //LBU x8, x7, 4 
        //rom[9] = 32'h005273b3; //LHU x8, x7, 4
        // ========================================
        //0311 class
        //rom[0] = 32'h004182b3; //ADD X5, X3, X4  
        //rom[1] = 32'h00812123; //sw x2, 2(x8), sw x2, x8, 2 
        //rom[2] = 32'h00212383; //LW x7, x2, 2 
        //rom[3] = 32'h00438413; //ADDi x8, x7, 4 
        ////rom[4] = 32'h00838463; //BEQ x7, x8, 8
        //rom[4] = 32'h00840463; //BEQ x8, x8, 8
        //rom[5] = 32'h004182b3; //ADD X5, X3, X4  
        //rom[6] = 32'h00812123; //sw x2, 2(x8), sw x2, x8, 2 
        // ========================================
        //rom[4] = 32'h00d201a3; //SB x4, x13, 3
        //rom[5] = 32'h00320403; //LB x8, x4, 3
        //rom[6] = 32'h00e292a3; //SH x5, x14, 5 
        //rom[7] = 32'h00529483; //LH x9, x5, 5 
        //rom[8] = 32'h00324783; //LBU x8, x7, 4 
        //rom[9] = 32'h0052d883; //LHU x8, x7, 4


        
        //rom[1] = 32'h005201b3;
    end
    //나머지는 초기화 안했으니 X로 채워짐

    //read addr 를 word addr로 변경 
    assign instr_data = rom [instr_addr[31:2]]; //우 shift 2 

endmodule