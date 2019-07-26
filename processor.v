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
reg [31:0] NextPCID;
reg [31:0] NextPCEM;
reg [31:0] NextPCWB;

wire [31:0] CurrentInstruction;
reg [31:0] CurrentInstructionID;

wire RegDst;

wire RegWriteEnable;
reg RegWriteEnableEM;
reg RegWriteEnableWB;

wire ALUSrc;
reg ALUSrcEM;

wire [5:0] ALUFunction;
reg [5:0] ALUFunctionEM;

wire [31:0] ALUMuxOut; // EM DONE
wire [31:0] NumberExt;
wire [4:0] InstructMuxOut;

wire [31:0] DataMuxOut;




wire [31:0] DataMemoryOut;

// Control Signals
wire MemoryRE;
reg MemoryRE_EM;
wire MemoryWE;
reg MemoryWE_EM;

wire MemoryToReg;
reg MemoryToRegEM;
reg MemoryToRegWB;

wire UseLUI;
reg UseLUI_EM;
reg UseLUI_WB;

wire Jump;	// created in the ID
reg JumpEM;

wire PCFromReg;
reg PCFromRegEM;
reg PCFromRegWB;

wire WriteRegFromPC;
reg WriteRegFromPC_EM;
reg WriteRegFromPC_WB;

wire ForceWriteToR31;

wire ImmediateFunction;
wire Unsigned;
reg UnsignedEM;

wire [1:0] SizeIn;
reg [1:0] SizeInEM;


// Processor wires/regs
wire [31:0] BranchAddress;		// EM DONE

wire [31:0] JumpAddress;		// EM DONE
reg [31:0] JumpAddressEM;

wire [4:0] ForceWriteToR31MuxOut; // WB DONE
reg [4:0] ForceWriteToR31MuxOutEM;
reg [4:0] ForceWriteToR31MuxOutWB;

wire [31:0] ReadData1; // EM DONE
reg [31:0] ReadData1EM;
wire [31:0] ReadData2; // EM DONE
reg [31:0] ReadData2EM;

wire [31:0] ImmediateFunctionTypeMuxOut; // EM DONE
reg  [31:0] ImmediateFunctionTypeMuxOutEM;

reg  [31:0] LUIShift; // WB DONE
reg  [31:0] LUIShiftEM;
reg  [31:0] LUIShiftWB;

wire [31:0] BranchOrJumpOut;  // WB DONE
reg  [31:0] BranchOrJumpOutWB;

wire [31:0] ALUResult; // EM and WB DONE
reg  [31:0] ALUResultWB;

wire ALUBranchOut; // WB DONE
reg  ALUBranchOutWB;
wire ALUJumpOut;  // WB DONE
reg  ALUJumpOutWB;

wire [31:0] MemoryShifterOut;		// WB DONE
reg  [31:0] MemoryShifterOutWB;

wire [31:0] NextPCMuxOut;
wire [31:0] PCFromRegisterMuxOut;
wire [31:0] RegFileWriteMuxOut;
wire [31:0] ZeroExtendedNumber;
wire [31:0] ALUorLUIMuxOut;

// PC adder.
// IF DONE
always @(*) begin
	NextPC = PC + `PC_INCREMENT;
end

// Update the PC value.
// IF DONE
always @(posedge clock) begin
	if (reset)
		PC <= `PC_RESET;
	else begin
		PC <= PCFromRegisterMuxOut;
		//PC <= 32'b0;
	end
end

// EM DONE
assign BranchAddress = (NumberExt << 2) + NextPCEM;

// ID DONE
assign JumpAddress = {NextPCID[31:28], CurrentInstructionID[25:0] << 2};

// EM
mux #(32) BranchOrJumpMux (
	.A(JumpAddressEM),
	.B(BranchAddress),
	.PickA(JumpEM),
	.out(BranchOrJumpOut)
);

// WB
mux #(32) NextPCMux (
	.A(BranchOrJumpOutWB),
	.B(NextPC), // THIS remains un-pipelined.
	.PickA(ALUBranchOutWB || ALUJumpOutWB),
	.out(NextPCMuxOut)
);

