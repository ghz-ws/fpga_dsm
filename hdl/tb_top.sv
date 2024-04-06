`timescale 1ns / 1ps
module tb_top();
    bit mclk,ext_rst;
    logic [9:0]adc1,adc2,dac1,dac2;
    logic dac1_clk,dac2_clk,adc1_clk,adc2_clk;
    logic pmod1, pmod2;
    logic [8:3]pmod;
    logic [2:0]led;
    logic signed [9:0]out;
    
    always #42ns mclk<=!mclk;
    assign adc1=0;  //ext. adc is not used for delta-sigma module
    assign adc2=0;  //ext. adc is not used for delta-sigma module
    
    initial begin
        @(posedge dut.locked);
        #3000us
        $finish;
    end
    
    //external delta-sigma module for delta-sigma ADC test
    wire signed [15:0]din=out*64; //delta-sigma input
    wire ds_clk=dut.clk;
    wire ds_cke=dut.sub_top.cke;//dut.cke;
    wire ds_rst=dut.rst;
    logic dac_drive,comp_out;
    logic signed [16:0]sigma,delta,comp_in; //sigma register, delta out
    logic signed [15:0]dac;                 //dac value
    assign dac=(dac_drive)?32767:-32768;    //if dac_drive>0, dac=32767 
    assign delta=din-dac;                   //calc delta
    assign comp_in=sigma+delta;             //comparator in. 1 clk forward to sigma reg. out
    assign comp_out=!comp_in[16];           //if sigma>0 comp_out=1
    always_ff@(posedge ds_clk)begin
        if(ds_rst)begin
            sigma<=0;
        end else begin
            if(ds_cke)begin
                sigma<=sigma+delta;
            end
        end
    end
    
    //connect ext. ds_mod to FPGA
    assign pmod1=comp_out;
    assign dac_drive=pmod2;
    
    top dut(.*);
    nco_sim nco(.*);
endmodule
