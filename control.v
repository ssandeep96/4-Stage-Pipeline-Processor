module control (
	input Clock,
	input Reset,
	input [31:0] Instruction,
	
	output reg RegDst,
	output reg RegWriteEnable,  // controls write on reg_file
	output reg ALUSrc,				// controls ALUMux
	output reg [5:0] ALUFunction,		// controls ALU Func_in
	output reg MemoryRE,
	output reg MemoryWE,
	output reg MemoryToReg
);

always @(*) begin
	
	// Simple alu operations
	if (Instruction[31:26] == 6'b000000) begin 
		RegDst = 1'b1;
		RegWriteEnable = 1'b1;
		ALUSrc = 1'b0;
		ALUFunction = Instruction[5:0];
		MemoryRE = 1'b0;
		MemoryWE = 1'b0;
		MemoryToReg = 1'b0;
	end
	
	// Immediates.
	else if (Instruction[31:29] == 3'b001) begin
	
		RegDst = 1'b0;
		RegWriteEnable = 1'b1;
		ALUSrc = 1'b1;
		MemoryRE = 1'b0;
		MemoryWE = 1'b0;
		MemoryToReg = 1'b0;
		
		// addi
		if(Instruction[28:26] == 3'b000) begin
			ALUFunction = 6'b100000;
		end
		
	end
	
	// Load
	else if (Instruction[31:29] == 3'b100) begin
		RegDst = 1'b0;
		RegWriteEnable =1'b1;
		ALUSrc = 1'b1;
		ALUFunction = 6'b100000;
		MemoryRE = 1'b1;
		MemoryWE = 1'b0;
		MemoryToReg = 1'b1;
		
		// lw
		/*
		if (Instruction[28:26] == 3'b011) begin
			
		end
		*/
		
	end
	
	else if (Instruction[31:29] == 3'b101) begin
		RegDst = 1'b0;
		RegWriteEnable =1'b0;
		ALUSrc = 1'b1;
		ALUFunction = 6'b100000;
		MemoryRE = 1'b0;
		MemoryWE = 1'b1;
		MemoryToReg = 1'b0;
	end
	
end

endmodule