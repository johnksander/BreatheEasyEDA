function startBEEDA

format compact
global BEEDAdata

[BEEDAmat_fn,BEEDAmat_path] = select_intro;

load(fullfile(BEEDAmat_path,BEEDAmat_fn));

BEEDAdir = which('startBEEDA');
if isunix
    BEEDAdir = strsplit(BEEDAdir,'/startBEEDA.m');
elseif ispc
    BEEDAdir = strsplit(BEEDAdir,'startBEEDA.m');
end
BEEDAdir = char(BEEDAdir{1});
addpath(BEEDAdir);



switch BEEDAdata.savedfile
    case 'false'
        BEEDAdata.Hz_original = (length(BEEDAdata.sampletimes) -1) / (BEEDAdata.sampletimes(end) - BEEDAdata.sampletimes(1));
        %first smoothing
        BEEDAdata.EDAdata = smooth_mainfunc(BEEDAdata.EDAdata, 1 * BEEDAdata.Hz_original, .00001);
        downsample_answer = downsample_menu(BEEDAdata.Hz_original);
        BEEDAdata = downsample_followup(downsample_answer,BEEDAdata);
        if downsample_answer ~= 0
            newsample_rate =  BEEDAdata.Hz_original/BEEDAdata.downsample_factor;
            BEEDAdata.EDAdata = smooth_mainfunc(BEEDAdata.EDAdata, 1 * newsample_rate, .00001);
            BEEDAdata.EDAdata = smooth_mainfunc(BEEDAdata.EDAdata, newsample_rate*.5, .0003);
        elseif downsample_answer == 0
            %do nothing
        end
        BEEDAdata = set_main_analysisparams(BEEDAdata);
        BEEDAdata = get_SCRs(BEEDAdata);
        BEEDAdata = get_BEEDApoints(BEEDAdata); %get indicies for events, all other indicies moved to get_SCRs
end

f = figure('Visible','on','Position',[360,200,800,600],'NumberTitle','off');
f.Name = 'BreatheEasyEDA';
%plot experiment overview-------------------
axes('Units','normalized','Position',[.05,.75,.9,.2]);
plot(BEEDAdata.sampletimes,BEEDAdata.EDAdata)
hold on
curr_ylim = ylim;
scatter(BEEDAdata.sampletimes(BEEDAdata.SCRs.index_onsets),BEEDAdata.SCRs.onsetlevels,'filled')
lineY(1,:) = repmat(curr_ylim(2),1,numel(BEEDAdata.index_events));
lineY(2,:) = repmat(curr_ylim(1),1,numel(BEEDAdata.index_events));
eventpoints4plotline = repmat(BEEDAdata.sampletimes(BEEDAdata.index_events),2,1);
line(eventpoints4plotline,lineY,'Color','g');
legend('EDA','SCR onsets','Events')
xlabel('Seconds')
ylabel('EDA \muS')
pan xon
zoom xon
hold off
uicontrol('Style','text','String','Experiment','Units','normalized',...
    'Position',[.37,.96,.26,.03],'FontSize',15,'FontWeight','bold');
%------------------------------------------
%plot trials types & settings--------------
switch BEEDAdata.savedfile
    case 'false'
        %[BEEDAdata,options] = setdefault_options(BEEDAdata);
        BEEDAdata = setdefault_options(BEEDAdata);
    case 'true'
        %options = BEEDAdata.options;
end

event_display = uipanel('Title','Trial Types','FontSize',15,'BackgroundColor','white',...
    'Position',[.03 .03 .45 .67],'FontWeight','bold','TitlePosition','centertop');
eventType_text = uicontrol('Style','text','String',BEEDAdata.event_types,'Units','normalized',...
    'Position',[0,0,1,.98],'FontSize',12,'BackgroundColor','white','parent',event_display);
settings_display = uipanel('Title','Settings','FontSize',15,'BackgroundColor','white',...
    'Position',[.53 .4 .45 .3],'FontWeight','bold','TitlePosition','centertop');
settingDisp_option_text = uicontrol('Style','text','String',BEEDAdata.options.settings_text(:,1),'Units','normalized',...
    'Position',[0,0,1,.98],'FontSize',12,'BackgroundColor','white','parent',settings_display,'HorizontalAlignment','left');
%settingDisp_text = uicontrol('Style','text','String',BEEDAdata.options.settings_text(:,2),'Units','normalized',...
%'Position',[.6,0,.4,.98],'FontSize',12,'BackgroundColor','white','parent',settings_display);

