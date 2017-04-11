function [ BEEDAdata ] = downsample_BEEDAdata(BEEDAdata,factor)

BEEDAdata.respiration = BEEDAdata.respiration(factor:factor:end);
BEEDAdata.EDAdata = BEEDAdata.EDAdata(factor:factor:end);
BEEDAdata.sampletimes = BEEDAdata.sampletimes(factor:factor:end);
BEEDAdata.downsample_factor = factor;

end

