module control (
	input Clock,
	input Reset,
	input [31:0] Instruction,
	
	output RegDst,
	output RegWriteEnable,  // controls write on reg_file
	output ALUSrc,				// controls ALUMux
	output [5:0] ALUFunction,		// controls ALU Func_in
	output MemoryRE,
	output MemoryWE,
	output MemoryToReg
);

always @(*) {
	ALUSrc = Instruction[2] || Instruction[0];
	
	if (Instruction[1:0] == 2'b00) begin
		RegDst = Instruction[2];
	end
	
	
}

endmodule