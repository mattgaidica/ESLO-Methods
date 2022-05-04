function [type,data,labels] = extractSD(fname,varargin)
% note: type is 0-indexed, labels in MATLAB will be 1-indexed
labels(:,2) = ["AbsoluteTime";"RelativeTime";"EEG1";"EEG2";"EEG3";"EEG4";"BatteryVoltage";...
    "XlX";"XlY";"XlZ";"EEGState";"SWATrial";"NotUsed2";"Temperature";"Error";"Version"];
labels(:,1) = 0:size(labels,1)-1;

fid = fopen(fname);
A = fread(fid,inf);
fclose(fid);

startSequence = 3:9; % find tail
startPos = strfind(A',startSequence);
if isempty(startPos)
    error('no start sequence found (part of UART dump), retry exporting...');
end
A = A(startPos+numel(startSequence):end,1);

data = int32(zeros(1,0));
type = uint8(zeros(1,0));

sampleCount = 1;
esloVersion = NaN;
% mode is 0
for ii = 1:4:numel(A)
    thisType = uint8(A(ii+3));
    
    if thisType == 0xFF % break w/out valid header
        break;
    end
    thisData = uint32(0);
    thisData = bitor(thisData, uint32(A(ii)));
    thisData = bitor(thisData, bitshift(uint32(A(ii+1)),8));
    thisData = bitor(thisData, bitshift(uint32(A(ii+2)),16));
    
    if thisType == 0x00 % time
        if numel(varargin) == 2
            MSB = bitand(uint32(posixtime(varargin{2})),0xFF000000);
            thisData = bitor(thisData,MSB);
        else
            thisData = bitor(thisData,0x62000000);
        end
    else
        if (bitget(thisData,24) == 1) % apply sign
            thisData = bitor(thisData,0xFF000000);
        end
    end
    thisData = typecast(thisData,'int32');
    
    if thisType == 0x0F
        if ii == 1
            esloVersion = thisData;
        else
            if thisData ~= esloVersion
                break; % no longer from same session
            end
        end
    end
    
    type(sampleCount) = thisType;
    data(sampleCount) = thisData;
    sampleCount = sampleCount + 1;
    if ~isempty(varargin) && sampleCount > varargin{1}
        fprintf('BREAKING, max sample = %i\n',varargin{1});
        break;
    end
end
% end