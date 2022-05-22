// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns / 1ps

module uartprog #(
    parameter FILENAME="program.hex"
)(
    input mprj_ready,
    output reg r_Rx_Serial // used by task UART_WRITE_BYTE
);

reg r_Clock = 0;
parameter c_BIT_PERIOD = 8681; // used by task UART_WRITE_BYTE
parameter c_CLOCK_PERIOD_NS = 100;

reg [7:0] INSTR [16384-1:0];
integer instr_count = 0;
reg ready;
reg test;

always @ ( posedge r_Clock ) begin
  if (mprj_ready) begin
    ready <= 1'b1;
  end else begin
    ready <= 1'b0;
  end
end

initial begin
    $readmemh(FILENAME,INSTR);
end

task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer     ii;
    begin
        // Send Start Bit
        r_Rx_Serial <= 1'b0;
        #(c_BIT_PERIOD);
        #1000;

        // Send Data Byte
        for (ii=0; ii<8; ii=ii+1) begin
            r_Rx_Serial <= i_Data[ii];
            #(c_BIT_PERIOD);
        end

        // Send Stop Bit
        r_Rx_Serial <= 1'b1;
        #(c_BIT_PERIOD);
     end
endtask // UART_WRITE_BYTE

initial begin
        test = 1'b0;
  #1000 test = 1'b1;
end

always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;

initial begin
    r_Rx_Serial <= 1'b1;
    #2000;
    while (!ready && test) begin
      @(posedge r_Clock)
      r_Rx_Serial <= 1'b1;
    end
    while ((instr_count < 16384) && ({INSTR[instr_count],INSTR[instr_count+1],INSTR[instr_count+2],INSTR[instr_count+3]} != 32'h00000FFF)) begin
        @(posedge r_Clock);
        UART_WRITE_BYTE(INSTR[instr_count][7:0]);
        @(posedge r_Clock);
        UART_WRITE_BYTE(INSTR[instr_count+1][7:0]);
        @(posedge r_Clock);
        UART_WRITE_BYTE(INSTR[instr_count+2][7:0]);
        @(posedge r_Clock);
        UART_WRITE_BYTE(INSTR[instr_count+3][7:0]);
        @(posedge r_Clock);
        instr_count = instr_count + 32'd4;
    end
    @(posedge r_Clock);
    UART_WRITE_BYTE(8'h00);
    @(posedge r_Clock);
    UART_WRITE_BYTE(8'h00);
    @(posedge r_Clock);
    UART_WRITE_BYTE(8'h0F);
    @(posedge r_Clock);
    UART_WRITE_BYTE(8'hFF);
    @(posedge r_Clock);
end

endmodule