// WB
mux #(32) PCFromRegisterMux (
	.A(ALUResultWB),
	.B(NextPCMuxOut),
	.PickA(PCFromRegWB),
	.out(PCFromRegisterMuxOut)
);

// IF DONE
inst_rom #(
	.ADDR_WIDTH(10),
	.INIT_PROGRAM("D:/Documents/School/CSE_141L/Lab_2/nbhelloworld/nbhelloworld.inst_rom.memh")) 
	//.INIT_PROGRAM("D:/Documents/School/CSE_141L/Lab_2/fib/fib.inst_rom.memh")) 
	InstructionMemory (
	.clock(clock),
	.reset(reset),
	.addr_in(PCFromRegisterMuxOut), //input - from PC (program counter)
	.data_out(CurrentInstruction)
);

// Controller---------------------------------------------
// ID DONE
control Controller(
	.Clock(clock),
	.Reset(reset),
	
	.Instruction(CurrentInstructionID),	// DONE
	.RegDst(RegDst),	// ID
	.RegWriteEnable(RegWriteEnable),  // used in WB
	.ALUSrc(ALUSrc), // EM  
	.ALUFunction(ALUFunction), // EM DONE
	.MemoryRE(MemoryRE),	// EM DONE
	.MemoryWE(MemoryWE), // EM DONE
	.MemoryToReg(MemoryToReg), // WB DONE  
	.Jump(Jump), // EM DONE
	.PCFromReg(PCFromReg), // WB DONE determines if PC uses reg instead of branch and jump.
	.WriteRegFromPC(WriteRegFromPC), // WB DONE
	.ForceWriteToR31(ForceWriteToR31), // ID DONE
	.SizeOut(SizeIn),	// EM DONE
	.Unsigned(Unsigned), // EM DONE
	.ImmediateFunction(ImmediateFunction), // ID DONE
	.UseLUI(UseLUI) // WB DONE
);

// ID output piped to WB DONE
// think of as one mux
mux #(5) InstructMux (
	.B(CurrentInstructionID[20:16]),
	.A(CurrentInstructionID[15:11]),
	
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

// ID for Reading, but the write part is used in WB
reg_file RegisterFile (
	.clock(clock),
	.reset(reset),
	
	// ID DONE
	.read_reg_1(CurrentInstructionID[25:21]),
	.read_reg_2(CurrentInstructionID[20:16]),
	.read_data_1(ReadData1), // 
	.read_data_2(ReadData2),
	
	// WB
	.write_reg(ForceWriteToR31MuxOutWB),	// done 	
	.write_data(RegFileWriteMuxOut),	
	.write_enable(RegWriteEnableWB)		
);

// Instruction block ----------------------- DONE
// ID DONE
sign_extend SignExt(
	.number(CurrentInstructionID[15:0]),
	.numberExt(NumberExt)
);

// ID DONE
zero_extend ZeroExt(
	.number(CurrentInstructionID[15:0]),
	.numberExt(ZeroExtendedNumber)
);

// ID DONE RESULT PIPED TO EM 
mux #(32) ImmediateFunctionTypeMux (
	.A(ZeroExtendedNumber),
	.B(NumberExt),
	.PickA(ImmediateFunction),
	.out(ImmediateFunctionTypeMuxOut) // piped to EM
);
//-----------------------------------------

// EM DONE!
mux #(32) ALUMux  (
	.A(ImmediateFunctionTypeMuxOutEM), // done
	.B(ReadData2EM),
	.PickA(ALUSrcEM),
	.out(ALUMuxOut)
);

// EM DONE
alu ALU(
	.Func_in(ALUFunctionEM), 
	.A_in(ReadData1EM), 
	.B_in(ALUMuxOut),
	
	.O_out(ALUResult), // DONE
	.Branch_out(ALUBranchOut), // DONE
	.Jump_out(ALUJumpOut) // DONE
);

// EM DONE
data_memory DataMemory (
	.clock(clock),
	.reset(reset),

	.addr_in(ALUResult),
	.writedata_in(ReadData2EM),
	.re_in(MemoryRE_EM),
	.we_in(MemoryWE_EM),
	.size_in(SizeInEM),
	
	.readdata_out(DataMemoryOut), // DONE
	
	.serial_in(serial_in),
	.serial_ready_in(serial_ready_in),
	.serial_valid_in(serial_valid_in),
	.serial_out(serial_out),
	.serial_rden_out(serial_rden_out),
	.serial_wren_out(serial_wren_out)
);

