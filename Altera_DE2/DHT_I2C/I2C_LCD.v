`timescale 1ns / 1ps

module I2C_LCD(
    input wire clk,
    input wire rst,
    input wire [63:0] I2C_data_in_1,
    input wire [255:0] I2C_data_in_2,
    input wire [15:0] I2C_data_in_3,
    input wire [255:0] I2C_data_in_4,
    input wire [7:0] I2C_project_step,
    inout wire I2C_SDA,
    output wire I2C_LCD_step,
    output reg I2C_SCL,
    output reg [4:0] LED
    );
    
    reg [20:0] I2C_counter;
    reg [20:0] LCD_counter;
    reg I2C_output;
    reg I2C_output_enable;
    reg [10:0] I2C_state;
    reg [10:0] LCD_state;
    reg [3:0] I2C_data_bit;
    reg [7:0] I2C_data;
    reg [7:0] I2C_data_temp;
    reg LCD_enable;
    reg [15:0] I2C_data_MSB;
    reg [15:0] I2C_data_LSB;
    reg [2:0] I2C_data_step;
    reg I2C_LCD_step_reg;
    wire [7:0] next_LSB = I2C_data_LSB - 8;
    wire [7:0] next_MSB = I2C_data_MSB - 8;
    
    localparam I2C_counter_value = 500;
    localparam LCD_counter_value = 1000;
    
    assign I2C_SDA = (I2C_output_enable) ? I2C_output : 1'bz;
    assign I2C_LCD_step = I2C_LCD_step_reg;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            I2C_counter <= 0;
            LCD_counter <= 0;
            I2C_output_enable <= 1'b1;
            I2C_output <= 1'b1;
            I2C_state <= 1;
            LCD_state <= 0;
            I2C_data_bit <= 7;
            I2C_SCL <= 1'b1;
            I2C_data <= 8'b0100_1110;
            I2C_data_MSB <= 8'd63;
            I2C_data_LSB <= 8'd56;
            I2C_data_temp <= I2C_data_in_1[63:56];
            LED = 5'd0;
            LCD_enable <= 1'b0;
            I2C_data_step <= 1;
            I2C_LCD_step_reg <= 1'b0;
        end
        else begin
            case (I2C_project_step)
                1: begin 
                    I2C_LCD_step_reg <= 1'b0;
                    LED <= 5'b00001;
                end
                3: begin
                    LED <= 5'b00010;
                    case (I2C_LCD_step_reg)
                        1'b0: begin
                            I2C_counter = (I2C_counter > I2C_counter_value) ? 0 : I2C_counter + 1;
                            if (I2C_counter == I2C_counter_value) begin
                                case (I2C_state)
                                    1:  begin
                                            I2C_output_enable <= 1'b1;
                                            I2C_output <= 1'b1;  
                                            I2C_SCL <= 1'b1; 
                                            I2C_state <= 2;  
                                            LED <= 5'b00010;                 
                                        end
                                    2:  begin
                                            I2C_output <= 1'b0; 
                                            I2C_state <= 3;               
                                        end
                                    3:  begin
                                            I2C_SCL <= 1'b0; 
                                            I2C_state <= 4;               
                                        end
                                    4:  begin
                                            I2C_output <= I2C_data[I2C_data_bit]; 
                                            if (I2C_data_bit == 0) I2C_state <= 7;
                                            else begin 
                                                I2C_state <= 5;
                                                I2C_data_bit <= I2C_data_bit - 1;
                                            end               
                                        end 
                                    5:  begin
                                            I2C_SCL <= 1'b1; 
                                            I2C_state <= 6;               
                                        end 
                                    6:  begin
                                            I2C_SCL <= 1'b0; 
                                            I2C_state <= 4;               
                                        end 
                                    7:  begin
                                            I2C_SCL <= 1'b1; 
                                            I2C_state <= 8;               
                                        end 
                                    8:  begin
                                            I2C_SCL <= 1'b0; 
                                            I2C_output_enable <= 1'b0;
                                            case (I2C_SDA)
                                                1'b0: I2C_state <= 10;
                                            endcase               
                                        end
                                    10: begin
                                             
                                            I2C_SCL <= 1'b1;
                                            case (I2C_SDA)
                                                1'b0: I2C_state <= 11;
                                            endcase          
                                        end
                                    11: begin
                                            I2C_SCL <= 1'b0;
                                            case (I2C_SDA)
                                                1'b1: I2C_state <= 12;
                                            endcase     
                                        end
                                    12: begin
                                            I2C_data <= I2C_data_temp;
                                            I2C_data_bit <= 7;
                                            I2C_output_enable <= 1'b1;
                                            I2C_state <= 13; 
                                            if (I2C_data_temp[2] == 1'b1) LCD_enable <= 1'b1;
                                        end
                                    13: begin
                                            I2C_output <= I2C_data[I2C_data_bit]; 
                                            if (I2C_data_bit == 0) I2C_state <= 16;
                                            else begin 
                                                I2C_state <= 14;
                                                I2C_data_bit <= I2C_data_bit - 1;
                                            end               
                                        end 
                                    14: begin
                                            I2C_SCL <= 1'b1; 
                                            I2C_state <= 15;               
                                        end 
                                    15: begin
                                            I2C_SCL <= 1'b0; 
                                            I2C_state <= 13;               
                                        end 
                                    16:  begin
                                            I2C_SCL <= 1'b1; 
                                            I2C_state <= 17;               
                                        end 
                                    17:  begin
                                            I2C_SCL <= 1'b0; 
                                            I2C_output_enable <= 1'b0;
                                            case (I2C_SDA)
                                                1'b0: I2C_state <= 19;
                                            endcase              
                                        end
                                    19: begin
                                            I2C_SCL <= 1'b1;
                                            case (I2C_SDA)
                                                1'b0: I2C_state <= 20;
                                            endcase 
                                        end
                                    20: begin
                                            I2C_SCL <= 1'b0;
                                            case (I2C_SDA)
                                                1'b1: I2C_state <= 22;
                                            endcase            
                                        end
                                    22: begin
                                            LCD_counter = (LCD_counter > LCD_counter_value) ? 0 : LCD_counter + 1;
                                            case (LCD_counter) 
                                                LCD_counter_value: begin 
                                                    case (LCD_enable)
                                                        1'b1: begin
                                                            case (I2C_data_temp[2])
                                                                1'b1: begin
                                                                    I2C_data_temp[2] <= 1'b0;
                                                                    LCD_enable <= 1'b0;
                                                                    I2C_state <= 12;
                                                                end
                                                            endcase
                                                        end
                                                        1'b0: begin 
                                                            case (I2C_data_LSB) 
                                                                8'd0: begin 
                                                                    I2C_state <= 23;
                                                                end
                                                                8'd1: I2C_state <= 23;
                                                                default: begin 
                                                                    I2C_data_MSB <= next_MSB;
                                                                    I2C_data_LSB <= next_LSB;
                                                                    case (I2C_data_step)
                                                                        1: I2C_data_temp <= (I2C_data_in_1 >> next_LSB) & 8'b1111_1111;
                                                                        2: I2C_data_temp <= (I2C_data_in_2 >> next_LSB) & 8'b1111_1111;
                                                                        3: I2C_data_temp <= (I2C_data_in_3 >> next_LSB) & 8'b1111_1111;
                                                                        4: I2C_data_temp <= (I2C_data_in_4 >> next_LSB) & 8'b1111_1111;                                                        
                                                                    endcase
                                                                    I2C_state <= 12;
                                                                end
                                                            endcase
                                                        end
                                                    endcase
                                                end
                                            endcase
                                        end 
                                    23: begin  
                                            case (I2C_data_step)
                                                1: begin 
                                                    I2C_data_step <= 2;
                                                    I2C_data_MSB <= 8'd255;
                                                    I2C_data_LSB <= 8'd248;
                                                    I2C_data_temp <= I2C_data_in_2[255:248];
                                                    I2C_state <= 12;
                                                end
                                                2: begin 
                                                    I2C_data_step <= 3;
                                                    I2C_data_MSB <= 8'd15;
                                                    I2C_data_LSB <= 8'd8;
                                                    I2C_data_temp <= I2C_data_in_3[15:8];
                                                    I2C_state <= 12;
                                                end
                                                3: begin 
                                                    I2C_data_step <= 4;
                                                    I2C_data_MSB <= 8'd255;
                                                    I2C_data_LSB <= 8'd248;
                                                    I2C_data_temp <= I2C_data_in_4[255:248];
                                                    I2C_state <= 12;
                                                end
                                                4: begin 
                                                    I2C_state <= 24;
                                                end
                                            endcase           
                                        end
                                        24: begin
                                            I2C_data_step <= 1;
                                            I2C_LCD_step_reg <= 1'b1;
                                            I2C_state <= 1;
                                            LED <= 5'b10000;
                                            
                                            I2C_output_enable <= 1'b1;
                                            I2C_output <= 1'b1;
                                            I2C_data_bit <= 7;
                                            I2C_SCL <= 1'b1;
                                            I2C_data <= 8'b0100_1110;
                                            I2C_data_MSB <= 8'd63;
                                            I2C_data_LSB <= 8'd56;
                                            I2C_data_temp <= I2C_data_in_1[63:56];
                                            LCD_enable <= 1'b0;
                                        end
                                    default: begin 
                                        I2C_output_enable <= 1'b0; 
                                    end      
                                endcase
                            end
                        end
                        default: begin end
                    endcase
                end
                default: begin end
            endcase
        end
    end
endmodule