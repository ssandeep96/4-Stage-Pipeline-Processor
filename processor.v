`define PC_RESET 8'h00400000
`define PC_INCREMENT 8'h00000004

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



/*
inst_rom InstructionMemory(
	.clock(clock),
	.reset(reset),
	.addr_in(), //input - from PC (program counter)
	.data_out()
);

module reg_file RegisterFile (
	.clock(clock),
	.clock(reset),
	
	.read_reg_1(),
	.read_reg_2(),
	
	.read_data_1(),
	.read_data_2(),
	
	.write_reg(),	
	.write_data(),	
	.write_enable()		
);
*/

endmodule

module mux #(parameter W = 1) (
	input [W-1:0] A,
	input [W-1:0] B,
	input PickA,
	output [W-1:0] out
);
	
	assign out = PickA ? A : B;

endmodule
