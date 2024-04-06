module sub_top_ds_adc (
    input clk,rst,
    input signed [15:0]din1,din2,
    output signed [15:0]dout1,dout2,
    input pmod1,     //pmod1 for comparator in
    output pmod2    //pmod2 for dac out
    );
    //clk div for delta-sigma D-FF
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
    //delta-sigma adc
    logic pdm;
    ds_mod_ad ds_adc(
        .clk(clk),
        .rst(rst),
        .cke(cke),
        .din(pmod1),    //comparator signal from pmod1
        .dac_drive(pmod2),    //dac signal to pmod2
        .pdm_out(pdm),
        .cke_out(),
        .dout(dout1)
    );
    assign dout2=(pdm)?32767:-32768;
endmodule