`timescale 1ns / 1ps

module I2C_data_store(
    input wire rst, clk,
    input wire [7:0] I2C_project_step,
	 input wire [7:0] value_one_wire_1, value_one_wire_2, value_one_wire_3, value_one_wire_4,
    
    output wire I2C_data_store_step,
    output wire [63:0] I2C_data_out_1,
    output wire [255:0] I2C_data_out_2,
    output wire [15:0] I2C_data_out_3,
    output wire [255:0] I2C_data_out_4,
    output reg [2:0] LED
    );
    
    reg [127:0] I2C_data_high1; // upper 4 bits of each byte
    reg [127:0] I2C_data_high2; // upper 4 bits of each byte
    reg [3:0] I2C_data_low;  // lower 4 bits of each byte
    reg [255:0] I2C_data_out_2_reg;
    reg [255:0] I2C_data_out_4_reg;
    reg I2C_data_store_step_reg;
    
    integer i;
    // init
    assign I2C_data_out_1 = {
        8'h0C, 8'h2C, 8'h2C, 8'h8C,
        8'h0C, 8'h1C, 8'h0C, 8'hEC
    };
    
    assign I2C_data_out_2 = I2C_data_out_2_reg;
    
    // 2nd line
    assign I2C_data_out_3 = {
        8'hCC, 8'h0C
    };
    
    assign I2C_data_out_4 = I2C_data_out_4_reg;
    assign I2C_data_store_step = I2C_data_store_step_reg;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            I2C_data_high1          <= "N: 10 T: 06 N:25";
            I2C_data_high2          <= "Temp: 00.00 oC  ";
//				I2C_data_high1          <= "A=00 B=00 OP=000";
//          I2C_data_high2          <= "R=00 C=0 Z=0 O=0";
            I2C_data_low            <= 4'hD;
            I2C_data_store_step_reg <= 1'b0;
            LED <= 3'd0;
        end
        else begin
                        
            case (I2C_project_step)
                1: begin 
                    I2C_data_store_step_reg <= 1'b0;
//                    I2C_data_high1[111:104] <= value_A1_out; 
//                    I2C_data_high1[103:96] <= value_A2_out;
//                    I2C_data_high1[71:64] <= value_B1_out;
//                    I2C_data_high1[63:56] <= value_B2_out;
//                    I2C_data_high1[16] <= value_Opcode_out[2]; 
//                    I2C_data_high1[8] <= value_Opcode_out[1];
//                    I2C_data_high1[0] <= value_Opcode_out[0];
//                    I2C_data_high2[111:104] <= value_R1_out; 
//                    I2C_data_high2[103:96] <= value_R2_out;
//                    I2C_data_high2[71:64] <= out_carry;
//                    I2C_data_high2[39:32] <= out_zero;

                    I2C_data_high2[79:72] <= value_one_wire_1; 
                    I2C_data_high2[71:64] <= value_one_wire_2;
                    I2C_data_high2[55:48] <= value_one_wire_3;
                    I2C_data_high2[47:40] <= value_one_wire_4;
                end
                2: begin
                    case (I2C_data_store_step_reg)
                        1'b0: begin
                            for (i = 0; i < 32; i = i + 1) begin
                                I2C_data_out_2_reg[i*8 +: 8] = {I2C_data_high1[i*4 +: 4], I2C_data_low[3:0]};
                                I2C_data_out_4_reg[i*8 +: 8] = {I2C_data_high2[i*4 +: 4], I2C_data_low[3:0]};
                            end
                            case (i)
                                32: begin
                                    i = 0;
                                    I2C_data_store_step_reg <= 1'b1;
                                    LED[2] <= 1'b1;
                                end
                            endcase
                        end
                        default: begin end
                    endcase
                end
                default: begin end
            endcase
        end
    end
endmodule