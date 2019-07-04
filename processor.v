`define PC_RESET 32'h00400000

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

// Reset functionality
always @(*) begin
	if (reset)
		PC = `PC_RESET;
end

/*
inst_rom InstructionMemory(
	.clock(clock),
	.reset(reset),
	.addr_in(), //input - from PC (program counter)
	.data_out()
);
*/


endmodule