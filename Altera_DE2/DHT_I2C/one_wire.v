`timescale 1ns / 1ps

module one_wire(
   input wire rst, clk,
	inout wire dht_io,
	
   input wire [4:0] BTN,
   input wire [7:0] I2C_project_step,
	
	input wire ws2812_step,
	
   output wire I2C_button_step,
	output wire [7:0] value_one_wire_1, value_one_wire_2, value_one_wire_3, value_one_wire_4,
	
   output reg [5:0] LEDR,
	output reg [8:0] LEDG
   );
	
	//init I2C
	reg I2C_button_step_reg;
	
	reg [31:0] cnt;
	reg [23:0] counter;
	reg [3:0] state;
	reg dht_io_out; // write value out when in output mode
	reg dht_io_oe;  // 1 = output mode, 0 = input mode
	wire dht_io_in; // read the pin
	 
	reg [7:0] rh_int, rh_dec;
	reg [7:0] temp_int, temp_dec;
	reg [39:0] data_store_temp;
	reg [7:0] checksum;
	reg [5:0] bit_count;
	reg [1:0] read_state;
	
	reg [2:0] BTNisPressed;
	
	// wire data out
	assign value_one_wire_1 = data_store_temp[23:16] / 10 + 48; // temp_int
	assign value_one_wire_2 = data_store_temp[23:16] % 10 + 48;
	assign value_one_wire_3 = data_store_temp[15:8] / 10 + 48;
	assign value_one_wire_4 = data_store_temp[15:8] % 10 + 48;
	

	assign dht_io     = dht_io_oe ? dht_io_out : 1'bz; // Tri-state buffer
	assign dht_io_in  = dht_io; // Input read
	
	assign I2C_button_step = I2C_button_step_reg;

	localparam CLK_1US          = 50;              // 50 MHz clock = 50 ticks per microsecond
	localparam START_LOW_US     = 20_000;          // 20 milliseconds
	localparam START_LOW        = START_LOW_US * CLK_1US;  // 1,000,000 cycles (20 ms)
	localparam WAIT_RESPONSE_US = 40;              // 40 microseconds
	localparam WAIT_RESPONSE    = WAIT_RESPONSE_US * CLK_1US;  // 2,000 cycles
	localparam DELAY_80_US      = 85;              // 80 microseconds
	localparam DELAY_80         = DELAY_80_US * CLK_1US;  // 4,000 cycles
	localparam WRITE_DELAY_US   = 50;              // 50 microseconds
	localparam WRITE_DELAY      = WRITE_DELAY_US * CLK_1US;  // 2,500 cycles
	
	localparam counter_value = 10_000_000;

	localparam STATE_IDLE       = 0;
	localparam STATE_START_LOW  = 1;
	localparam STATE_WAIT_HIGH  = 2;
	localparam STATE_WAIT_RESP_LOW  = 3;
	localparam STATE_WAIT_RESP_HIGH = 4;
	localparam STATE_READ_DATA  = 5;
	localparam STATE_WAIT_CHECKSUM = 6;
	localparam STATE_CHECKSUM = 7;
	localparam STATE_DONE = 8;
    
	always @(posedge clk or negedge rst) begin
	if (!rst) begin // HIGH active
		state <= STATE_IDLE;
		dht_io_oe <= 0; // switch to input mode
		dht_io_out <= 1; // start to write value
		LEDR <= 6'd0;
		LEDG <= 9'd0;
		rh_int <= 8'd0;
		rh_dec <= 8'd0;
		temp_int <= 8'd0;
		temp_dec <= 8'd0;
		checksum <= 8'd0;
		read_state <= 2'b00;
		data_store_temp <= 40'd0;
		cnt <= 0;
		counter <= 24'd0;
		BTNisPressed <= 3'd0;
		I2C_button_step_reg <= 1'b0;
		bit_count <= 0;
	end else begin
		case(I2C_project_step)         
			1: begin
				//LEDR[2] <= 1'b1;
				case(I2C_button_step_reg)
					1'b0: begin
						//LEDR[1] <= 1'b1;
						// counter = (counter > counter_value) ? 0 : (counter + 1);
					   case (BTN)
							  5'b00001: begin 
									BTNisPressed <= 1;
//									LEDR[1] <= 1'b1;
							  end
							  default: begin end
                  endcase
						
						case(BTNisPressed)
							  1: begin
									LEDR[0] <= 1'b1; // led 8
									case (state)
											STATE_IDLE: begin
											dht_io_oe <= 1;         // Output mode
											dht_io_out <= 0;        // Pull line LOW
											cnt <= cnt + 1;

											// RESET
											state <= (cnt > START_LOW) ? STATE_START_LOW : STATE_IDLE;
										end

										
										STATE_START_LOW: begin
											if (cnt > WAIT_RESPONSE) begin // 40us
												dht_io_out <= 1; // pull high, release line
												dht_io_oe <= 0; // switch to input
												state <= STATE_WAIT_HIGH;
											end else begin
												cnt <= cnt + 1;
											end
										end	
											
										STATE_WAIT_HIGH: begin
											if (dht_io_in == 0) begin
												state <= STATE_WAIT_RESP_LOW;
											end
										end
										
										STATE_WAIT_RESP_LOW: begin // detect DHT response
											if (cnt > DELAY_80) begin
												cnt <= 0;
												state <= STATE_WAIT_RESP_HIGH;
											end else begin
												cnt <= cnt + 1;
											end
										end
										
										STATE_WAIT_RESP_HIGH: begin // DHT pull up state
											if (dht_io_in == 1) begin
												cnt <= cnt + 1;
												if (cnt > DELAY_80) begin
													cnt <= 0;
													state <= STATE_READ_DATA;
												end
											end else begin
												cnt <= 0; // Reset counter if line goes LOW too early
											end
										end
										
										STATE_READ_DATA: begin
											case (read_state)
												2'b00: begin
													// starting bit: LOW
													if (dht_io_in == 1'b0) begin
														cnt <= 0;
														read_state <= 2'b01;
														LEDR[1] <= 1'b1; // led 9
													end
												end

												2'b01: begin
													// starting bit: HIGH
													if (dht_io_in == 1'b1) begin
														cnt <= 0;
														read_state <= 2'b10;
														LEDR[2] <= 1'b1; // led 10
													end
												end

												2'b10: begin
													// measure bit HIGH
													if (dht_io_in == 1'b1) begin
														cnt <= cnt + 1;
														LEDR[3] <= 1'b1; // led 11
													end else begin
														// end of bit, falling to LOW => store bit value
														if (bit_count < 6'd40) begin
															data_store_temp <= {data_store_temp[38:0], (cnt > WRITE_DELAY)};
															bit_count <= bit_count + 1;
														end

														// check bit_count is enough 40 bit yet or not
														if (bit_count == 6'd39) begin
															state <= STATE_WAIT_CHECKSUM;
															LEDR[4] <= 1'b1; // led 12
														end

														cnt <= 0;
														read_state <= 2'b00;
													end
												end
											endcase
										end
										
										STATE_WAIT_CHECKSUM: begin
											state <= STATE_CHECKSUM;
										end
										
										STATE_CHECKSUM: begin
											LEDR[5] <= 1'b1; // led 13
											rh_int    <= data_store_temp[39:32];
											rh_dec    <= data_store_temp[31:24];
											temp_int  <= data_store_temp[23:16];
											temp_dec  <= data_store_temp[15:8];
											checksum  <= data_store_temp[7:0];
											state <= STATE_DONE;
										end
										
										STATE_DONE: begin
											if ((rh_int + rh_dec + temp_int + temp_dec) == checksum) begin
												LEDG[7:0] <= temp_int; // Display temperature if checksum ok
											end 
											else begin
												LEDG[7] <= 1'b1;  // Indicate error
											end
											
											I2C_button_step_reg <= 1'b1;
											BTNisPressed <= 0;
											
											// auto reset FSM 
											cnt <= cnt + 1;
											if (cnt > START_LOW) begin
												cnt <= 0;
												state <= STATE_START_LOW;
											end
										end
										default: begin

										end
									endcase
							  end
							  
							  default: begin
							  end
						endcase
					end
					
					
					
					default: begin
					end
				endcase
			end
			
			2: begin 
				I2C_button_step_reg <= 1'b0;
			end
			
			default: begin
			
			end
		endcase
	end
end
	
endmodule