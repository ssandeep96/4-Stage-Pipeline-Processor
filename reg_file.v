// Register File. We need to write this.
`define ZERO_VALUE 32'h00000000

module reg_file (
	input clock,
	input reset,
	
	input [4:0] read_reg_1,
	input [4:0] read_reg_2,
	
	output [31:0] read_data_1,
	output [31:0] read_data_2,
	
	input [4:0] write_reg,	// address of reg to write to.
	input [31:0] write_data,	// data to write
	input write_enable		
	);

// The registers. Make sure register ZERO(0) is always zero.
reg [31:0] registers [31:0];

reg [31:0] reg_1_out;
reg [31:0] reg_2_out;

assign read_data_1 = reg_1_out;
assign read_data_2 = reg_2_out;	

// Write only occurs on positve edge of clock, if write_enable is true.
// also reset is handled in this block.
always @(posedge clock) begin
	
	// Reset all the register values to 0.
	if (reset) begin
		registers[0] = `ZERO_VALUE;
		registers[1] = `ZERO_VALUE;
		registers[2] = `ZERO_VALUE;
		registers[3] = `ZERO_VALUE;
		
		registers[4] = `ZERO_VALUE;
		registers[5] = `ZERO_VALUE;
		registers[6] = `ZERO_VALUE;
		registers[7] = `ZERO_VALUE;
		
		registers[8] = `ZERO_VALUE;
		registers[9] = `ZERO_VALUE;
		registers[10] = `ZERO_VALUE;
		registers[11] = `ZERO_VALUE;
		
		registers[12] = `ZERO_VALUE;
		registers[13] = `ZERO_VALUE;
		registers[14] = `ZERO_VALUE;
		registers[15] = `ZERO_VALUE;
		
		registers[16] = `ZERO_VALUE;
		registers[17] = `ZERO_VALUE;
		registers[18] = `ZERO_VALUE;
		registers[19] = `ZERO_VALUE;
		
		registers[20] = `ZERO_VALUE;
		registers[21] = `ZERO_VALUE;
		registers[22] = `ZERO_VALUE;
		registers[23] = `ZERO_VALUE;
		
		registers[24] = `ZERO_VALUE;
		registers[25] = `ZERO_VALUE;
		registers[26] = `ZERO_VALUE;
		registers[27] = `ZERO_VALUE;
		
		registers[28] = `ZERO_VALUE;
		registers[29] = `ZERO_VALUE;
		registers[30] = `ZERO_VALUE;
		registers[31] = `ZERO_VALUE;
	end
	else if (write_enable) begin
		// Make sure we don't overwrite the ZERO register's value.
		if (write_reg != 5'b00000) begin
			registers[write_reg] = write_data;
		end
 	end
	
end

// Data out is handled here.
always @(negedge clock) begin
	reg_1_out <= registers[read_reg_1];
	reg_2_out <= registers[read_reg_2];
end	
	
endmodule