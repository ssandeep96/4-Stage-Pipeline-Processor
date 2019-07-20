//`define PC_RESET 32'h0040_0000
`define PC_RESET 32'h003FFFFC
`define PC_INCREMENT 32'h0000_0004
`define SIGN_EXT_POS 16'h0000
`define SIGN_EXT_NEG 16'hFFFF

module processor(
	input clock,
	input reset,

	//these ports are used for serial IO and 
	//must be wired up to the data_memory module
	input [7:0] serial_in,
	input serial_valid_in,
	input serial_ready_in,
	output [7:0] serial_out,
	output serial_rden_out,
	output serial_wren_out
);

// TODO: set up the processor here.

reg [31:0] PC;
reg [31:0] NextPC;
wire [31:0] CurrentInstruction;
wire RegDst;
wire RegWriteEnable;
wire ALUSrc;
wire [31:0] ALUMuxOut;
wire [31:0] NumberExt;
wire [4:0] InstructMuxOut;
wire [31:0] ReadData1;
wire [31:0] ReadData2;
wire [31:0] DataMuxOut;
wire [31:0] ALUResult;
wire ALUBranchOut;
wire ALUJumpOut;
wire [31:0] DataMemoryOut;
wire [5:0] ALUFunction;
wire MemoryRE;
wire MemoryWE;
wire MemoryToReg;
wire [31:0] BranchAddress;
wire [31:0] BranchOrJumpOut;
wire [31:0] JumpAddress;
wire Jump;
wire [31:0] NextPCMuxOut;
wire PCFromReg;
wire PCFromRegisterMuxOut;
wire WriteRegFromPC;
wire [31:0] RegFileWriteMuxOut;
wire [31:0] ForceWriteToR31;
wire [1:0] SizeIn;

// PC adder.
always @(*) begin
	NextPC = PC + `PC_INCREMENT;
end

// Update the PC value.
always @(posedge clock) begin
	if (reset)
		PC <= `PC_RESET;
	else begin
		PC <= PCFromRegisterMuxOut;
	end
end

mux #(32) NextPCMux (
	.A(BranchOrJumpOut),
	.B(NextPC),
	.PickA(ALUBranchOut || ALUJumpOut),
	.out(NextPCMuxOut)
);

mux #(32) PCFromRegisterMux (
	.A(DataMuxOut),
	.B(NextPCMuxOut),
	.PickA(PCFromReg),
	.out(PCFromRegisterMuxOut)
);
// Controller---------------------------------------------
control Controller(
	.Clock(clock),
	.Reset(reset),
	.Instruction(CurrentInstruction),
	.RegDst(RegDst),
	.RegWriteEnable(RegWriteEnable),
	.ALUSrc(ALUSrc),
	.ALUFunction(ALUFunction),
	.MemoryRE(MemoryRE),
	.MemoryWE(MemoryWE),
	.MemoryToReg(MemoryToReg),
	.Jump(Jump),
	.PCFromReg(PCFromReg),
	.WriteRegFromPC(WriteRegFromPC),
	.ForceWriteToR31(ForceWriteToR31)
);

inst_rom #(
	.ADDR_WIDTH(10),
	.INIT_PROGRAM("D:/Documents/School/CSE_141L/Lab_2/nbhelloworld/nbhelloworld.inst_rom.memh")) 
	InstructionMemory (
	.clock(clock),
	.reset(reset),
	.addr_in(NextPC), //input - from PC (program counter)
	.data_out(CurrentInstruction)
);

mux #(5) InstructMux (
	.B(CurrentInstruction[20:16]),
	.A(CurrentInstruction[15:11]),
	
	.PickA(RegDst),
	.out(InstructMuxOut)
);

mux #(32) RegFileWriteMux(
	.A(NextPC + 4), // PC + 8, so we are over the branch delay instruction after the banch
	.B(DataMuxOut),
	.PickA(WriteRegFromPC),
	.out(RegFileWriteMuxOut)
);

mux #(32) ForceWriteToR31Mux (
	.A(5'h1F),
	.B(InstructMuxOut),
	.PickA(ForceWriteToR31),
	.out(ForceWriteToR31Out)
);

reg_file RegisterFile (
	.clock(clock),
	.reset(reset),
	
	.read_reg_1(CurrentInstruction[25:21]),
	.read_reg_2(CurrentInstruction[20:16]),
	
	.read_data_1(ReadData1),
	.read_data_2(ReadData2),
	
	.write_reg(ForceWriteToR31Out),	 	
	.write_data(RegFileWriteMuxOut),	
	.write_enable(RegWriteEnable)		
);


sign_extend SignExt(
	.number(CurrentInstruction[15:0]),
	.numberExt(NumberExt)
);

assign BranchAddress = NumberExt << 2 + NextPC;
assign JumpAddress = {NextPC[31:28],CurrentInstruction[25:0] << 2};

mux #(32) BranchOrJumpMux (
	.A(JumpAddress),
	.B(BranchAddress),
	.PickA(Jump),
	.out(BranchOrJumpOut)
);



mux #(32) ALUMux  (
	.A(NumberExt),
	.B(ReadData2),
	.PickA(ALUSrc),
	.out(ALUMuxOut)
);


alu ALU(
	.Func_in(ALUFunction), 
	.A_in(ReadData1), 
	.B_in(ALUMuxOut),
	.O_out(ALUResult),
	.Branch_out(ALUBranchOut), 
	.Jump_out(ALUJumpOut)
);



data_memory DataMemory (
	.clock(clock),
	.reset(reset),

	.addr_in(ALUResult),
	.writedata_in(ReadData2),
	.re_in(MemoryRE),
	.we_in(MemoryWE),
	.size_in(SizeIn),
	.readdata_out(DataMemoryOut),
	
	.serial_in(serial_in),
	.serial_ready_in(serial_ready_in),
	.serial_valid_in(serial_valid_in),
	.serial_out(serial_out),
	.serial_rden_out(serial_rden_out),
	.serial_wren_out(serial_wren_out)
);

mux #(32) DataMux  (
	.A(DataMemoryOut),
	.B(ALUResult),
	.PickA(MemoryToReg),
	.out(DataMuxOut)
);

endmodule









module sign_extend(
	input [15:0] number,
	output [31:0] numberExt
);

reg [31:0] outReg;
assign numberExt = outReg;
always @(*) begin
	// if positive
 	if(number[15] == 1'b0) begin
		outReg = {`SIGN_EXT_POS, number};
	end
	// if negative
	else begin
		outReg = {`SIGN_EXT_NEG, number};
	end
end


endmodule



module mux #(parameter W = 1) (
	input [W-1:0] A,
	input [W-1:0] B,
	input PickA,
	output [W-1:0] out
);
	
	assign out = PickA ? A : B;

endmodule
