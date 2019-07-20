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
	output reg MemoryToReg,
	output reg Jump,
	output reg PCFromReg,
	output reg WriteRegFromPC,
	output reg ForceWriteToR31,
	output reg [1:0] SizeOut;
);

always @(*) begin
	
	// NoOp
	if (Instruction == 32'b0) begin
		RegDst = 1'b0;
		RegWriteEnable = 1'b0;
		ALUSrc = 1'b0;
		ALUFunction = 6'b000000;
		MemoryRE = 1'b0;
		MemoryWE = 1'b0;
		MemoryToReg = 1'b0;
		Jump = 1'b0;
		
		PCFromReg = 1'b0;
		WriteRegFromPC = 1'b0;
		ForceWriteToR31 = 1'b0;
	end
	
	// JR
	else if (Instruction[31:26] == 6'b000000 && Instruction[5:0] == 6'b001000) begin
		RegDst = 1'b0;
		ALUSrc = 1'b0;
		ALUFunction = 6'b111010;
		MemoryRE = 1'b0;
		MemoryWE = 1'b0;
		MemoryToReg = 1'b0;
		Jump = 1'b1;
		PCFromReg = 1'b1;
	end
	
		// JALR
	else if (Instruction[31:26] == 6'b000000 && Instruction[5:0] == 6'b001001) begin
		RegWriteEnable =1'b1;
		RegDst = 1'b1;
		ALUSrc = 1'b0;
		ALUFunction = 6'b111010;
		MemoryRE = 1'b0;
		MemoryWE = 1'b0;
		MemoryToReg = 1'b0;
		Jump = 1'b1;
		PCFromReg = 1'b1;
		WriteRegFromPC = 1'b1;
	end
	
	// Simple alu operations
	else if (Instruction[31:26] == 6'b000000) begin 
		RegDst = 1'b1;
		RegWriteEnable = 1'b1;
		ALUSrc = 1'b0;
		ALUFunction = Instruction[5:0];
		MemoryRE = 1'b0;
		MemoryWE = 1'b0;
		MemoryToReg = 1'b0;
		Jump = 1'b0;
		PCFromReg = 1'b0;
		WriteRegFromPC = 1'b0;
		ForceWriteToR31 = 1'b0;
	end
	
	// Immediates.
	else if (Instruction[31:29] == 3'b001) begin
	
		RegDst = 1'b0;
		RegWriteEnable = 1'b1;
		ALUSrc = 1'b1;
		MemoryRE = 1'b0;
		MemoryWE = 1'b0;
		MemoryToReg = 1'b0;
		Jump = 1'b0;
		PCFromReg = 1'b0;
		WriteRegFromPC = 1'b0;
		ForceWriteToR31 = 1'b0;
		
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
		Jump = 1'b0;
		
		PCFromReg = 1'b0;
		WriteRegFromPC = 1'b0;
		ForceWriteToR31 = 1'b0;
		
	end
	
	// SAVE
	else if (Instruction[31:29] == 3'b101) begin
		RegDst = 1'b0;
		RegWriteEnable =1'b0;
		ALUSrc = 1'b1;
		ALUFunction = 6'b100000;
		MemoryRE = 1'b0;
		MemoryWE = 1'b1;
		MemoryToReg = 1'b0;
		
		// SB save byte
		else if (Instruction[28:26] == 3'b000) begin
			SizeOut = 2'b00;
		end
		
		// SH save half
		else if (Instruction[28:26] == 3'b001) begin
			SizeOut = 2'b01;
		end
		
	end
	
		// J and JAL
	else if (Instruction[31:27] == 5'b00001) begin
		RegDst = 1'b0;
		ALUSrc = 1'b0;
		ALUFunction = 6'b111010;
		MemoryRE = 1'b0;
		MemoryWE = 1'b0;
		MemoryToReg = 1'b0;
		Jump = 1'b1;
		PCFromReg = 1'b0;
		
		// JAL
		if (Instruction[26] == 1'b1) begin
			RegWriteEnable =1'b1;
			ForceWriteToR31 = 1'b1;
			WriteRegFromPC = 1'b1;
			
		end
		// J
		else begin
			RegWriteEnable =1'b0;
		end
	end
	
	// Branch
	else if (Instruction[31:29] == 3'b000) begin
		RegDst = 1'b0;
		RegWriteEnable = 1'b0;
		ALUSrc = 1'b0;
		MemoryRE = 1'b0;
		MemoryWE = 1'b0;
		MemoryToReg = 1'b0;
		Jump = 1'b0;
		
		PCFromReg = 1'b0;
		WriteRegFromPC = 1'b0;
		ForceWriteToR31 = 1'b0;
		
		// BEQ
		if (Instruction[28:26] == 3'b100) begin 
			ALUFunction = 6'b111100;
		end
		// BNE
		else if (Instruction[28:26] == 3'b101) begin
			ALUFunction = 6'b111101;			
		end
		// BLTZ and BGEZ
		else if(Instruction[28:26] == 3'b001) begin
			ALUFunction = {5'b11100, Instruction[16]};
		end
		// BLEZ
		else if (Instruction[28:26] == 3'b110) begin
			ALUFunction = 6'b111110;
		end
		// BGTZ
		else if (Instruction[28:26] == 3'b111)	begin
			ALUFunction = 6'b111111;
		end
	end
	
	else  begin
		RegDst = 1'b0;
		RegWriteEnable = 1'b0;
		ALUSrc = 1'b0;
		ALUFunction = 6'b000000;
		MemoryRE = 1'b0;
		MemoryWE = 1'b0;
		MemoryToReg = 1'b0;
		Jump = 1'b0;
		
		PCFromReg = 1'b0;
		WriteRegFromPC = 1'b0;
		ForceWriteToR31 = 1'b0;
		SizeOut = 2'b11;
	end

	
end

endmodule