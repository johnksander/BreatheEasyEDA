function BreatheEasyEDA
%Start BEEDA 
curr_dir = which('BreathEasyEDA');
if isunix
    curr_dir = strsplit(curr_dir,'/BreatheEasyEDA.m');
elseif ispc
    curr_dir = strsplit(curr_dir,'BreatheEasyEDA.m');
end
curr_dir = char(curr_dir{1});
run(fullfile(curr_dir,'BEEDA','gui_files','startBEEDA.m'));