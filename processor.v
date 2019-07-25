//`define PC_RESET 32'h0040_0000
`define PC_RESET 32'h003FFFFC
`define PC_INCREMENT 32'h0000_0004
`define SIGN_EXT_POS 16'h0000
`define SIGN_EXT_NEG 16'hFFFF

module processor(
	input clock,
	input reset,
	//input [31:0] InputInstruction,

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
wire [31:0] PCFromRegisterMuxOut;
wire WriteRegFromPC;
wire [31:0] RegFileWriteMuxOut;
wire ForceWriteToR31;
wire [4:0] ForceWriteToR31MuxOut;
wire [1:0] SizeIn;
wire Unsigned;
wire [31:0] MemoryShifterOut;
wire [31:0] ZeroExtendedNumber;
reg  [31:0] LUIShift;
wire ImmediateFunction;
wire [31:0] ImmediateFunctionTypeMuxOut;
wire UseLUI;
wire [31:0] ALUorLUIMuxOut;

 

// PC adder.
// IF
always @(*) begin
	NextPC = PC + `PC_INCREMENT;
end

// Update the PC value.
// IF
always @(posedge clock) begin
	if (reset)
		PC <= `PC_RESET;
	else begin
		PC <= PCFromRegisterMuxOut;
		//PC <= 32'b0;
	end
end

// EM
assign BranchAddress = (NumberExt << 2) + NextPC;

// ID
assign JumpAddress = {NextPC[31:28],CurrentInstruction[25:0] << 2};

// EM
mux #(32) BranchOrJumpMux (
	.A(JumpAddress),
	.B(BranchAddress),
	.PickA(Jump),
	.out(BranchOrJumpOut)
);

// WB
mux #(32) NextPCMux (
	.A(BranchOrJumpOut),
	.B(NextPC),
	.PickA(ALUBranchOut || ALUJumpOut),
	.out(NextPCMuxOut)
);

// WB
mux #(32) PCFromRegisterMux (
	.A(ALUResult),
	.B(NextPCMuxOut),
	.PickA(PCFromReg),
	.out(PCFromRegisterMuxOut)
);

// IF
inst_rom #(
	.ADDR_WIDTH(10),
	//.INIT_PROGRAM("D:/Documents/School/CSE_141L/Lab_2/nbhelloworld/nbhelloworld.inst_rom.memh")) 
	.INIT_PROGRAM("D:/Documents/School/CSE_141L/Lab_2/fib/fib.inst_rom.memh")) 
	InstructionMemory (
	.clock(clock),
	.reset(reset),
	.addr_in(PCFromRegisterMuxOut), //input - from PC (program counter)
	.data_out(CurrentInstruction)
);

// Controller---------------------------------------------
// ID
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
	.ForceWriteToR31(ForceWriteToR31),
	.SizeOut(SizeIn),
	.Unsigned(Unsigned),
	.ImmediateFunction(ImmediateFunction),
	.UseLUI(UseLUI)
);

// ID output piped to WB
// FOLD into one mux 
mux #(5) InstructMux (
	.B(CurrentInstruction[20:16]),
	.A(CurrentInstruction[15:11]),
	
	.PickA(RegDst),
	.out(InstructMuxOut)
);
mux #(5) ForceWriteToR31Mux (
	.A(5'h1F),
	.B(InstructMuxOut),
	.PickA(ForceWriteToR31),
	.out(ForceWriteToR31MuxOut)
);
//-------------------------------------------

// ID
reg_file RegisterFile (
	.clock(clock),
	.reset(reset),
	
	.read_reg_1(CurrentInstruction[25:21]),
	.read_reg_2(CurrentInstruction[20:16]),
	
	.read_data_1(ReadData1),
	.read_data_2(ReadData2),
	
	.write_reg(ForceWriteToR31MuxOut),	 	
	.write_data(RegFileWriteMuxOut),	
	.write_enable(RegWriteEnable)		
);

// ID
sign_extend SignExt(
	.number(CurrentInstruction[15:0]),
	.numberExt(NumberExt)
);

// ID
zero_extend ZeroExt(
	.number(CurrentInstruction[15:0]),
	.numberExt(ZeroExtendedNumber)
);

// ID RESULT PIPED TO EM
mux #(32) ImmediateFunctionTypeMux (
	.A(ZeroExtendedNumber),
	.B(NumberExt),
	.PickA(ImmediateFunction),
	.out(ImmediateFunctionTypeMuxOut)
);

