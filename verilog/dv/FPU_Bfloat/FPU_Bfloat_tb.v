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

`default_nettype wire

//`timescale 1 ns / 1 ps

//`include "uprj_netlists.v"
//`include "caravel_netlists.v"
//`include "spiflash.v"
`include "tb_prog.v"

module FPU_Bfloat_tb();
    reg clock;
    reg RSTB;
    reg CSB;
    reg power1, power2;
    reg power3, power4;
    
    wire gpio;
    wire [37:0] mprj_io;

    wire [15:0] mprj_io_0;
    wire mprj_ready;
    
    assign mprj_io_0 = mprj_io[23:8];
    assign mprj_ready = mprj_io[37];
    
    assign mprj_io[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;
    
    always #12.5 clock <= (clock === 1'b0);
    
    initial begin
        clock = 0;
    end
 
    initial begin
        $dumpfile("FPU_Bfloat.vcd");
        $dumpvars(0, FPU_Bfloat_tb);

        // Repeat cycles of 1000 clock edges as needed to complete testbench
        //repeat (300) begin
        //    repeat (1000) @(posedge clock);
        //end
        //$display("%c[1;31m",27);
        //$display ("Monitor: Timeout, Test Project IO Stimulus (RTL) Failed");
        //$display("%c[0m",27);
        //$finish;
    end

	initial begin
	    wait(mprj_ready == 1'b1)
            // Observe Output pins [23:8] for Fmove
            /*
            wait(mprj_io_0 == 16'h4000);
            wait(mprj_io_0 == 16'h4020);
            wait(mprj_io_0 == 16'h4060);
            wait(mprj_io_0 == 16'h4090);
            wait(mprj_io_0 == 16'h40b0);
            wait(mprj_io_0 == 16'h40d0);
            wait(mprj_io_0 == 16'hC158);
            wait(mprj_io_0 == 16'hC178);
            */
            // Observe Output pins [23:8] for Fsign and I2F
            
            wait(mprj_io_0 == 16'h449A);
            wait(mprj_io_0 == 16'h3042);
            wait(mprj_io_0 == 16'h491E);
            wait(mprj_io_0 == 16'hDA92);
            wait(mprj_io_0 == 16'h5CB0);
            wait(mprj_io_0 == 16'h5CD9);
            wait(mprj_io_0 == 16'h5F09);
            wait(mprj_io_0 == 16'hBD78);
            wait(mprj_io_0 == 16'h449A);
            wait(mprj_io_0 == 16'h4689);
            wait(mprj_io_0 == 16'h475D);
            wait(mprj_io_0 == 16'h46B0);
            wait(mprj_io_0 == 16'h475D);
            wait(mprj_io_0 == 16'h4641);
            wait(mprj_io_0 == 16'h475D);
            
            // Observe Output pins [23:8] for FClass and F2I
            /*
            wait(mprj_io_0 == 16'h04d0);
            wait(mprj_io_0 == 16'hffff);
            wait(mprj_io_0 == 16'd0);
            wait(mprj_io_0 == 16'd0);
            wait(mprj_io_0 == 16'hE000);
            wait(mprj_io_0 == 16'hffff);
            wait(mprj_io_0 == 16'hffff);
            wait(mprj_io_0 == 16'hffff);
            wait(mprj_io_0 == 16'h0040);
            wait(mprj_io_0 == 16'h0040);
            wait(mprj_io_0 == 16'h0002);
            wait(mprj_io_0 == 16'h0002);
            */
            // Observe Output pins [23:8] for Comparison and Min/Max
            /*
            wait(mprj_io_0 == 16'h0001);
            wait(mprj_io_0 == 16'h0001);
            wait(mprj_io_0 == 16'h0001);
            wait(mprj_io_0 == 16'h0000);
            wait(mprj_io_0 == 16'h0001);
            wait(mprj_io_0 == 16'h0001);
            wait(mprj_io_0 == 16'h0001);
            wait(mprj_io_0 == 16'h0001);
            wait(mprj_io_0 == 16'h449A);
            wait(mprj_io_0 == 16'h3042);
            wait(mprj_io_0 == 16'h491E);
            wait(mprj_io_0 == 16'h59EE);
            wait(mprj_io_0 == 16'hDC87);
            wait(mprj_io_0 == 16'hB03E);
            wait(mprj_io_0 == 16'hBCF0);
            */
            // Observe Output pins [23:8] for FMUL
            /*
            wait(mprj_io_0 == 16'h60C2);
            wait(mprj_io_0 == 16'h30A7);
            wait(mprj_io_0 == 16'h67FF);
            wait(mprj_io_0 == 16'h78DF);
            wait(mprj_io_0 == 16'h7C00);
            wait(mprj_io_0 == 16'h5124);
            wait(mprj_io_0 == 16'h6058);
            wait(mprj_io_0 == 16'h0000);
            */
            $display("MPRJ-IO state = %h", mprj_io[23:8]);  
		
		`ifdef GL
	    	    $display("Monitor: Test 1 Mega-Project IO (GL) Passed");
		`else
		    $display("Monitor: Test 1 Mega-Project IO (RTL) Passed");
		`endif
	    $finish;
	end
	
	// Reset Operation
    initial begin
        RSTB <= 1'b0;
        CSB  <= 1'b1;       // Force CSB high
        #2000;
        RSTB <= 1'b1;       // Release reset
        #170000;
        CSB = 1'b0;         // CSB can be released
    end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end
	
	always @(mprj_io_0) begin
		#1 $display("MPRJ-IO state = %h, at time = %0t  ", mprj_io[23:8], $time);
	end
	
	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;
	wire r_Rx_Serial;
	assign mprj_io[5] = r_Rx_Serial;
        
        assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vddio_2  (VDD3V3),
		.vssio	  (VSS),
		.vssio_2  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda1_2  (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa1_2  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock    (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("FPU_Bfloat.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);
	
	
	uartprog #(
		.FILENAME("../hex/uart.hex")
	) prog_uut (
		//.clk(clock),
		.mprj_ready (mprj_ready),
		.r_Rx_Serial (r_Rx_Serial)
	);

endmodule
`default_nettype wire
