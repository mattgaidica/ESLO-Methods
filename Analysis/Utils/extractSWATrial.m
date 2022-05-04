function [trialVars,EEG,t,rawEEG] = extractSWATrial(fname,Fs)
esloGain = 12;

fid = fopen(fname);
A = uint32(fread(fid,inf,'uint32'));
fclose(fid);

dataLen = numel(A) - 7; % num of vars from base station
t = linspace(0,dataLen/Fs,dataLen);
rawEEG = A(1:dataLen);

% these come from central device
trialVars = {};
trialVars.doSham        = double(A(dataLen + 1));
trialVars.dominantFreq  = double(A(dataLen + 2));
trialVars.phaseAngle    = double(A(dataLen + 3));
trialVars.trialCount    = double(A(dataLen + 4));
trialVars.absoluteTime  = double(A(dataLen + 5));
trialVars.msToStim      = double(A(dataLen + 6));
trialVars.targetPhase   = double(A(dataLen + 7));

% add EEG Channel
dataType = bitshift(bitand(rawEEG(1),uint32(0xFF000000)),-24);
trialVars.eegChannel    = dataType - 1;

for iData = 1:numel(rawEEG)
    rawEEG(iData) = bitand(rawEEG(iData),uint32(0x00FFFFFF));
    if (bitget(rawEEG(iData),24) == 1) % apply sign
        rawEEG(iData) = bitor(rawEEG(iData),uint32(0xFF000000));
    end
end
rawEEG = double(typecast(rawEEG,'int32'));
% post-process
EEG = ADSgain(rawEEG,esloGain);
% EEG(EEG==0) = NaN;
% EEG = fillmissing(EEG,'spline');