// ID
// LUIShift
always @(*) begin
	LUIShift = {CurrentInstruction[15:0], 16'h0000};
end

// EM
mux #(32) ALUMux  (
	.A(ImmediateFunctionTypeMuxOut),
	.B(ReadData2),
	.PickA(ALUSrc),
	.out(ALUMuxOut)
);

// EM
alu ALU(
	.Func_in(ALUFunction), 
	.A_in(ReadData1), 
	.B_in(ALUMuxOut),
	.O_out(ALUResult),
	.Branch_out(ALUBranchOut), 
	.Jump_out(ALUJumpOut)
);

// EM
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

// EM
DataShifter MemoryShifter (
	.SizeIn(SizeIn),
	.Data(DataMemoryOut),
	.BytePicker(ALUResult[1:0]),
	.Unsigned(Unsigned),
	.MemoryShifterOut(MemoryShifterOut)
);

// Fold Into One Mux
mux #(32) ALUorLUIMux (
	.A(LUIShift),
	.B(ALUResult),
	.PickA(UseLUI),
	.out(ALUorLUIMuxOut)
);
mux #(32) DataMux  (
	.A(MemoryShifterOut),
	.B(ALUorLUIMuxOut),
	.PickA(MemoryToReg),
	.out(DataMuxOut)
);
mux #(32) RegFileWriteMux(
	.A(NextPC + 4), // PC + 8, so we are over the branch delay instruction after the banch
	.B(DataMuxOut),
	.PickA(WriteRegFromPC),
	.out(RegFileWriteMuxOut)
);
//-------------------------------------------------------------------------------------



endmodule





module DataShifter (
	input [1:0] SizeIn,
	input [31:0] Data,
	input [1:0] BytePicker,
	input Unsigned,
	output reg [31:0] MemoryShifterOut
);

always @(*) begin
	
	MemoryShifterOut = Data;
	
	// NORMAL
	if (SizeIn == 2'b11 || SizeIn == 2'b10) begin
		MemoryShifterOut = Data;
	end
	// BTYE
	else if (SizeIn == 2'b00) begin
	
			if (BytePicker == 2'b00) begin
				MemoryShifterOut = Data;
			end
			else if (BytePicker == 2'b01) 
				MemoryShifterOut = Data >> 8;
			else if (BytePicker == 2'b10) 
				MemoryShifterOut = Data >> 16;
			else if (BytePicker == 2'b11) 
				MemoryShifterOut = Data >> 24;
			
			if (Unsigned) begin
				MemoryShifterOut = {24'b0,MemoryShifterOut[7:0]};
			end
			else begin
				if(MemoryShifterOut[7] == 1'b0)
					MemoryShifterOut = {24'b0,MemoryShifterOut[7:0]};
				else
					MemoryShifterOut = {24'b1111_1111_1111_1111_1111_1111,MemoryShifterOut[7:0]};
			end
	end
	
	// HALF
	else if (SizeIn == 2'b01) begin
	
		if (BytePicker == 2'b00) begin
			MemoryShifterOut = Data;
		end
		if (BytePicker == 2'b01) begin
			MemoryShifterOut = Data >> 16;
		end
		
		if (Unsigned) begin
			MemoryShifterOut = {16'b0,MemoryShifterOut[15:0]};
		end
		else begin
			if (MemoryShifterOut[15] == 1'b0)
				MemoryShifterOut = {16'b0,MemoryShifterOut[15:0]};
			else
				MemoryShifterOut = {16'hffff,MemoryShifterOut[15:0]};
		end	
	end
end
endmodule



module zero_extend(
		input [15:0] number,
	output reg [31:0] numberExt
);

always @(*) begin
	numberExt = {16'h0000,number};
end

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

module mux4 #(parameter W = 1) (
	input [W-1:0] Zero,
	input [W-1:0] One,
	input [W-1:0] Two,
	input [W-1:0] Three,
	input [1:0] Picker,
	output reg [W-1:0] Out
);
	
	always @(*) begin
		if(Picker == 2'b00)
			Out = Zero;
		else if (Picker == 2'b01)
			Out = One;
		else if (Picker == 2'b10)
			Out = Two;
		else if (Picker == 2'b11)
			Out = Three;
	end

endmodule