%------------------------------------------
%setting buttons---------------------------

min_scrbutton = uicontrol('Style','pushbutton','String','Set min SCR latency','Units','normalized',...
    'Position',[.53,.3,.2,.08],'Callback',@Minbut_Callback,'FontSize',12);
max_scrbutton = uicontrol('Style','pushbutton','String','Set max SCR latency','Units','normalized',...
    'Position',[.53,.2,.2,.08],'Callback',@Maxbut_Callback,'FontSize',12);
TOI_button = uicontrol('Style','pushbutton','String','Define trial types of interest','Units','normalized',...
    'Position',[.53,.1,.2,.08],'Callback',@TOIbut_Callback,'FontSize',12);
edit_disp_settings_but = uicontrol('Style','pushbutton','String','Display settings',...
    'Units','normalized','Position',[.75,.3,.2,.08],'Callback',@edit_disp_settings_Callback,'FontSize',12);
save_button = uicontrol('Style','pushbutton','String','Save current dataset','Units','normalized',...
    'Position',[.75,.1,.2,.08],'Callback',@save_Callback,'FontSize',12,'FontWeight','bold');
export_results_button = uicontrol('Style','pushbutton','String','Export final results','Units','normalized',...
    'Position',[.75,.01,.2,.07],'Callback',@export_results_Callback,'FontSize',12);
IRR_button = uicontrol('Style','pushbutton','String','Inter-rater reliability','Units','normalized',...
    'Position',[.53,.01,.2,.07],'Callback',@IRR_Callback,'FontSize',12);
%------------------------------------------
%scrub buttons-----------------------------

scrub_button = uicontrol('Style','pushbutton','String','Remove artifacts','Units','normalized',...
    'Position',[.75,.2,.2,.08],'Callback',@scrub_Callback,'FontSize',12,'FontWeight','bold');

