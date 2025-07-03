module uart_receive(
    input wire clk,
    input wire rst,
    input wire rx,  // 1-bit serial input

    output reg rx_en,
    output reg [7:0] rx_data = 8'd0,
    output reg [7:0] LEDG,
	 output reg [7:0] LEDR
);

reg [2:0] state;
reg [4:0] bit_index;
reg [15:0] baud_cnt; // Adjust for your baud rate
reg sample_tick;
reg [7:0] shift_reg;

parameter IDLE  = 3'd0;
parameter START = 3'd1;
parameter DATA  = 3'd2;
parameter STOP  = 3'd3;
parameter DONE  = 3'd4;

parameter BAUD_TICK = 434; // Assuming 50 MHz clock, 115200 baud

//always @(*) begin
//   for (i = 0; i < 8; i = i + 1) begin
//      LEDG[i] = rx_data[i];
//   end
//end

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        state <= IDLE;
        baud_cnt <= 0;
        sample_tick <= 0;
        rx_en <= 0;
        bit_index <= 0;
        rx_data <= 0;
        shift_reg <= 0;
		  LEDR <= 0;
		  LEDG <= 0;
    end else begin
        baud_cnt <= baud_cnt + 1;
        sample_tick <= (baud_cnt == BAUD_TICK/2);

        case (state)
            IDLE: begin
                rx_en <= 0;
					 LEDR[0] <= 1'b1;
                if (!rx) begin  // start bit
                    state <= START;
                    baud_cnt <= 0;
                end
            end

            START: begin
                if (sample_tick) begin
                    if (!rx) begin
								LEDR[1] <= 1'b1;
                        state <= DATA;
                        baud_cnt <= 0;
                        bit_index <= 0;
                    end else begin
                        state <= IDLE; // false start bit
                    end
                end
            end

            DATA: begin
                if (sample_tick) begin
						  LEDR[2] <= 1'b1;
                    shift_reg[bit_index] <= rx;
                    bit_index <= bit_index + 1;
						  baud_cnt <= 0;
                    if (bit_index == 7) begin
                        state <= STOP;
                    end
                end
            end

            STOP: begin
                if (sample_tick) begin
						  baud_cnt <= 0;
                    if (rx) begin // Stop bit must be high
								LEDR[3] <= 1'b1;
                        rx_data <= shift_reg;
                        rx_en <= 1;
                        LEDG <= rx_data;
                    end else begin
                        state <= IDLE; // framing error
                    end
                end
            end

            DONE: begin
                rx_en <= 0;
                state <= IDLE;
            end
        endcase
    end
end



endmodule
