`timescale 1ns / 1ps

module top_module(
    input wire clk,
    input wire rst,
    inout wire I2C_SDA,
	 inout wire dht_io,
    input wire [4:0] BTN,
    output wire I2C_SCL,
	 output wire [17:0] LEDR,
	 output wire [8:0] LEDG,
	 output wire data_out
);
    wire [63:0] I2C_data_store_1;
    wire [255:0] I2C_data_store_2;
    wire [15:0] I2C_data_store_3;
    wire [255:0] I2C_data_store_4;
    wire I2C_output;
    wire I2C_output_enable;
    wire [7:0] I2C_project_step;
    wire I2C_button_step;
    wire I2C_data_store_step;
    wire I2C_LCD_step;
	 
	 //one_wire
	 wire [7:0] value_one_wire_1, value_one_wire_2, value_one_wire_3, value_one_wire_4; 
	 
	 //ws2812
	 wire ws2812_step;
	 

    I2C_data_store uut_I2C_data(
        .rst(rst),
        .clk(clk),
        .I2C_data_out_1(I2C_data_store_1),
        .I2C_data_out_2(I2C_data_store_2),
        .I2C_data_out_3(I2C_data_store_3),
        .I2C_data_out_4(I2C_data_store_4),
        .I2C_project_step(I2C_project_step),
        .I2C_data_store_step(I2C_data_store_step),
		  .value_one_wire_1(value_one_wire_1),
		  .value_one_wire_2(value_one_wire_2),
		  .value_one_wire_3(value_one_wire_3),
		  .value_one_wire_4(value_one_wire_4)
    );

    I2C_LCD uut_I2C_LCD(
        .I2C_data_in_1(I2C_data_store_1),
        .I2C_data_in_2(I2C_data_store_2),
        .I2C_data_in_3(I2C_data_store_3),
        .I2C_data_in_4(I2C_data_store_4),
        .clk(clk),
        .rst(rst),
        .I2C_SDA(I2C_SDA),
        .I2C_SCL(I2C_SCL),
        .I2C_project_step(I2C_project_step),
        .I2C_LCD_step(I2C_LCD_step)
    );
    
	 one_wire uut_one_wire(
        .clk(clk),
        .rst(rst),
		  .dht_io(dht_io),
		  .value_one_wire_1(value_one_wire_1),
		  .value_one_wire_2(value_one_wire_2),
		  .value_one_wire_3(value_one_wire_3),
		  .value_one_wire_4(value_one_wire_4),
		  .I2C_project_step(I2C_project_step),
		  .I2C_button_step(I2C_button_step),
		  .BTN(BTN),
        .LEDR(LEDR[13:8]),
		  .LEDG(LEDG)
    );
    
    I2C_step_processing uut_I2C_step(
        .clk(clk),
        .rst(rst),
        .I2C_project_step(I2C_project_step),
        .I2C_LCD_step(I2C_LCD_step),
        .I2C_button_step(I2C_button_step),
        .I2C_data_store_step(I2C_data_store_step),
		  .LEDR(LEDR[17:14]),
		  .ws2812_step(ws2812_step)
    );
	 
	 ws2812_test uut_ws2812(
			.clk(clk),
			.rst(rst),
			.I2C_project_step(I2C_project_step),
			.BTN(BTN),
			.value_one_wire_1(value_one_wire_1),
			.value_one_wire_2(value_one_wire_2),
			.value_one_wire_3(value_one_wire_3),
			.value_one_wire_4(value_one_wire_4),
			.LEDR(LEDR[6:3]),
			.ws2812_step(ws2812_step),
			.data_out(data_out)
	 );
endmodule
