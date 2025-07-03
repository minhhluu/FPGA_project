`timescale 1ns / 1ps

module uart_receive_tb();

reg clk = 0;
reg rst = 0;
reg rx = 1;

wire [7:0] rx_data;
wire [7:0] LEDG;
wire rx_en;

uart_receive uut (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .rx_en(rx_en),
    .rx_data(rx_data),
    .LEDG(LEDG)
);

always #10 clk = ~clk; // 50MHz

task send_byte(input [7:0] data);
    integer i;
    begin
        rx = 0; // start bit
        #(8680); // 1 bit time

        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];
            #(8680);
        end

        rx = 1; // stop bit
        #(8680);
    end
endtask

initial begin
    $dumpfile("uart_rx_tb.vcd");
    $dumpvars(0, uart_receive_tb);

    rst = 0;
    #100;
    rst = 1;

    #10000;

    send_byte(8'hA5); // Send 0xA5

  #100000;

    $finish;
end

endmodule
