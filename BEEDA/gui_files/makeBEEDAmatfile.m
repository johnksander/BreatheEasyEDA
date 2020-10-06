function BEEDAdata = makeBEEDAmatfile(Fdata,eventfile,use_call)
%-------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------
%
%makeBEEDAmatfile(Fdata,eventfile,use_call)
%
%---- This function converts datafiles into BEEDA mat files. The 3rd
% argument speficies whether the input files are from biolab, or generic
% .csv formatted files.
%
% FUNCTION USEAGE:
%      makeBEEDAmatfile('subject_110_data.txt','subject_110_events.txt','biolab')
%
%==== If the 3rd argument specifies 'biolab'
%
%---- Fdata is the .txt data file exported from biolab
%---- Fdata should be a .txt file with at least three columns, where the
% first col is the sample time, second col is EDA response data, and the
% third col is respiration data.
%
%---- eventfile is the experiment event.txt file containing event names
% and timestamps (also biolab format)
%
%==== If the 3rd argument specifies 'generic'
%
%---- Fdata should be a .csv file with at least three columns, where the
% first col is the sample time, second col is EDA response data, and the
% third col is respiration data.
%
%---- eventfile is the experiment event.csv file with two columns. First
% column contains event names and second column contains timestamps
%
%-------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------


switch use_call
    case 'biolab'
        
        disp(sprintf('reading in data file'))
        Fdata = dlmread(Fdata,'',2,0);%skip headers
        Fdata = Fdata(:,1:3); %cols (1 = timepoint) (2 = EDA) (3 = respiration)
        Fdata(:,2)= (Fdata(:,2)*10);
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
        event_nums = str2double(event_nums);
        
        
    case 'generic'

        disp(sprintf('reading in data file'))
        Fdata = csvread(Fdata);
        
        disp(sprintf('reading in event file'))
        %set(f_wait_text,'String','Reading in event file...')
        %drawnow
        event_data = readtable(eventfile,'Delimiter',',','ReadVariableNames',false);
        event_data.Properties.VariableNames = {'name','timestamp'};
        num_events = numel(event_data.name);
        [all_events,~,event_data.number] = unique(event_data.name);
        switch class(event_data.timestamp)
            case 'datetime'
                %good
            case 'duration'
                warning(['the timestamps in %s do not have dates, BEEDA will add '...
                    'today''s date to each timestamp. This may have unintended consequences.'],eventfile)
                event_data.timestamp = datetime('today') + event_data.timestamp; 
                event_data.timestamp = datetime(event_data.timestamp);
            otherwise
                try
                    event_data.timestamp = datetime(event_data.timestamp);
                catch
                    error('the timestamps in %s are not formatted properly',eventfile)
                end
        end
        start_time = datetime(event_data.timestamp(1));
         
        event_times = etime(datevec(event_data.timestamp),datevec(start_time));
        event_nums = event_data.number;
        event_names = event_data.name;        
end


BEEDAdata.respiration = Fdata(:,3)';
BEEDAdata.EDAdata = Fdata(:,2)';
BEEDAdata.sampletimes = Fdata(:,1)';



for Eidx = 1:numel(event_times(:,1))
    BEEDAdata.event(Eidx).time = event_times(Eidx);
    BEEDAdata.event(Eidx).nid = event_nums(Eidx);
    BEEDAdata.event(Eidx).name = event_names{Eidx};
end

BEEDAdata.savedfile = 'false';



end

