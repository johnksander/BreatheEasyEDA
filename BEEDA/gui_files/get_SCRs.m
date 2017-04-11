function BEEDAdata = get_SCRs(BEEDAdata)
EDA_data = BEEDAdata.EDAdata;% smoothData;
timecourse = BEEDAdata.sampletimes; %sampletimes
[minL, maxL] = findSCRpeaks(EDA_data, 1);
minL = minL(1:length(maxL));
amplitudes = EDA_data(maxL) - EDA_data(minL);
superthresholdSCRs = amplitudes > BEEDAdata.SCRs.threshold;

maxL = maxL(superthresholdSCRs);
minL = minL(superthresholdSCRs);

BEEDAdata.SCRs.onsets = timecourse(minL);
BEEDAdata.SCRs.peaks = timecourse(maxL);
BEEDAdata.SCRs.ampl = EDA_data(maxL) - EDA_data(minL);
BEEDAdata.SCRs.index_onsets = minL;
BEEDAdata.SCRs.index_peaks = maxL;
BEEDAdata.SCRs.onsetlevels =  BEEDAdata.EDAdata(BEEDAdata.SCRs.index_onsets);
BEEDAdata.SCRs.peaklevels =  BEEDAdata.EDAdata(BEEDAdata.SCRs.index_peaks);
BEEDAdata.SCRs.magnitude = BEEDAdata.SCRs.peaklevels - BEEDAdata.SCRs.onsetlevels;