%------------------------------------------
%setting buttons callback------------------

    function Minbut_Callback(source,eventdata)
        prompt = {'Enter Min SCR latency in seconds:'};
        dlg_title = 'Min SCR latency';
        BEEDAdata.options.min_SCR_latency = inputdlg(prompt,dlg_title);
        BEEDAdata.options.min_SCR_latency = char(BEEDAdata.options.min_SCR_latency);
        BEEDAdata.options.settings_text{1,1} = ['Min SCR latency  = ' BEEDAdata.options.min_SCR_latency];
        set(settingDisp_option_text,'String',BEEDAdata.options.settings_text(:,1))
        BEEDAdata.options.min_SCR_latency = str2double(BEEDAdata.options.min_SCR_latency);
    end


    function Maxbut_Callback(source,eventdata)
        prompt = {'Enter MAX SCR latency in seconds (end of trial is default setting):'};
        dlg_title = 'Max SCR latency';
        default = {'end of trial'};
        BEEDAdata.options.max_SCR_latency = inputdlg(prompt,dlg_title,1,default);
        BEEDAdata.options.max_SCR_latency = char(BEEDAdata.options.max_SCR_latency);
        BEEDAdata.options.settings_text{2,1} = ['Max SCR latency = ' BEEDAdata.options.max_SCR_latency];
        set(settingDisp_option_text,'String',BEEDAdata.options.settings_text(:,1))
        if strcmp(BEEDAdata.options.max_SCR_latency,default) == 0
            BEEDAdata.options.max_SCR_latency = str2double(BEEDAdata.options.max_SCR_latency);
        elseif strcmp(BEEDAdata.options.max_SCR_latency,default) == 1
            %do nothing
        end
    end


    function TOIbut_Callback(source,eventdata)
        prompt = {'Enter space-seperated event type #s:'};
        dlg_title = 'Trial types of interest';
        BEEDAdata.options.trials_of_interest = inputdlg(prompt,dlg_title);
        BEEDAdata.options.trials_of_interest = char(BEEDAdata.options.trials_of_interest);
        BEEDAdata.options.settings_text{5,1} = ['Trial types of interest = ' BEEDAdata.options.trials_of_interest];
        set(settingDisp_option_text,'String',BEEDAdata.options.settings_text(:,1))
        BEEDAdata.options.trials_of_interest = str2num(BEEDAdata.options.trials_of_interest);
    end


    function edit_disp_settings_Callback(source,eventdata) %set up later
        prompt = {'Set display limits for trial windows (+seconds)','Set Number of Trial Windows to Display'};
        dlg_title = 'Display Settings';
        disp_settings_defaultval = {num2str(BEEDAdata.options.expand_trialwin),num2str(BEEDAdata.options.num_trials2plot)};
        answer2display_settings = inputdlg(prompt,dlg_title,1,disp_settings_defaultval);
        exp_Twin_dlg_ans = answer2display_settings{1};
        if isempty(exp_Twin_dlg_ans)
            exp_Twin_dlg_ans = 'original default';
        end
        switch char(exp_Twin_dlg_ans)
            case 'original default'
                exp_Twin_dlg_ans = disp_settings_defaultval{1};
                BEEDAdata.options.expand_trialwin = str2double(exp_Twin_dlg_ans);
                BEEDAdata.options.settings_text{6,1} = ['Expanded trial window = ' char(exp_Twin_dlg_ans ) '(s)'];
                set(settingDisp_option_text,'String',BEEDAdata.options.settings_text(:,1))
            otherwise
                BEEDAdata.options.expand_trialwin = str2double(exp_Twin_dlg_ans);
                BEEDAdata.options.settings_text{6,1} = ['Expanded trial window = ' char(exp_Twin_dlg_ans) '(s)'];
                set(settingDisp_option_text,'String',BEEDAdata.options.settings_text(:,1))
        end
        num_Twins2disp_dlg_ans = answer2display_settings{2};
        switch char(num_Twins2disp_dlg_ans)
            case 'original default'
                num_Twins2disp_dlg_ans = disp_settings_defaultval{2};
                BEEDAdata.options.expand_trialwin = str2double(num_Twins2disp_dlg_ans);
                BEEDAdata.options.settings_text{7,1} = ['Number of trial windows to display = ' char(num_Twins2disp_dlg_ans )];
                set(settingDisp_option_text,'String',BEEDAdata.options.settings_text(:,1))
            otherwise
                BEEDAdata.options.num_trials2plot = str2double(num_Twins2disp_dlg_ans);
                BEEDAdata.options.settings_text{7,1} = ['Number of trial windows to display = ' char(num_Twins2disp_dlg_ans)];
                set(settingDisp_option_text,'String',BEEDAdata.options.settings_text(:,1))
        end
        
        %disp(sprintf('option under construction'))
        
        
        %         prompt = {'Set new default for zoom factor'};
        %         dlg_title = 'Set zoom default';
        %         default = {'original default'};
        %         answer2zoomset = inputdlg(prompt,dlg_title,1,default);
        %         if isempty(answer2zoomset)
        %             answer2zoomset = 'original default';
        %         end
        %         switch char(answer2zoomset)
        %             case 'original default'
        %                 BEEDAdata.options.twinzoom_factor = NaN;
        %                 BEEDAdata.options.twinzoom = 'off';
        %             otherwise
        %                 BEEDAdata.options.twinzoom = 'on';
        %                 BEEDAdata.options.twinzoom_factor = str2double(answer2zoomset);
        %         end
        %         delete(axhandle)
        %         axhandle = plot_twins();
    end
%------------------------------------------
%scrub window configs----------------------

%------------------------------------------
%scrub buttons callback--------------------
    function scrub_Callback(source,eventdata)
        
        if isempty(BEEDAdata.options.trials_of_interest)
            disp('ERROR: Trials of interest must be defined first')
        else
            if ~isfield(BEEDAdata,'TOI')
                %first call
                BEEDAdata = get_trial_data(BEEDAdata); %rejection rate excluding located here
                BEEDAdata = make_TOI_history(BEEDAdata);
            else
                %figure out if TOIs have changed, handle accordingly
                BEEDAdata = control_TOI_data(BEEDAdata);
            end
            
            build_scrub_window()
        end
    end




%------------------------------------------
%save button callback----------------------
    function save_Callback(source,eventdata)
        BEEDAdata.savedfile = 'true';
        %BEEDAdata.options = options;
        uisave('BEEDAdata')
    end


%------------------------------------------
%IRR button callback----------------------
    function IRR_Callback(source,eventdata)
        IRRinfo = IRR_intro();
        doIRR(IRRinfo)
    end



