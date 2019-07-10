`define PC_RESET 8'h00400000
`define PC_INCREMENT 8'h00000004
`define SIGN_EXT_POS 4'h0000
`define SIGN_EXT_NEG 4'hFFFF

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

// PC adder.
always @(*) begin
	NextPC = PC + `PC_INCREMENT;
end

// Update the PC value.
always @(posedge clock) begin
	if (reset)
		PC <= `PC_RESET;
	else begin
		PC <= NextPC;
	end
end



wire [31:0] CurrentInstruction;

inst_rom #(.INIT_PROGRAM("C:/Users/Sandeep/Desktop/CSE141L/lab2/CSE_141L_Lab2/blank.memh")) InstructionMemory (
	.clock(clock),
	.reset(reset),
	.addr_in(NextPC), //input - from PC (program counter)
	.data_out(CurrentInstruction)
);


wire [31:0] InstructMuxOut;
mux #(5) InstructMux (
	.B(CurrentInstruction[20:16]),
	.A(CurrentInstruction[15:11]),
	
	.PickA(1'b0),
	.out(InstructMuxOut)
);


wire [31:0] ReadData1;
wire [31:0] ReadData2;

reg_file RegisterFile (
	.clock(clock),
	.reset(reset),
	
	.read_reg_1(CurrentInstruction[25:21]),
	.read_reg_2(CurrentInstruction[20:16]),
	
	.read_data_1(ReadData1),
	.read_data_2(ReadData2),
	
	.write_reg(InstructMuxOut),	
	.write_data(DataMuxOut),	
	.write_enable(1'b0)		
);

wire [31:0] NumberExt;
sign_extend SignExt(
	.number(CurrentInstruction[15:0]),
	.numberExt(NumberExt)
);


wire [31:0] ALUMuxOut;
mux #(32) ALUMux  (
	.A(NumberExt),
	.B(ReadData2),
	.PickA(1'b0),
	.out(ALUMuxOut)
);

wire [31:0] ALUResult;

alu ALU(
	.Func_in(6'b000000), 
	.A_in(ReadData1), 
	.B_in(ALUMuxOut),
	.O_out(ALUResult)
);


wire [31:0] DataMemoryOut;
data_memory DataMemory (
	.clock(clock),
	.reset(reset),

	.addr_in(ALUResult),
	.writedata_in(ReadData2),
	.re_in(1'b0),
	.we_in(1'b0),
	.size_in(2'b00),
	.readdata_out(DataMemoryOut),
	
	.serial_in(serial_in),
	.serial_ready_in(serial_ready_in),
	.serial_valid_in(serial_valid_in),
	.serial_out(serial_out),
	.serial_rden_out(serial_rden_out),
	.serial_wren_out(serial_wren_out)
);

/*
module data_memory(
	input clock,
	input reset,

	input		[31:0]	addr_in,
	input		[31:0]	writedata_in,
	input					re_in,
	input					we_in,
	input		[1:0]		size_in,
	output	reg [31:0]	readdata_out,
	
	//serial port connection that need to be routed out of the process
	input		[7:0]		serial_in,
	input					serial_ready_in,
	input					serial_valid_in,
	output	[7:0]		serial_out,
	output				serial_rden_out,
	output				serial_wren_out
);
*/
wire [31:0] DataMuxOut;
mux #(32) DataMux  (
	.A(DataMemoryOut),
	.B(ALUResult),
	.PickA(1'b0),
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
