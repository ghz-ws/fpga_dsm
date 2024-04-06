module sub_top_ds_dac(
    input clk,rst,
    input signed [15:0]din1,din2,
    output signed [15:0]dout1,dout2,
    input pmod1,
    output pmod2
    );
    assign pmod2=0;
    
    parameter div_ratio=100;        //50M/100=500k delta-sigma clk
    logic [$clog2(div_ratio+1):0]div;
    logic cke;
    always_ff@(posedge clk)begin
        if(rst)begin
            div<=0;
            cke<=0;
        end else begin
            if(div==div_ratio-1)begin
                div<=0;
                cke<=1;
            end else begin
                div<=div+1;
                cke<=0;
            end
        end
    end
    logic signed [15:0]nco_out;
    logic ds_out;   //delta-sigma modulator output. PDM signal
    nco nco(
        .clk(clk),
        .rst(rst),
        .freq(268435456/50000*1),   //nco set 1kHz
        .out(nco_out)
        );
    ds_1st_dac ds_dac(
        .clk(clk),
        .rst(rst),
        .cke(cke),
        .din(nco_out),
        .dout(ds_out)
        );
    assign dout1=nco_out;
    assign dout2=(ds_out)?32767:-32768;
endmodule