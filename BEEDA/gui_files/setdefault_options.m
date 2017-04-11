function [BEEDAdata] = setdefault_options(BEEDAdata)


BEEDAdata = get_BEEDAevent_array(BEEDAdata);
BEEDAdata.event_types = unique(BEEDAdata.event_array(:,3));

options.settings_text{1,1} = 'Min SCR latency  = 3';
options.settings_text{2,1} = 'Max SCR latency = end of trial';
options.settings_text{3,1} = ['SCR threshold     = ' num2str(BEEDAdata.SCRs.threshold) ' ' char(956) 'S'];
options.settings_text{4,1} = ['Rejection rate      = ' num2str(BEEDAdata.SCRs.rejection_rate * 100) '%'];
options.settings_text{5,1} = 'Trial types of interest = ';
options.settings_text{6,1} = 'Expanded trial window = 3(s)';
options.settings_text{7,1} = 'Number of trial windows to display = 4';


%options.settings_text{1,2} = '0'; %default
%options.settings_text{3,2} = 'end of trial'; %default

options.min_SCR_latency = 3;
options.max_SCR_latency = 'end of trial';
options.trials_of_interest = [];
options.expand_trialwin = 3;
options.num_trials2plot = 4;


options.twinzoom = 'off';
options.twinzoom_factor = NaN;

BEEDAdata.options = options;