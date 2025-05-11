`timescale 1ns / 1ps

module LCD_Rotary(
    input wire rst,
    input wire clk,
    input wire [4:0] BTN,
    output reg LCD_VO,
    
    output reg LCD_RS,
    output reg LCD_EN,
    output reg LCD_RW,
    
    output reg [3:0] LCD_DATA,
    output reg [14:0] LED
    );

    // pwm init contril
    reg [16:0] duty;
    reg [16:0] cnt2;
    
    // lcd init count
    reg [16:0] cnt;
    reg [5:0] LCD_state;

    reg done = 0;
    
    parameter STEP_CONT = 17'd50;
    parameter DUTY_MIN = 17'd0;
    parameter DUTY_MAX = 17'd90_000;
    
    // when the clock is at high edge
    always @(posedge clk or negedge rst) begin
        // if the switch controls reset is off
        if (!rst) begin
            cnt2        <= 0; //counter of pwm
            LCD_VO      <= 1'b0;
            duty        <= 17'd50_000;
            LCD_state   <= 6'd0;
            LCD_RW      <= 0;
            LED         <= 15'd0;
            LCD_EN      <= 0;
            done        <= 0;
        end
    
        // if the switch controls reset is on
        else begin
            // Smoother contrast increase (BTN[2] held down)
            if (BTN[2] && cnt2 == 0) begin
                if (duty + STEP_CONT <= DUTY_MAX) begin
                    duty <= duty + STEP_CONT;
                end
                else duty <= DUTY_MAX;
            end

            // Smoother contrast decrease (BTN[1] held down)
            if (BTN[1] && cnt2 == 0) begin
                if (duty >= STEP_CONT) begin
                    duty <= duty - STEP_CONT;
                end           
                else duty <= DUTY_MIN;
            end
        
            //count_2
            if (cnt2 < 99_999) begin
                cnt2 <= cnt2 + 1;
            end 
            else cnt2 <= 0;
            
            // Increase or decrease contrast
            LCD_VO <= (cnt2 < duty) ? 1'b1 : 1'b0;
            
            if (!done) begin
                // debounce
                cnt = (cnt > 100_000) ? 0 : cnt + 1; 

                case(cnt)
                    99_999: begin
                        LCD_EN <= ~LCD_EN;
                        if (~LCD_EN) begin
                            case(LCD_state)
                                0: begin
                                    LCD_DATA <= 4'h0;
                                    LCD_RS <= 0;
                                    LCD_state <= 1;
                                end

                                1: begin
                                    LCD_DATA <= 4'h2;
                                    LCD_state <= 2;
                                end

                                2: begin
                                    LCD_DATA <= 4'h2;
                                    LCD_state <= 3;
                                end

                                3: begin
                                    LCD_DATA <= 4'h8;
                                    LCD_state <= 4;
                                end

                                4: begin
                                    LCD_DATA <= 4'h0;
                                    LCD_state <= 5;
                                end

                                5: begin
                                    LCD_DATA <= 4'h1;
                                    LCD_state <= 6;
                                end

                                6: begin
                                    LCD_DATA <= 4'h0;
                                    LCD_state <= 7;
                                end

                                7: begin
                                    LCD_DATA <= 4'hE;
                                    LCD_state <= 8;
                                end

                                8: begin
                                    LCD_DATA <= 4'h4; // high nibble of H
                                    LCD_RS <= 1;
                                    LCD_state <= 9;
                                end

                                9: begin
                                    LCD_DATA <= 4'h8; // low nibble of H
                                    LCD_state <= 10;
                                end
                                
                                10: begin
                                    LCD_DATA <= 4'h6; // high nibble of 'e'
                                    LCD_state <= 11;
                                end
                                
                                11: begin
                                    LCD_DATA <= 4'h5; // low nibble of 'e'
                                    LCD_state <= 12;
                                end

                                12: begin
                                    LCD_DATA <= 4'h6; // high nibble of 'l'
                                    LCD_state <= 13;
                                end
                                
                                13: begin
                                    LCD_DATA <= 4'hC; // low nibble of 'l'
                                    LCD_state <= 14;
                                end

                                14: begin
                                    LCD_DATA <= 4'h6; // high nibble of 'l'
                                    LCD_state <= 15;
                                end
                                
                                15: begin
                                    LCD_DATA <= 4'hC; // low nibble of 'l'
                                    LCD_state <= 16;
                                end

                                16: begin
                                    LCD_DATA <= 4'h6; // high nibble of 'o'
                                    LCD_state <= 17;
                                end

                                17: begin
                                    LCD_DATA <= 4'hF; // low nibble of 'o'
                                    LCD_state <= 18;
                                end

                                18: begin
                                    LCD_DATA <= 4'h2; // high nibble of ','
                                    LCD_state <= 19;
                                end

                                19: begin
                                    LCD_DATA <= 4'hC; // low nibble of ','
                                    LCD_state <= 20;
                                end

                                20: begin
                                    LCD_DATA <= 4'h2; // high nibble of space
                                    LCD_state <= 21;
                                end

                                21: begin
                                    LCD_DATA <= 4'h0; // low nibble of space
                                    LCD_state <= 22;
                                end

                                22: begin
                                    LCD_DATA <= 4'h6; // high nibble of 'm'
                                    LCD_state <= 23;
                                end

                                23: begin
                                    LCD_DATA <= 4'hD; // low nibble of 'm'
                                    LCD_state <= 24;
                                end

                                24: begin
                                    LCD_DATA <= 4'h7; // high nibble of 'y'
                                    LCD_state <= 25;
                                end

                                25: begin
                                    LCD_DATA <= 4'h9; // low nibble of 'y'
                                    LCD_state <= 26;
                                end

                                26: begin
                                    LCD_DATA <= 4'h2; // high nibble of space
                                    LCD_state <= 27;
                                end

                                27: begin
                                    LCD_DATA <= 4'h0; // low nibble of space
                                    LCD_state <= 28;
                                end

                                28: begin
                                    LCD_DATA <= 4'h6; // high nibble of 'n'
                                    LCD_state <= 29;
                                end

                                29: begin
                                    LCD_DATA <= 4'hE; // low nibble of 'n'
                                    LCD_state <= 30;
                                end

                                30: begin
                                    LCD_DATA <= 4'h6; // high nibble of 'a'
                                    LCD_state <= 31;
                                end

                                31: begin
                                    LCD_DATA <= 4'h1; // low nibble of 'a'
                                    LCD_state <= 32;
                                end

                                32: begin
                                    LCD_DATA <= 4'h6; // high nibble of 'm'
                                    LCD_state <= 33;
                                end

                                33: begin
                                    LCD_DATA <= 4'hD; // low nibble of 'm'
                                    LCD_state <= 34;
                                end

                                34: begin
                                    LCD_DATA <= 4'h6; // high nibble of 'e'
                                    LCD_state <= 35;
                                end

                                35: begin
                                    LCD_DATA <= 4'h5; // low nibble of 'e'
                                    LCD_state <= 36;
                                end

                                36: begin
                                    LCD_DATA <= 4'h2; // high nibble of space
                                    LCD_state <= 37;
                                end

                                37: begin
                                    LCD_DATA <= 4'h0; // low nibble of space
                                    LCD_state <= 38;
                                end

                                38: begin
                                    LCD_DATA <= 4'h2; // high nibble of space
                                    LCD_state <= 39;
                                end

                                39: begin
                                    LCD_DATA <= 4'h0; // low nibble of space
                                    LCD_state <= 40;
                                end

                                40: begin
                                    LCD_DATA <= 4'h2; // high nibble of space
                                    LCD_state <= 41;
                                end

                                41: begin
                                    LCD_DATA <= 4'h0; // low nibble of space
                                    LCD_state <= 42;
                                end

                                42: begin
                                    LCD_RS <= 0;          // Command mode
                                    LCD_DATA <= 4'hC;     // High nibble of 0xC0
                                    LCD_state <= 43;
                                end

                                43: begin
                                    LCD_DATA <= 4'h0;     // Low nibble of 0xC0
                                    LCD_state <= 44;
                                end

                                44: begin
                                    LCD_RS <= 1;          // Back to data mode
                                    LCD_DATA <= 4'h6;     // High nibble of 's'
                                    LCD_state <= 45;
                                end

                                45: begin
                                    LCD_DATA <= 4'h9;     // Low nibble of 's'
                                    LCD_state <= 46;
                                end
                                
                                46: begin
                                    LCD_DATA <= 4'h7;
                                    LCD_state <= 47;
                                end
                                
                                47: begin
                                    LCD_DATA <= 4'h3;
                                    LCD_state <= 48;
                                end
                                
                                48: begin
                                    LCD_DATA <= 4'h2; // high nibble of space
                                    LCD_state <= 49;
                                end

                                49: begin
                                    LCD_DATA <= 4'h0; // low nibble of space
                                    LCD_state <= 50;
                                end
                                
                                50: begin
                                    LCD_DATA <= 4'h4;     // High nibble of 'M' (0x4D)
                                    LCD_state <= 51;
                                end

                                51: begin
                                    LCD_DATA <= 4'hD;     // Low nibble of 'M'
                                    LCD_state <= 52;
                                end

                                52: begin
                                    LCD_DATA <= 4'h6;     // High nibble of 'i' (0x69)
                                    LCD_state <= 53;
                                end

                                53: begin
                                    LCD_DATA <= 4'h9;     // Low nibble of 'i'
                                    LCD_state <= 54;
                                end

                                54: begin
                                    LCD_DATA <= 4'h6;     // High nibble of 'n' (0x6E)
                                    LCD_state <= 55;
                                end

                                55: begin
                                    LCD_DATA <= 4'hE;     // Low nibble of 'n'
                                    LCD_state <= 56;
                                end

                                56: begin
                                    LCD_DATA <= 4'h6;     // High nibble of 'h' (0x68)
                                    LCD_state <= 57;
                                end

                                57: begin
                                    LCD_DATA <= 4'h8;     // Low nibble of 'h'
                                    LCD_state <= 58;
                                end

                                58: begin
                                    done <= 1;
                                    cnt <= 0;
                                end
                                
                            endcase
                        end
                    end
                endcase
            end
        end 
    end
endmodule
