module ws2812_test (
    input wire clk, rst, // 50 MHz
	 input wire [7:0] value_one_wire_1, value_one_wire_2, value_one_wire_3, value_one_wire_4,

	 input wire [7:0] I2C_project_step,
    input wire [4:0] BTN,
	 
	 output wire ws2812_step,
    output reg data_out,
	 output reg [3:0] LEDR,
    output reg done
);
	 
	 // temp value
	 reg [11:0] temp_value;
	
	 // init project step
	 reg ws2812_step_reg;
	 assign ws2812_step = ws2812_step_reg;
	 
	 // Color values - simplified to only red and blue
	 reg [23:0] red_color, blue_color, green_color;
	 initial begin
		 green_color = 24'hFF0000;   // GRB format: Green=255, Red=0, Blue=0
		 red_color = 24'h00FF00;
		 blue_color = 24'h0000FF;  // GRB format: Green=0, Red=0, Blue=255
	 end

	
    // clock frequency delay
    parameter integer CLK_FREQ_HZ = 50_000_000;
    parameter integer T1H_CYCLE = (CLK_FREQ_HZ * 8) / 10_000_000;   // 0.8us
    parameter integer T1L_CYCLE = (CLK_FREQ_HZ * 7) / 10_000_000; // 0.7us
    parameter integer T0H_CYCLE = (CLK_FREQ_HZ * 4) / 10_000_000;   // 0.4us
    parameter integer T0L_CYCLE = (CLK_FREQ_HZ * 85) / 100_000_000; // 0.85us
	 parameter integer HALF_SECOND_COUNT = 25_000_000; // 0.5s
	 parameter RESET_CYCLES = 3000; // for ~50us @ 60MHz


	 // may 8th
	 reg [23:0] led_colors [7:0];
	 reg [2:0] led_index; 
	 reg [4:0] bit_index;
	 reg [15:0] delay_counter;
	 reg [3:0] state;
	 reg [24:0] led_counter;
	 

    localparam IDLE = 0, LOAD_BIT = 1, LOAD_BIT_LATCH = 2, LOAD_BIT_WAIT = 3, SEND_HIGH = 4, SEND_LOW = 5, DONE = 6, RESET_WAIT = 7, WAIT = 8, READ_TEMP = 9, UPDATE_COLOR = 10;

    reg current_bit;
	 reg [3:0] i;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            bit_index <= 0;
            delay_counter <= 0;
            data_out <= 0;
            done <= 0;
				led_counter <= 0;
				led_index <= 0;
				LEDR <= 4'b0000;
				ws2812_step_reg <= 1'b0;
				
				// Initialize all LEDs to blue (default cold state)
				for (i = 0; i < 8; i = i + 1) begin
					led_colors[i] <= blue_color;
				end
				
        end else begin
		  case (I2C_project_step)
				 1: begin
					  ws2812_step_reg <= 1'b0;
				 end

				 4: begin
					  case (ws2812_step_reg)
							1'b0: begin
								 case (state)
									  IDLE: begin
											done <= 0; 						  
											led_index <= 0;
											bit_index <= 0;
											state <= LOAD_BIT;
											// OK
									  end
								
									  LOAD_BIT: begin
											current_bit <= led_colors[led_index][23 - bit_index];
											state <= LOAD_BIT_LATCH; // wait 1 cycle
									  end
									  
									  LOAD_BIT_LATCH: begin
											state <= LOAD_BIT_WAIT;
									  end
									  
									  LOAD_BIT_WAIT: begin
											delay_counter <= current_bit ? T1H_CYCLE : T0H_CYCLE; // check bit and set delay
											data_out <= 1;
											state <= SEND_HIGH;
									  end

									  SEND_HIGH: begin
											if (delay_counter == 0) begin
												 delay_counter <= current_bit ? T1L_CYCLE : T0L_CYCLE;
												 data_out <= 0;
												 state <= SEND_LOW;
											end else begin
												 delay_counter <= delay_counter - 1;
											end
									  end

									  SEND_LOW: begin
											if (delay_counter == 0) begin
												 if (bit_index == 23) begin
													  bit_index <= 0;
													  if (led_index == 7) begin
															state <= DONE;
													  end else begin
															led_index <= led_index + 1;
															bit_index <= 0;
															state <= LOAD_BIT;
													  end
												 end else begin
													  bit_index <= bit_index + 1;
													  state <= LOAD_BIT;
												 end
											end else begin
												 delay_counter <= delay_counter - 1;
											end
									  end

									  DONE: begin
											done <= 1;
											state <= RESET_WAIT;
											led_counter <= 0;
											ws2812_step_reg <= 1'b1;
											delay_counter <= 0;
									  end
									  
									  RESET_WAIT: begin
											data_out <= 0;
											if (delay_counter < RESET_CYCLES) begin
												delay_counter <= delay_counter + 1;
											end else begin
												state <= WAIT;
											end
									  end

									  WAIT: begin
											if (led_counter < HALF_SECOND_COUNT) begin
												 led_counter <= led_counter + 1;
											end else begin
												 led_counter <= 0;
												 state <= READ_TEMP;
											end
									  end
									  
									  READ_TEMP: begin
											// Compute temp_value
												temp_value = value_one_wire_1 * 1000 +
															 value_one_wire_2 * 100 +
															 value_one_wire_3 * 10 +
															 value_one_wire_4;			 
												state <= UPDATE_COLOR;
									  end

									  UPDATE_COLOR: begin
										 if (temp_value >= 16'd3000) begin
											  // Temperature >= 30°C: All LEDs RED
											  for (i = 0; i < 8; i = i + 1) begin
													led_colors[i] <= red_color;
											  end
											  LEDR <= 4'b1111; // Visual indicator on board LEDs
										 end else begin
											  // Temperature < 30°C: All LEDs BLUE
										 for (i = 0; i < 8; i = i + 1) begin
													led_colors[i] <= blue_color;
										 end
											  LEDR <= 4'b0000; // Turn off board LEDs
										 end
											state <= IDLE;
										end
									  
								 endcase
							end

							default: begin end
					  endcase
				 end
			endcase
		  end
    end
endmodule