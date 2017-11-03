function doIRR(user_info)
%Inter-rater reliability

warning('off','MATLAB:table:ModifiedVarnames') %suppress readtable() warn
rater_info = readtable(user_info.FN,'ReadVariableNames',false);
raterFNs = rater_info.Var1;
rater_names = rater_info.Var2;
num_raters = numel(rater_names);
kappa_array = NaN(num_raters,num_raters);
%fix filenames without extension, if any
FNs2fix = cellfun(@(x) ~strcmpi('.csv',x(end-3:end)),raterFNs);
raterFNs(FNs2fix) = cellfun(@(x) [x '.csv'],raterFNs(FNs2fix),'UniformOutput',false);

%append filepath & check for existence 
raterFNs = cellfun(@(x) fullfile(user_info.Fdir,x),raterFNs,'UniformOutput',false);
excheck = cellfun(@(x) exist(x) > 0,raterFNs);

if sum(~excheck) > 0
    missfiles = strjoin(raterFNs(~excheck),', ');
    errhdr = '---------------------------------';
    message = sprintf(['%s\nthe files:\n    %s\neither do not exist, or are not located'...
        ' in the directory:\n    %s\n%s'],errhdr,missfiles,user_info.Fdir,errhdr);
    error(message)
end

%load exported datasheets
data = cellfun(@(x) readtable(x),raterFNs,'UniformOutput',false);
artifacts = cellfun(@(x) ~cellfun(@isempty,x.Artifacts),data,'UniformOutput',false);

Ntotal = unique(cellfun(@(x) size(x,1),data));
%safety check
if numel(Ntotal) > 1
    error('raters have inconsistent trial numbers')
end


switch user_info.Tmode
    case 'SCRonly'
        %SCRs aren't marked in results file when flagged for artifacts
        %trial N = all flagged & all SCR trials across all raters
        SCRtrials = cellfun(@(x) x.NumberOfSCRs > 0 ,data,'UniformOutput',false);
        valid_trials = [cell2mat(artifacts') cell2mat(SCRtrials')];
        valid_trials = sum(valid_trials,2) > 0;

    case 'allTOI'
        valid_trials = logical(ones(Ntotal,1));      
end


rater_data = cellfun(@(x) x(valid_trials),artifacts,'UniformOutput',false);
%interrater reliability between scorers
for rateridx = 1:num_raters
    for second_rater_idx = 1:num_raters
        if rateridx > second_rater_idx %only do lower diagonal
            pair_inds = [rateridx,second_rater_idx];
            data2compare = cell2mat(rater_data(pair_inds)');
            cohens_kappa = cohenk_score(data2compare);
            kappa_array(rateridx,second_rater_idx) = cohens_kappa;
        end
    end
end

header = cell(1,num_raters+1);
header{1} = 'Cohen''s kapppa inter-rater reliability matrix';
sheet_output = [rater_names,num2cell(kappa_array)];
sheet_output = [[{''},rater_names'];sheet_output];
sheet_output = [header;sheet_output];

[FN,Fdir] = uiputfile('*','Save results');
write2csv(fullfile(Fdir,FN),sheet_output)




