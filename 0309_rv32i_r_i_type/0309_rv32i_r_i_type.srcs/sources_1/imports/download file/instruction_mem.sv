`timescale 1ns / 1ps

module instruction_mem (
    //rom은 조합 출력
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    logic [31:0] rom [0:31];

    initial begin
        rom[0] = 32'h004182b3; //ADD X5, X3, X4 
        rom[1] = 32'h402302b3;
        rom[2] = 32'h008193b3;
        rom[3] = 32'h0081a2b3;
        rom[4] = 32'h0081b2b3;
        rom[5] = 32'h00954433;
        rom[6] = 32'h0081d3b3;
        rom[7] = 32'h4042d333;
        rom[8] = 32'h004161b3;
        rom[9] = 32'h005273b3;
    end
    //나머지는 초기화 안했으니 X로 채워짐

    //read addr 를 word addr로 변경 
    assign instr_data = rom [instr_addr[31:2]]; //우 shift 2 

endmodule
