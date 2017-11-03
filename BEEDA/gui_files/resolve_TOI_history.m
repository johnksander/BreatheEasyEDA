function BEEDAdata = resolve_TOI_history(BEEDAdata,action)

current_types = BEEDAdata.options.trials_of_interest;
trial_num_labels = cell2mat(BEEDAdata.event_array(:,2));

switch action
    case 'archive'
        
        prev_types = BEEDAdata.TOI.current_types; %yea that var name is a little misleading here...
        [TOIs2arch,arc_inds] = make_inds(prev_types,BEEDAdata);
        %add this to the history
        %or replace if already present, would've been pulled from history
        %if re-added before... so the current data is historically accurate
        FNs = fieldnames(BEEDAdata.TOI.history);
        FNs = FNs(~strcmp(FNs,'types')); %do this one seperately
        for idx = 1:numel(FNs) %update everything
            hist_data = getfield(BEEDAdata.TOI.history,FNs{idx});
            %expand array
            if iscell(hist_data)
                combined_array = cell(numel(trial_num_labels),1);
            elseif isnumeric(hist_data)
                combined_array = NaN(numel(trial_num_labels),1);
            end
            %add historical data
            combined_array(arc_inds) = hist_data;
            %add in all new data
            data2arch = getfield(BEEDAdata.TOI,FNs{idx});
            combined_array(TOIs2arch) = data2arch;
            %recompress
            combined_array = combined_array(TOIs2arch | arc_inds);
            %archive
            BEEDAdata.TOI.history = setfield(BEEDAdata.TOI.history,FNs{idx},combined_array);
        end
        %update the types in history
        BEEDAdata.TOI.history.types = unique(trial_num_labels(TOIs2arch | arc_inds));
        
    case 'pull'
        
        %check the types in history
        historic_types =  BEEDAdata.TOI.history.types;
        historic_types = historic_types(ismember(historic_types,current_types));
        [TOIs2pull,~,archived_types] = make_inds(historic_types,BEEDAdata);
        %this the logical fo currently specified TOIs that exist in the history        
        %add everything
        FNs = fieldnames(BEEDAdata.TOI.history);
        FNs = FNs(~strcmp(FNs,'types')); %do this one seperately
        for idx = 1:numel(FNs) %update everything
            %get current TOI data 
            %current_data = getfield(BEEDAdata.TOI,FNs{idx});
            %pull historical data 
            hist_data = getfield(BEEDAdata.TOI.history,FNs{idx});
            %expand array
            if iscell(hist_data)
                combined_array = cell(numel(trial_num_labels),1);
            elseif isnumeric(hist_data)
                combined_array = NaN(numel(trial_num_labels),1);
            end
            %add in historical data for currently spec TOIs 
            combined_array(TOIs2pull) = hist_data(historic_types == archived_types);
            %recompress
            combined_array = combined_array(ismember(trial_num_labels,current_types));
            %set it & forget it 
            BEEDAdata.TOI = setfield(BEEDAdata.TOI,FNs{idx},combined_array);
        end        
end

    function [TOIbool,arch_bool,arc_types] = make_inds(OI,BEEDAdata)
        %construct indicies for BEEDAdata.TOI and BEEDAdata.TOI.history
        %Makes these indicies for  "of interest" OI types.. 
        tlabels = cell2mat(BEEDAdata.event_array(:,2));
        %for indexing trial_num_labels
        TOIbool = ismember(tlabels,OI);
        arch_bool = BEEDAdata.TOI.history.types;
        arch_bool = ismember(tlabels,arch_bool);
        arc_types = tlabels(arch_bool);
    end
  
end