// EM DONE OUTPUT PIPIED TO WB
DataShifter MemoryShifter (
	.SizeIn(SizeInEM),
	.Data(DataMemoryOut),
	.BytePicker(ALUResult[1:0]),
	.Unsigned(UnsignedEM),
	.MemoryShifterOut(MemoryShifterOut)
);

// ID DONE
// LUIShift
always @(*) begin
	LUIShift = {CurrentInstructionID[15:0], 16'h0000};
end

// WB
// Fold Into One Mux ------
mux #(32) ALUorLUIMux (
	.A(LUIShiftWB),
	.B(ALUResultWB),
	.PickA(UseLUI_WB),
	.out(ALUorLUIMuxOut)
);
mux #(32) DataMux  (
	.A(MemoryShifterOutWB),
	.B(ALUorLUIMuxOut),
	.PickA(MemoryToRegWB),
	.out(DataMuxOut)
);
mux #(32) RegFileWriteMux(
	.A(NextPCWB + 4), // PC + 8, so we are over the branch delay instruction after the banch
	.B(DataMuxOut),
	.PickA(WriteRegFromPC_WB),
	.out(RegFileWriteMuxOut) // input into the RegisterFile's write step. Writting done durring WB.
);
//-------------------------------------------------------------------------------------

//---PIPELINE---
// IF -> ID DONE
always @(posedge clock) begin
	CurrentInstructionID <= CurrentInstruction;
	NextPCID <= NextPC;
end

// ID -> EM DONE
always @(posedge clock) begin
	NextPCEM <= NextPCID;
	
	// Control signals.
	RegWriteEnableEM <= RegWriteEnable;
	ALUSrcEM <= ALUSrc;
	ALUFunctionEM <= ALUFunction;
	MemoryRE_EM <= MemoryRE;
	MemoryWE_EM <= MemoryWE;
	MemoryToRegEM <= MemoryToReg;
	JumpEM <= Jump;
	PCFromRegEM <= PCFromReg;
	WriteRegFromPC_EM <= WriteRegFromPC;
	SizeInEM <= SizeIn;
	UnsignedEM <= Unsigned;
	UseLUI_EM <= UseLUI;
	
	// processor wires
	JumpAddressEM <= JumpAddress;
	ForceWriteToR31MuxOutEM <= ForceWriteToR31MuxOut;
	ReadData1EM <= ReadData1;
	ReadData2EM <= ReadData2;
	ImmediateFunctionTypeMuxOutEM <= ImmediateFunctionTypeMuxOut;
	LUIShiftEM <= LUIShift;
end

// EM -> WB
always @(posedge clock) begin
	NextPCWB <= NextPCEM;
	RegWriteEnableWB <= RegWriteEnableEM;
	MemoryToRegWB <= MemoryToReg;
	PCFromRegWB <= PCFromRegEM;
	WriteRegFromPC_WB <= WriteRegFromPC_EM;
	UseLUI_WB <= UseLUI_EM;
	ForceWriteToR31MuxOutWB <= ForceWriteToR31MuxOutEM;
	LUIShiftWB <= LUIShiftEM;
	BranchOrJumpOutWB <= BranchOrJumpOut;
	ALUResultWB <= ALUResult;
	ALUBranchOutWB <= ALUBranchOut;
	ALUJumpOutWB <= ALUJumpOut;
	MemoryShifterOutWB <= MemoryShifterOut;
end

endmodule










// ----- MODULES-------------------------------------------------------------

module ForwardingUnit (
	input RegWriteEnableInst1, // From controler.
	input [4:0] DestinationRegInst1, // FROM MUX
	input [31:0] Instruction2,
	output ForwardA, // Controls muxA
	output ForwardB // Controls muxB
	);

	// Determine the parameters of #2 instruction.
	
	// Check if destination of #1 is equal to the paramter of #2.
	
	// Forward data appropriately.
	
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
