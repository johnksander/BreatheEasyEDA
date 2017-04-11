function BEEDAdata = set_main_analysisparams(BEEDAdata)


options.Resize='off';
options.WindowStyle='modal';
options.Interpreter='tex';
prompt = {'Enter SCR threshold (\muS)','Enter rejection rate (%)'};
dlg_title = 'SCR analysis parameters';
num_lines = 1;
def = {'.03','10'};
answer = inputdlg(prompt,dlg_title,num_lines,def,options);
clear options
BEEDAdata.SCRs.threshold = str2num(answer{1});
BEEDAdata.SCRs.rejection_rate = str2num(answer{2})/100; %change back to percent



