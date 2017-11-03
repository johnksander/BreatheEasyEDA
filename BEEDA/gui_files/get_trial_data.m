function BEEDAdata = get_trial_data(BEEDAdata)


%end of trial is defined by beginning of the next event
%find trials to plot
current_types = BEEDAdata.options.trials_of_interest;
trial_num_labels = cell2mat(BEEDAdata.event_array(:,2));
TOI_mask = ismember(trial_num_labels,current_types);
TOI_starttimes = BEEDAdata.event_array(TOI_mask,1); %use for excluding SCRs below min latenency
TOI_index_start = BEEDAdata.index_events(TOI_mask); %get startpoints
TOI_end_indices = find(TOI_mask) + 1; %get index after start
TOIend_mask = zeros(size(TOI_mask));
if max(TOI_end_indices) <= numel(BEEDAdata.index_events) %you're good
    TOIend_mask(TOI_end_indices) = 1;
    TOIend_mask = logical(TOIend_mask);
    TOI_index_end = BEEDAdata.index_events(TOIend_mask); %get endpoints
elseif max(TOI_end_indices) == (numel(BEEDAdata.index_events) + 1)
    %last event is a trial of interest, set index to end of data timecourse
    TOI_end_indices(end) = numel(BEEDAdata.index_events);
    TOIend_mask(TOI_end_indices) = 1;
    TOIend_mask = logical(TOIend_mask);
    TOI_index_end = BEEDAdata.index_events(TOIend_mask); 
    TOI_index_end(end) = numel(BEEDAdata.sampletimes);
end

trials2scrub = sum(TOI_mask);

TOI_respiration_data = cell(trials2scrub,1);
TOI_SCRs = cell(trials2scrub,1);
TOI_SCRs_index = cell(trials2scrub,1);
TOI_deleted_SCRs = cell(trials2scrub,1);
TOI_undo_deleted = NaN;
TOI_deleted_resp_segments = cell(trials2scrub,1);
TOI_undo_deleted_resp_segments = NaN;


for idx = 1:trials2scrub %get trial resp data % SCRs
    
    TOI_respiration_data{idx} = BEEDAdata.respiration(TOI_index_start(idx):TOI_index_end(idx));
    curr_scrpoints = find((BEEDAdata.SCRs.index_onsets >= TOI_index_start(idx) & BEEDAdata.SCRs.index_onsets <= TOI_index_end(idx)));
    TOI_SCRs{idx} =  BEEDAdata.SCRs.index_onsets(curr_scrpoints);
    TOI_SCRs_index{idx} = curr_scrpoints;
end

switch BEEDAdata.options.max_SCR_latency
    case 'end of trial'
            for idx = 1:trials2scrub
                %remove them from cell array
                curr_SCRs = find((BEEDAdata.SCRs.index_onsets >= TOI_index_start(idx) & BEEDAdata.SCRs.index_onsets <= TOI_index_end(idx)));      
                curr_SCRtimes = BEEDAdata.SCRs.onsets(curr_SCRs);
                curr_SCRtimes = curr_SCRtimes - TOI_starttimes{idx};
                if sum(curr_SCRtimes < BEEDAdata.options.min_SCR_latency) > 0
                    remSCR = find(curr_SCRtimes < BEEDAdata.options.min_SCR_latency);
                    TOI_SCRs{idx}(remSCR) = [];
                    TOI_SCRs_index{idx}(remSCR) = [];
                end
            end
    otherwise
        for idx = 1:trials2scrub
            %remove them from cell array
            curr_SCRs = find((BEEDAdata.SCRs.index_onsets >= TOI_index_start(idx) & BEEDAdata.SCRs.index_onsets <= TOI_index_end(idx)));
            curr_SCRtimes = BEEDAdata.SCRs.onsets(curr_SCRs);
            curr_SCRtimes = curr_SCRtimes - TOI_starttimes{idx};
            if sum(curr_SCRtimes < BEEDAdata.options.min_SCR_latency) | sum(curr_SCRtimes > BEEDAdata.options.max_SCR_latency) > 0
                remSCR = find(curr_SCRtimes < BEEDAdata.options.min_SCR_latency | curr_SCRtimes > BEEDAdata.options.max_SCR_latency);
                TOI_SCRs{idx}(remSCR) = [];
                TOI_SCRs_index{idx}(remSCR) = [];
            end
        end
end




if BEEDAdata.SCRs.rejection_rate > 0 %exclude SCRs below rejection rate 
    for idx = 1:trials2scrub %remove them from cell array
        curr_ampls = BEEDAdata.SCRs.ampl(TOI_SCRs_index{idx});
        cutoff = max(curr_ampls) * BEEDAdata.SCRs.rejection_rate;   
        if sum(curr_ampls < cutoff) > 0
            remSCR = find(curr_ampls < cutoff);
            TOI_SCRs{idx}(remSCR) = [];
            TOI_SCRs_index{idx}(remSCR) = [];
        end
    end
end


TOI_resp_segment_scrubmasks = cell(trials2scrub,1);
for idx = 1:trials2scrub
    %triallength = numel(TOI_index_start(idx):TOI_index_end(idx));
    TOI_resp_segment_scrubmasks{idx} = [TOI_index_start(idx):TOI_index_end(idx);...
        zeros(1,numel(TOI_index_start(idx):TOI_index_end(idx)))];
end



if BEEDAdata.options.min_SCR_latency > 0 %remove SCL data below min latenency
   for idx = 1:trials2scrub 
        curr_timewin = BEEDAdata.sampletimes(TOI_resp_segment_scrubmasks{idx}(1,:));
        minSCLlatency = curr_timewin(1) + BEEDAdata.options.min_SCR_latency;
        points2flip = find(curr_timewin < minSCLlatency);
        TOI_resp_segment_scrubmasks{idx}(2,points2flip) = 1;
    end
end

BEEDAdata.TOI.current_types = current_types;
BEEDAdata.TOI.SCRs = TOI_SCRs;
BEEDAdata.TOI.SCRs_index = TOI_SCRs_index; %index of original SCR list
BEEDAdata.TOI.respiration_data = TOI_respiration_data;
BEEDAdata.TOI.index_start = TOI_index_start; %used to be startpoints
BEEDAdata.TOI.index_end = TOI_index_end;
BEEDAdata.TOI.deleted_SCRs = TOI_deleted_SCRs;
BEEDAdata.TOI.undo_deleted = TOI_undo_deleted;
BEEDAdata.TOI.resp_segment_scrubmasks = TOI_resp_segment_scrubmasks;
BEEDAdata.TOI.deleted_resp_segments = TOI_deleted_resp_segments;
BEEDAdata.TOI.undo_deleted_resp_segments = TOI_undo_deleted_resp_segments;

end




