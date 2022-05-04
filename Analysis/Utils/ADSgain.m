function uV = ADSgain(EEG,adsGain)
Vref = 1.5;
uV = EEG .* (Vref/adsGain)/(2^23-1) * 10^6; % based on ADS
uV = uV * 5/3; % empirically found, must be due to input filters