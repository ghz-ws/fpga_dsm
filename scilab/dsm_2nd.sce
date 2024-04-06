clc
clear
clf

Fs=20000;   //sample freq.
L=10000;    //Length of signal
Freq=99;    //Signal freq.

t=0:1/Fs:(L-1)/Fs;    //time vector. 0-1
f=Fs*(0:(L/2))/L; //freq vector. freq res.=Fs/N*n. n=0-N/2
n=length(f) //length of freq vector
pure=sin(2*%pi*Freq*t); //pure signal

//1st order delta-sigma
dac=0;           //initial dac value
sigma=0;     //initial sigma register value
for i=1:L
    delta=pure(1,i)-dac;    //means sigma in
    sigma=sigma+delta;      //means comparator in
    if sigma>0 then         //act as comparator
        dac=1;
        comp1_out(1,i)=1;   //comparator out value
    else
        dac=-1;
        comp1_out(1,i)=-1;  //also zero
    end
end

//2nd order delta-sigma
dac=0;           //initial dac value
sigma1=0;    //initial 1st sigma register value
sigma2=0;    //initial 2nd sigma register value
dac_p=0;
for i=1:L
    delta1=pure(1,i)-dac;       //means 1st sigma in
    sigma1=sigma1+delta1;   //means 2nd delta in
    delta2=sigma1-dac;      //means 2nd sigma in
    sigma2=sigma2+delta2;   //means comparator in
    if sigma2>0 then             //act as comparator
        dac=1;
        comp2_out(1,i)=1;
    else
        dac=-1;
        comp2_out(1,i)=-1;           //also zero
    end
end

win=window('hn',L)      //window func.
pure_sp=abs(fft(pure.*win));
pdm1_sp=abs(fft(comp1_out.*win));
pdm2_sp=abs(fft(comp2_out.*win));

subplot(3,2,1)
plot(t,pure)
xgrid()
title("Pure signal","fontsize",5)
ylabel("Amplitude","fontsize",5)
g1=gca();   //get axis object
g1.data_bounds(:,1)=[0;1/Freq];   //y axis scale
g1.data_bounds(:,2)=[-1.2;1.2];   //y axis scale
g1.font_size=3

subplot(3,2,3)
plot(t,comp1_out)
xgrid()
title("1st order delta-sigma","fontsize",5)
ylabel("Amplitude","fontsize",5)
g1=gca();   //get axis object
g1.data_bounds(:,1)=[0;1/Freq];   //y axis scale
g1.data_bounds(:,2)=[-1.2;1.2];   //y axis scale
g1.font_size=3
subplot(3,2,5)
plot(t,comp2_out)
xgrid()
title("2nd order delta-sigma","fontsize",5)
xlabel("Time [s]","fontsize",5)
ylabel("Amplitude","fontsize",5)
g1=gca();   //get axis object
g1.data_bounds(:,1)=[0;1/Freq];   //y axis scale
g1.data_bounds(:,2)=[-1.2;1.2];   //y axis scale
g1.font_size=3

subplot(1,2,2)
plot('ln',f,20*log10(pure_sp(1:n)),f,20*log10(pdm1_sp(1:n)),f,20*log10(pdm2_sp(1:n)))
legend("Pure signal","1st order","2nd order",1,"in_lower_right")
xgrid()
title("Spectrum","fontsize",5)
xlabel("Freq [Hz]","fontsize",5)
ylabel("Amplitude [dB]","fontsize",5)
g2=gca();   //get axis object
g2.data_bounds(:,1)=[1;Fs/2];   //y axis scale
g2.data_bounds(:,2)=[-80;max(20*log10(pure_sp))];   //y axis scale
g2.font_size=3
e2=gce();
e2.font_size=5
