`timescale 1ns / 1ps

module I2C_step_processing(
    input wire rst, clk,
    input wire I2C_data_store_step,
    input wire I2C_LCD_step,
    input wire I2C_button_step,
	 input wire ws2812_step,
	 
    output wire [7:0] I2C_project_step,
    output reg [3:0] LEDR
    );
    
    reg [7:0] project_step;
    
    assign I2C_project_step = project_step;
    
    always @(posedge clk or negedge rst) begin 
        if (!rst) begin
            project_step <= 2;
        end
        else begin
            case (I2C_button_step)
                1'b1: begin 
                    project_step <= 2; 
                end
                default: begin end
            endcase
            case (I2C_data_store_step)
                1'b1: begin 
                    project_step <= 3; 
                    LEDR <= 4'b0010;
                end
                default: begin end
            endcase
            case (I2C_LCD_step)
                1'b1: begin 
                    project_step <= 4; 
                end
                default: begin end
            endcase
            
				case (ws2812_step)
                1'b1: begin 
                    project_step <= 1; 
                    LEDR <= 4'b0100;
                end
                default: begin end
            endcase
        end
    end
endmodule