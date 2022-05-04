function OA = axyOA(x,y,z,axyFs)
nFilt = axyFs*60;
OA = abs(double(x) - medfilt1(double(x),nFilt)) + ...
    abs(double(y) - medfilt1(double(y),nFilt)) + ...
    abs(double(z) - medfilt1(double(z),nFilt));