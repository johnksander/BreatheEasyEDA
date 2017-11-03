function BEEDAdata = control_TOI_data(BEEDAdata)

%are there new TOI types specified?
newTOIs = ~ismember(BEEDAdata.options.trials_of_interest,BEEDAdata.TOI.current_types);
newTOIs = BEEDAdata.options.trials_of_interest(newTOIs);
dropped_TOIs = ~ismember(BEEDAdata.TOI.current_types,BEEDAdata.options.trials_of_interest);
dropped_TOIs = BEEDAdata.TOI.current_types(dropped_TOIs);

if ~isempty(newTOIs) || ~isempty(dropped_TOIs)
    %new TOIs specified
    %there's already a history, need to do this:
    %1) all TOIs need to be archived (or archive updated)
    %2) make a fresh TOI structure 
    %2) pull all new TOIs, if re-added and must be pulled from history
    %in that order
    
    %1)
    BEEDAdata = resolve_TOI_history(BEEDAdata,'archive');
    %2)
    BEEDAdata = get_trial_data(BEEDAdata); %rejection rate excluding located here
    %3)
    BEEDAdata = resolve_TOI_history(BEEDAdata,'pull');
end