%------------------------------------------
%export results button callback------------
    function export_results_Callback(source,eventdata)
        
        if ~isfield(BEEDAdata,'TOI') & ~isempty(BEEDAdata.options.trials_of_interest)
            BEEDAdata = get_trial_data(BEEDAdata); %rejection rate excluding located here
            disp(sprintf('WARNING: BEEDA artifact removal not used with this dataset'))
        end
        
        if ~isfield(BEEDAdata,'TOI') | isempty(BEEDAdata.options.trials_of_interest)
            disp(sprintf('ERROR: No trials of interest defined'))
        else
            
            check_answer = checkUser4save();
            switch check_answer
                case 'go'
                    trial_num_labels = cell2mat(BEEDAdata.event_array(:,2));
                    trial_names = BEEDAdata.event_array(:,3);
                    TOI_mask = ismember(trial_num_labels,BEEDAdata.options.trials_of_interest);
                    trial_num_labels = trial_num_labels(TOI_mask);
                    trial_names = trial_names(TOI_mask);
                    num_trialSCRs = NaN(numel(trial_num_labels),1);
                    avg_trialSCRmag = NaN(numel(trial_num_labels),1);
                    max_trialSCRmag = NaN(numel(trial_num_labels),1);
                    sum_trialSCRmag = NaN(numel(trial_num_labels),1);
                    avg_trialSCL = NaN(numel(trial_num_labels),1);
                    std_trialSCL = NaN(numel(trial_num_labels),1);
                    trial_scrub_info = cell(numel(trial_num_labels),1);
                    edited_trials = ...
                        unique(horzcat(BEEDAdata.TOI.undo_deleted_resp_segments,BEEDAdata.TOI.undo_deleted));
                    edited_trials = edited_trials(edited_trials~=9999 & ~isnan(edited_trials));
                    trial_scrub_info(edited_trials) = {'artifacts flagged'};
                    for idx = 1:numel(trial_num_labels)
                        num_trialSCRs(idx) = numel(BEEDAdata.TOI.SCRs{idx});
                        avg_trialSCRmag(idx) =  mean(BEEDAdata.SCRs.peaklevels(BEEDAdata.TOI.SCRs_index{idx}) ...
                            - BEEDAdata.SCRs.onsetlevels(BEEDAdata.TOI.SCRs_index{idx}));
                        if ~isempty(BEEDAdata.SCRs.peaklevels(BEEDAdata.TOI.SCRs_index{idx}) ... %if max returns an empty cell, matlab gets mad
                                - BEEDAdata.SCRs.onsetlevels(BEEDAdata.TOI.SCRs_index{idx}))
                            max_trialSCRmag(idx) =  max(BEEDAdata.SCRs.peaklevels(BEEDAdata.TOI.SCRs_index{idx}) ...
                                - BEEDAdata.SCRs.onsetlevels(BEEDAdata.TOI.SCRs_index{idx}));
                        end
                        sum_trialSCRmag(idx) =  sum(BEEDAdata.SCRs.peaklevels(BEEDAdata.TOI.SCRs_index{idx}) ...
                            - BEEDAdata.SCRs.onsetlevels(BEEDAdata.TOI.SCRs_index{idx}));
                        valid_respiration_mask = BEEDAdata.TOI.resp_segment_scrubmasks{idx}(2,:);
                        valid_respiration_mask = ~valid_respiration_mask;
                        valid_respiration_idx = BEEDAdata.TOI.resp_segment_scrubmasks{idx}(1,valid_respiration_mask);
                        avg_trialSCL(idx) = mean(BEEDAdata.EDAdata(valid_respiration_idx));
                        std_trialSCL(idx) = std(BEEDAdata.EDAdata(valid_respiration_idx));
                    end
                    spreadsheet_array = cell(numel(trial_num_labels),3);
                    spreadsheet_array(:,1) = trial_names;
                    spreadsheet_array(:,2) = num2cell(trial_num_labels);
                    spreadsheet_array(:,3) = num2cell(num_trialSCRs);
                    spreadsheet_array(:,4) = num2cell(avg_trialSCRmag);
                    spreadsheet_array(:,5) = num2cell(max_trialSCRmag);
                    spreadsheet_array(:,6) = num2cell(sum_trialSCRmag);
                    spreadsheet_array(:,7) = num2cell(avg_trialSCL);
                    spreadsheet_array(:,8) = num2cell(std_trialSCL);
                    spreadsheet_array(:,9) = trial_scrub_info;
                    
                    header = {'Trial name','Trial type #','Number of SCRs','Average SCR magnitude','Max SCR magnitude',...
                        'Cumulative SCR magnitude','SCL(average)','SCL(standard deviation)','Artifacts'};
                    spreadsheet_array = vertcat(header,spreadsheet_array);
                    
                    [sv_FileName,sv_PathName] = uiputfile('*','Save results');
                    write2csv(fullfile(sv_PathName,sv_FileName),spreadsheet_array)
                    
                case 'stop'
                    %do nothing
                    
            end
            
        end
        
        
    end
end

