module ds_2nd_dac(
    input clk,rst,cke,
    input signed [15:0]din,
    output dout
    );
    localparam bit_len=23;
    logic signed [15:0]din_reg;
    logic signed [bit_len:0]sigma1,sigma2;
    logic signed [15:0]dac;
    logic signed [bit_len:0]delta1,delta2;
    assign dac=(sigma2[bit_len])?-32768:32767;    //if sigma2>0, dac=32767 
    assign delta1=din_reg-dac;
    assign delta2=sigma1-dac;
    assign dout=!sigma2[bit_len];     //if sigma2>0 dout=1
    always_ff@(posedge clk)begin
        if(rst)begin
            din_reg<=0;
            sigma1<=0;
            sigma2<=0;
        end else begin
            if(cke)begin
                din_reg<=din;
                sigma1<=sigma1+delta1;
                sigma2<=sigma2+delta2;
            end
        end
    end
endmodule
