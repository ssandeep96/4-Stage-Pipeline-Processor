`timescale 1ns/1ps

module testbench();

reg clock;
reg reset;

wire [7:0] serial_out;
wire serial_wren;

// Generate clock at 100 MHz.
initial begin
	clock <= 1'b0;
	reset <= 1'b1;
	forever #10 clock <= ~clock;
end

// Drop reset after 200 ns.
always begin
	#200 reset <= 1'b0;
end
	
	
// instantiate the processor  "DUT".
processor dut(
	.clock(clock),
	.reset(reset),
	
	.serial_in(8'b0),
	.serial_valid_in(1'b0), //active-high - we never have anything to read from the serial port
	.serial_ready_in(1'b1), //active-high - we are always ready to print serial data
	.serial_rden_out(), 		//active-high
	.serial_out(serial_out),
	.serial_wren_out(serial_wren) //active-high
);

reg [4:0] write_addr;
reg [31:0] write_data;
reg write_enable;

reg [4:0] read_addr_1;
reg [4:0] read_addr_2;

wire [31:0] read_data_1;
wire [31:0] read_data_2;

reg picker;
wire [15:0] MuxOut;

reg [15:0] testNumber = 16'h0FFF;
wire [31:0] testNumberExtend;

// increment setting each register, and reading the set and previously read register.
always @(posedge clock) begin

	if(reset) begin
		write_addr <= 5'b00000;
		write_data <= 5'b00000;
		read_addr_1 <= 5'b00000;
		read_addr_2 <= 5'b00001;
		picker <= 1'b0;
	end
	else begin
		//write_addr <= write_addr + 5'b00001;
		//write_data <= write_data + 5'b00001;
		write_addr <= 32'h00000000;
		write_data <= 32'h0000_0001;
		picker <= ~|picker;
		//read_addr_1 <= read_addr_1 + 5'b00001;
		//read_addr_2 <= read_addr_2 + 5'b00001;
	end
	
	//write_data <= write_addr;
	read_addr_1 <= write_addr;
	read_addr_2 <= write_addr - 5'b00001;
	write_enable <= 1'b1;
end

// Test of Register File functionality.
reg_file file_test(
	.clock(clock),
	.reset(reset),
	
	.read_reg_1(read_addr_1),
	.read_reg_2(read_addr_2),
	
	.read_data_1(read_data_1),
	.read_data_2(read_data_2),
	
	.write_reg(write_addr),	// address of reg to write to.
	.write_data(write_data),	// data to write
	.write_enable(write_enable)
	);
	
mux #(16) test_mux (
	.A(16'hFFFF),
	.B(16'h0000),
	.PickA(picker),
	.out(MuxOut)
);

sign_extend test_sign_extender(
	.number(testNumber),
	.numberExt(testNumberExtend)
);

//This will print out a message whenever the serial port is written to
always @(posedge clock) begin
	if (reset) begin
	end else begin
		if (serial_wren) begin
				$display("[%0d] Serial: %c",$time,serial_out);
		end
	end
end


endmodule