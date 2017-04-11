function BEEDAdata = makeBEEDAmatfile(MWdata,eventfile)
%-------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------
%
% makeBEEDAmatfile(MWdata,eventfile,matfile_savename)
%
%---- MWdata is the .txt data file exported from biolab
%---- MWdata should be a .txt file with at least three columns, where the
% first col is the sample time, second col is EDA response data, and the
% third col is respiration data.
%
%---- eventfile is the experiment event.txt file containing event names
% and timestamps
%
%---- leda_scrlist is the .mat file from Ledalab's Export SCR-List
%
%---- matfile_savename is the name you want to save the BEEDA matfile as
%
%
% FUNCTION USEAGE:
%      makeBEEDAmatfile('MW_110_data.txt','110_1_event.txt','110_Ledadata_scrlist.mat','110_BEEDAfile')
%
%-------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------

disp(sprintf('reading in data file'))
MWdata = dlmread(MWdata,'',2,0);%skip headers
MWdata = MWdata(:,1:3); %cols (1 = timepoint) (2 = EDA) (3 = respiration)
MWdata(:,2)= (MWdata(:,2)*10);
%--- output SC data is off by a decimal point

disp(sprintf('reading in event file'))
%set(f_wait_text,'String','Reading in event file...')
%drawnow 

fileID = fopen(eventfile);
event_array = textscan(fileID,'%s','Delimiter','\n');
fclose(fileID);

disp(sprintf('reformatting and saving EDA experiment data'))
 

formatIn = 'dd/mm/yyyyHH:MM:SS.FFFPM';

start_time = event_array{1}{2};
events = event_array{1}(3:end);
event_times = cell(size(events));
event_names = cell(size(events));
event_nums = cell(size(events));
for idx = 1:numel(event_times)
    event_times{idx} = strsplit(events{idx});
    hld_strs = event_times{idx}((end - 2):end);
    event_times{idx} = [hld_strs{:}];
    
    event_names{idx} = strsplit(events{idx});
    hld_strs = event_names{idx}(1:(end - 3));
    event_names{idx} = strjoin(hld_strs);
    
    event_nums{idx} = strsplit(events{idx},'#');
    event_nums{idx} = event_nums{idx}{2};
    event_nums{idx} = strsplit(event_nums{idx},{'\t'});
    event_nums{idx} = event_nums{idx}{1};
end
event_times = datevec(event_times,formatIn); %need datevector format
start_time = strsplit(start_time);
start_time = start_time((end - 2):end);
start_time = [start_time{:}];
start_time = datevec(start_time,formatIn); %need datevector format
start_time = repmat(start_time,numel(event_times(:,1)),1);
event_times = etime(event_times,start_time);%--- calculate difference in seconds from start time to event time


BEEDAdata.respiration = MWdata(:,3)';
BEEDAdata.EDAdata = MWdata(:,2)';
BEEDAdata.sampletimes = MWdata(:,1)';

event_nums = str2double(event_nums);

for Eidx = 1:numel(event_times(:,1))
    BEEDAdata.event(Eidx).time = event_times(Eidx);
    BEEDAdata.event(Eidx).nid = event_nums(Eidx);
    BEEDAdata.event(Eidx).name = event_names{Eidx};
end

BEEDAdata.savedfile = 'false';

end