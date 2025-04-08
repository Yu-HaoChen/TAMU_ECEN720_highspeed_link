function [taps,taps_quan]=tx_eq(ir_in,bit_period,eq_tap_number,precursor_number,num_bits)




%%Include CTLE
%%Model Peaking Amplifier
%ctle.kacdc_fin=4;
%ctle.zero_fin=0.5e9;
%ctle.acbw_fin=10e9;
%ctle.gbw=25e9;
%ctle.gain_adjust_fac=1.0;
%ctle.format='pole/zero';
%ir_post_ctle=gen_ctle(ir_in,ctle,tsample);


% No RX CTLE Equalization
ir_process=ir_in;
% With RX CTLE Equalization
%ir_process=ir_post_ctle;

precursor_samples=10;
pulse_response=conv(ir_process,ones(1,bit_period));
[max_pulse_value,max_pulse_time]=max(pulse_response);
sample_times=[max_pulse_time-1*precursor_samples*bit_period:bit_period:max_pulse_time+30*bit_period];
sample_values=pulse_response(sample_times);

%figure; plot(pulse_response,'-b'); hold on; stem(sample_times,sample_values,'-*r'); grid on;

%eq_taps=3;
%precursor_number=1;

% Construct H matrix
H(:,1)=sample_values';
H(size(sample_values,1)+1:size(sample_values,1)+eq_tap_number-1,1)=0;
for i=2:eq_tap_number-1
    H(1:i-1,i)=0;
    H(i:size(sample_values,1)+i-1,i)=sample_values';
    H(size(sample_values,1)+i:size(sample_values,1)+eq_tap_number-1,1)=0;
end;
H(1:eq_tap_number-1,eq_tap_number)=0;
H(eq_tap_number:eq_tap_number+size(sample_values,1)-1,eq_tap_number)=sample_values';

% Construct Y matrix
Ydes(1:precursor_samples-1,1)=0;
Ydes(precursor_samples:precursor_samples+precursor_number,1)=0;
Ydes(precursor_samples+precursor_number+1,1)=1;
Ydes(precursor_samples+precursor_number+2:size(H,1),1)=0;

W=(H'*H)^(-1)*H'*Ydes

Itot=1;
taps=Itot*W/sum(abs(W));
taps_abs=abs(taps);
taps_sign=sign(taps);

partition=[1/(2*(2^num_bits-1)):1/(2^num_bits-1):1-1/(2*(2^num_bits-1))];
codebook=[0:1/(2^num_bits-1):1];
[index,abs_taps_quan]=quantiz(abs(taps),partition,codebook);
taps_quan=taps_sign'.*abs_taps_quan;
taps_quan(precursor_number+1)=sign(taps_quan(precursor_number+1))*(1-(sum(abs(taps_quan))-abs(taps_quan(precursor_number+1))));


