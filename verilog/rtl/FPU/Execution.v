module Execution(clk,rst_l,RS1_d_w,RS2_d_w,result,Flag_ADDI_w,Flag_LI_w,Activation_Signal,Flag_Reset_w,fpu_active,illegal_config,valid_execution,fs1_data,fs2_data,fs3_data,sfpu_op,fpu_pre,fpu_rounding,float_control,fpu_result_1,S_flag,dec_i0_rs1_en_d,dec_i0_rs2_en_d,IV_exception,fpu_complete,fpu_sel,fpu_result_rd_w,fpu_complete_rd);
    input clk,rst_l,Flag_ADDI_w,Flag_LI_w,Flag_Reset_w,fpu_active,illegal_config,valid_execution,dec_i0_rs1_en_d,dec_i0_rs2_en_d;
    input [31:0]RS1_d_w,RS2_d_w;
    input [15:0]fs1_data,fs2_data,fs3_data;
    input [23:0]sfpu_op;
    input [2:0]fpu_pre,fpu_rounding;
    input [3:0]float_control;
    input [2:0]fpu_sel;
    output reg[31:0]result;
    output reg Activation_Signal;
    output [15:0]fpu_result_1;
    output [4:0]S_flag;
    output IV_exception;
    output fpu_complete;
    output [31:0]fpu_result_rd_w;
    output fpu_complete_rd;

    reg [31:0]RS1_d,RS2_d;
    reg Flag_ADDI,Flag_LI,Flag_Reset;

    wire [31:0]result_w;
    wire complete; 

    always @(posedge clk)
    begin
        if(rst_l == 1'b0)
        begin
            RS1_d <= 32'h00000000;
            RS2_d <= 32'h00000000;
            Flag_ADDI <= 1'b0;
            Flag_LI <= 1'b0;
            Flag_Reset <= 1'b0;
        end
        else
        begin
            RS1_d <= RS1_d_w;
            RS2_d <= RS2_d_w;
            Flag_ADDI <= Flag_ADDI_w;
            Flag_LI <= Flag_LI_w;
            Flag_Reset <= Flag_Reset_w;
        end

    end

    FPU_exu FPU_Execution(
                         .clk(clk),
                         .rst_l(rst_l),
                         .scan_mode(1'b0),
                         .valid_execution(valid_execution),
                         .float_control(float_control),
                         .sfpu_op(sfpu_op),
                         .fpu_rnd(fpu_rounding),
                         .fpu_pre(fpu_pre),
                         .dec_i0_rs1_en_d(dec_i0_rs1_en_d),                               // Qualify GPR RS1 data
                         .dec_i0_rs2_en_d(dec_i0_rs2_en_d),                               // Qualify GPR RS2 data
                         .gpr_i0_rs1_d(RS1_d_w),                                  // DEC data gpr
                         .gpr_i0_rs2_d(RS2_d_w),                                  // DEC data gpr
                         .fs1_data(fs1_data),
                         .fs2_data(fs2_data),
                         .fs3_data(fs3_data),
                         .fpu_sel(fpu_sel),
                         .fpu_result_1(fpu_result_1),                           // single cycle result
                         .fpu_result_rd(fpu_result_rd_w),                          // integer result
                         .fpu_complete(fpu_complete),
                         .sflags(S_flag),
                         .IV_exception(IV_exception),
                         .fpu_complete_rd(fpu_complete_rd)
                         );

    assign result_w = (~rst_l) ? 32'h00000000 : (Flag_ADDI | Flag_LI) ? (RS1_d + RS2_d) : 32'h00000000;
    assign complete = (~rst_l) ? 1'b0 : (Flag_ADDI | Flag_LI | Flag_Reset) ? 1'b1 : 1'b0;

    always @(posedge clk)
    begin
        if(~rst_l)
        begin
            result = 32'h00000000;
            Activation_Signal = 1'b0;
        end

        else
        begin
            result = result_w;
            Activation_Signal =  complete;
        end
    end


endmodule
