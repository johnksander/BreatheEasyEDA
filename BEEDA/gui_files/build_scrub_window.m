function build_scrub_window()
global BEEDAdata


scrsz = get(groot,'ScreenSize');
scrub_window = figure('Visible','on','Position',[scrsz(3)/3 1 700 (scrsz(4)-150)],'NumberTitle','off');
scrub_window.Name = 'Remove artifacts';
set(scrub_window,'WindowButtonDownFcn',@remove_artifacts)
set(scrub_window,'Interruptible','off','BusyAction','cancel')
addlistener(scrub_window,'WindowKeyPress',@keyboard_input); %zoom/pan keypress fiasco


colors = lines;
redcolor = colors(2,:);

remove_pause = .1; %pause in seconds to fix major bug

firsttrial2plot = 1;
total_trials = numel(BEEDAdata.TOI.index_end);
if total_trials >= BEEDAdata.options.num_trials2plot
    %initialize normally
    num_trials2plot = BEEDAdata.options.num_trials2plot; %now set in main menu, default is 4
    lasttrial2plot = BEEDAdata.options.num_trials2plot; %now set in main menu, default is 4
elseif total_trials < BEEDAdata.options.num_trials2plot
    %requested num_trials2plot is greater than number of TOIs... 
    num_trials2plot = total_trials;
    lasttrial2plot = total_trials;
end

%current_page = 1;

room_at_top = .05;
trialwin_width = .9;
trialwin_height = .2;

delbut_color = [.94 .94 .94 ]; %delete tool button startup defaults
delbut_state = 0;
debut_label = 'Delete OFF';
allow_delete = 'no';
single_selection = 'off'; %safeguard
drag2select = 0; %default is off
drag_selection = []; %initalize
dragdata = []; %initalize

% text_numtwin = uicontrol('Style','text','String',num2str(num_trials2plot),'Units','normalized',...
%     'Position',[.10,.96,.05,.02],'FontSize',20,'FontWeight','Bold');
% text_eplain_numtwin = uicontrol('Style','text','String','# trials displayed','Units','normalized',...
%     'Position',[0,.98,.25,.02],'FontSize',12);

text_flippage = uicontrol('Style','text','String','Flip page','Units','normalized',...
    'Position',[.23,.98,.1,.02],'FontSize',12);
text_akeyReminder = uicontrol('Style','text','String','Press A to enable/disable single SCR delete','Units','normalized',...
    'Position',[.5,.96,.4,.02],'FontSize',12,'HorizontalAlignment','left');
text_dkeyReminder = uicontrol('Style','text','String','Press D to begin drag delete','Units','normalized',...
    'Position',[.5,.94,.4,.02],'FontSize',12,'HorizontalAlignment','left');
text_arrowkeyReminder = uicontrol('Style','text','String','Press Left/Right arrow keys to flip pages','Units','normalized',...
    'Position',[.5,.98,.4,.02],'FontSize',12,'HorizontalAlignment','left');

axhandle = plot_twins(); %plot trial windows

go2trial_but = uicontrol('Style','pushbutton','String','Go to trial','Units','normalized',...
    'Position',[.09,.955,.12,.03],'Callback',@go2trial_but_Callback,'FontSize',12);

% sub_twinbut = uicontrol('Style','pushbutton','String','-','Units','normalized',...
%     'Position',[.05,.96,.05,.02],'Callback',@sub_twinbut_Callback,'FontSize',30,'FontWeight','Bold');
% add_twinbut = uicontrol('Style','pushbutton','String','+','Units','normalized',...
%     'Position',[.15,.96,.05,.02],'Callback',@add_twinbut_Callback,'FontSize',20,'FontWeight','Bold');


nextpage_but = uicontrol('Style','pushbutton','String','>','Units','normalized',...
    'Position',[.28,.96,.05,.02],'Callback',@nextpage_but_Callback,'FontSize',20,'FontWeight','Bold');
prevpage_but = uicontrol('Style','pushbutton','String','<','Units','normalized',...
    'Position',[.23,.96,.05,.02],'Callback',@prevpage_but_Callback,'FontSize',20,'FontWeight','Bold');
undo_but = uicontrol('Style','pushbutton','String','Undo',...
    'Units','normalized','Position',[.35,.938,.12,.03],'Callback',@undo_but_Callback,'FontSize',12);
delete_but = uicontrol('Style','pushbutton','String',debut_label,...
    'Units','normalized','Position',[.35,.97,.12,.03],'Callback',@delete_but_Callback,'FontSize',12,'BackGroundColor',delbut_color);
% zoomset_but = uicontrol('Style','pushbutton','String','zoom default',...
%     'Units','normalized','Position',[.5,.98,.1,.02],'Callback',@zoomset_but_Callback,'FontSize',10);

set(findobj('Type','uicontrol'),'Interruptible','off','BusyAction','cancel');



    function delete_but_Callback(source,eventdata)
        if delbut_state == 0
            delbut_state = 1; %turn it on
        elseif delbut_state == 1
            delbut_state = 0; %turn it off
        end
        
        if drag2select == 0 %normal behavior, single select
            if delbut_state == 0
                debut_label = 'Delete OFF';
                delbut_color = [.94 .94 .94 ];
                allow_delete = 'no';
            elseif delbut_state == 1
                debut_label = 'Delete ON';
                delbut_color = 'red';
                allow_delete = 'yes';
            end
            
        elseif drag2select == 1 %drag selecting active, drag2select
            if delbut_state == 0
                debut_label = 'Delete OFF';
                delbut_color = [.94 .94 .94 ];
                allow_delete = 'no';
            elseif delbut_state == 1
                debut_label = 'Drag Delete ON';
                delbut_color = 'yellow';
                allow_delete = 'yes';
            end
        end
        set(delete_but,'String',debut_label,'BackgroundColor',delbut_color)
    end

%     function add_twinbut_Callback(source,eventdata)
%         delete(axhandle)
%         num_trials2plot = num_trials2plot + 1;
%         lasttrial2plot = lasttrial2plot + 1;
%         if lasttrial2plot > numel(BEEDAdata.TOI.index_start) %if you tried to go above max # trials, reset changes
%             lasttrial2plot = numel(BEEDAdata.TOI.index_start);
%             num_trials2plot = num_trials2plot -1;
%         end
%         axhandle = plot_twins();
%     end
%
%     function sub_twinbut_Callback(source,eventdata)
%         delete(axhandle)
%         num_trials2plot = num_trials2plot - 1;
%         lasttrial2plot = lasttrial2plot - 1;
%         if num_trials2plot == 0 %if you tried to go below 0, reset changes
%             num_trials2plot = 1;
%             lasttrial2plot = lasttrial2plot + 1;
%         end
%         axhandle = plot_twins();
%         set(text_numtwin,'String',num2str(num_trials2plot))
%     end

    function keyboard_input(source,eventdata)
        switch eventdata.Key
            case 'rightarrow'
                uicontrol(nextpage_but)
                nextpage_but_Callback(nextpage_but,[]);
            case 'leftarrow'
                uicontrol(prevpage_but)
                prevpage_but_Callback(prevpage_but,[]);
            case 'a'
                if drag2select == 0 %safeguard
                    single_selection = set_SSval(single_selection);
                    uicontrol(delete_but)
                    delete_but_Callback(delete_but,[]);
                elseif drag2select == 1
                    %do nothing
                end
            case 'd'
                switch single_selection
                    case 'off' %safeguard
                        if drag2select == 0 %if it's off, turn it on
                            drag2select = 1;
                            drag_selection = 0;
                            dragdata = []; %reset
                        elseif drag2select == 1 %if it's on, turn it off
                            drag2select = 0;
                            drag_selection = [];
                            dragdata = []; %reset
                        end
                        uicontrol(delete_but)
                        delete_but_Callback(delete_but,[]);
                    case 'on'
                        %do nothing
                end
        end
        datacursormode on
        datacursormode off
    end


    function nextpage_but_Callback(source,eventdata)
        delete(axhandle)
        firsttrial2plot = lasttrial2plot + 1;
        lasttrial2plot = lasttrial2plot + num_trials2plot;
        if lasttrial2plot > numel(BEEDAdata.TOI.index_start) %if you tried to go over max # trials, get stopped
            lasttrial2plot = numel(BEEDAdata.TOI.index_start);
            firsttrial2plot =  lasttrial2plot - (num_trials2plot - 1);
        end
        axhandle = plot_twins();
    end

    function prevpage_but_Callback(source,eventdata)
        
        delete(axhandle)
        lasttrial2plot = firsttrial2plot - 1;
        firsttrial2plot = lasttrial2plot - (num_trials2plot - 1);
        if firsttrial2plot <= 0 %if you tried to go go below 0, get stopped
            firsttrial2plot = 1;
            lasttrial2plot = firsttrial2plot + (num_trials2plot - 1);
        end
        axhandle = plot_twins();
    end

    function go2trial_but_Callback(source,eventdata)
        prompt = {'Enter trial number:'};
        dlg_title = 'Go to trial';
        go2ans = inputdlg(prompt,dlg_title);
        go2ans = char(go2ans);
        delete(axhandle)
        if ~isempty(go2ans) & str2num(go2ans) <= numel(BEEDAdata.TOI.index_start) & str2num(go2ans) > 0
            delete(axhandle)
            firsttrial2plot = str2num(go2ans);
            lasttrial2plot = firsttrial2plot + (num_trials2plot -1);
            if lasttrial2plot > numel(BEEDAdata.TOI.index_start) %if you tried to go over max # trials, get stopped
                lasttrial2plot = numel(BEEDAdata.TOI.index_start);
                firsttrial2plot =  lasttrial2plot - (num_trials2plot - 1);
            end                
            axhandle = plot_twins();
        else
            %do nothing
        end
    end


    function axhandle = plot_twins()
        find_trial4legend = 0;
        for plotidx = firsttrial2plot:lasttrial2plot
            trialwin_bottom = (1 - room_at_top) - (trialwin_height * ((plotidx - firsttrial2plot) + 1));
            trialwin_bottom = trialwin_bottom - (.02 * ((plotidx - firsttrial2plot) + 1)); %buffer between windows
            axhandle(plotidx) = ...
                axes('Units','normalized','Position',[.07,trialwin_bottom,trialwin_width,trialwin_height]);
            trial_timevals = BEEDAdata.sampletimes([BEEDAdata.TOI.index_start(plotidx):BEEDAdata.TOI.index_end(plotidx)]);
            if BEEDAdata.options.expand_trialwin > 0
                adjstart = min(trial_timevals) - BEEDAdata.options.expand_trialwin;
                adjend = max(trial_timevals) + BEEDAdata.options.expand_trialwin;
                [~,adjstart] = min(abs(BEEDAdata.sampletimes - adjstart));
                [~,adjend] = min(abs(BEEDAdata.sampletimes - adjend));
                expanded_trialwin = BEEDAdata.sampletimes(adjstart:adjend);
                plot(expanded_trialwin,BEEDAdata.respiration(adjstart:adjend));
                xlim([expanded_trialwin(1) expanded_trialwin(end)])
                ylim([(min(BEEDAdata.respiration(adjstart:adjend)) -1) max(BEEDAdata.respiration(adjstart:adjend) + 1)])
            else
                plot(trial_timevals,BEEDAdata.TOI.respiration_data{plotidx});
                xlim([trial_timevals(1) trial_timevals(end)])
                ylim([(min(BEEDAdata.TOI.respiration_data{plotidx}) -1) max(BEEDAdata.TOI.respiration_data{plotidx} + 1)])
            end
            ylabel(['Trial:  ' num2str(plotidx) ' / ' num2str(numel(BEEDAdata.TOI.index_start))],...
                'FontSize',12,'FontWeight','Bold')
            
            
            %xlim([1 numel(BEEDAdata.TOI.respiration_data{plotidx})])
            %SCRlocs = BEEDAdata.TOI.SCRs{plotidx} - BEEDAdata.TOI.index_start(plotidx);
            SCRlocs = BEEDAdata.respiration(BEEDAdata.TOI.SCRs{plotidx});
            SCRtimes = BEEDAdata.sampletimes(BEEDAdata.TOI.SCRs{plotidx});
            hold on
            
            %plotting here goes trial start line, scrs, trial end line in
            %order to make the legend plotting nice
            
            if BEEDAdata.options.expand_trialwin > 0 
                currentYlimit = ylim;
                trialYlines = NaN(2,2);
                trialYlines(1,:) = currentYlimit(2);
                trialYlines(2,:) = currentYlimit(1);
                trialXspots = [BEEDAdata.TOI.index_start(plotidx) BEEDAdata.TOI.index_end(plotidx)];
                trialXspots = BEEDAdata.sampletimes(trialXspots);
                trialXspots = repmat(trialXspots,2,1);
                labels4legend = {'Respiration','Trial start/end','SCR onset'};
                plot(trialXspots(:,1),trialYlines(:,1),'Color',[.2 .7 .1]);
            else
                labels4legend = {'Respiration','SCR onset'};
            end
            
            scatter(SCRtimes,SCRlocs,150,redcolor,'filled')
            
            if BEEDAdata.options.expand_trialwin > 0 %swiched to before & after scatter b/c of legend issue
                plot(trialXspots(:,2),trialYlines(:,2),'Color',[.2 .7 .1]);
            end

            
            
            if sum(BEEDAdata.TOI.resp_segment_scrubmasks{plotidx}(2,:)) > 0
                for plotdeletedresp_idx = 1:numel(BEEDAdata.TOI.deleted_resp_segments{plotidx})
                    plot(BEEDAdata.TOI.deleted_resp_segments{plotidx}{plotdeletedresp_idx}(1,:),...
                        BEEDAdata.TOI.respiration_data{plotidx}(BEEDAdata.TOI.deleted_resp_segments{plotidx}{plotdeletedresp_idx}(2,:)),...
                        'Color',[0 0 0]);
                end
            end
            if plotidx == firsttrial2plot & ~isempty(SCRtimes)
                %legend('Respiration','SCR onset','Location','southwest')
                legend(labels4legend,'Location','southwest')
            elseif plotidx == firsttrial2plot & isempty(SCRtimes) & firsttrial2plot ~= lasttrial2plot
                find_trial4legend = 1;
            elseif plotidx == firsttrial2plot & isempty(SCRtimes) & firsttrial2plot == lasttrial2plot & BEEDAdata.options.expand_trialwin <= 0
                legend('Respiration','Location','southwest') %give up, show respiration legend
            elseif plotidx == firsttrial2plot & isempty(SCRtimes) & firsttrial2plot == lasttrial2plot & BEEDAdata.options.expand_trialwin > 0
                legend('Respiration','Trial start/end','Location','southwest') %give up, show respiration & trial start/end legend
            elseif plotidx > firsttrial2plot & find_trial4legend == 1
                if ~isempty(SCRtimes)
                    legend(labels4legend,'Location','southwest')
                    find_trial4legend = 0;
                elseif isempty(SCRtimes) & plotidx == lasttrial2plot & BEEDAdata.options.expand_trialwin <= 0
                    legend('Respiration','Location','southwest') %give up, show respiration legend
                elseif isempty(SCRtimes) & plotidx == lasttrial2plot & BEEDAdata.options.expand_trialwin > 0
                    legend('Respiration','Trial start/end','Location','southwest') %give up, show respiration & trial start/end legend
                elseif isempty(SCRtimes)
                    %keep looking
                end
            end
            zoomobj = zoom;
            panobj = pan;
            setAxesZoomMotion(zoomobj,axhandle(plotidx),'horizontal');
            setAxesPanMotion(panobj,axhandle(plotidx),'horizontal');
            
            switch BEEDAdata.options.twinzoom
                case 'on'
                    zoom(BEEDAdata.options.twinzoom_factor)
            end
            %set(text_numtwin,'String',num2str(num_trials2plot))
        end
        datacursormode on
        datacursormode off
        set(findobj('Type','uicontrol'), 'BusyAction','cancel', 'Interruptible','off','BusyAction','cancel');
        set(findobj('Type','axes'), 'BusyAction','cancel', 'Interruptible','off','BusyAction','cancel');
    end

    function undo_but_Callback(source,eventdata)
        selected_trial = BEEDAdata.TOI.undo_deleted(end);
        if isnan(selected_trial)
            disp(sprintf('No previously deleted SCRs or data segments found in memory'))
        elseif selected_trial == 9999 %it's a respiration segment
            selected_trial4resp = BEEDAdata.TOI.undo_deleted_resp_segments(end);
            scrubmask_points2flipback = BEEDAdata.TOI.deleted_resp_segments{selected_trial4resp}(end);
            scrubmask_points2flipback = scrubmask_points2flipback{:}(2,:);
            BEEDAdata.TOI.resp_segment_scrubmasks{selected_trial4resp}(2,scrubmask_points2flipback) = 0;
            BEEDAdata.TOI.deleted_resp_segments{selected_trial4resp}(end) = [];
            BEEDAdata.TOI.undo_deleted_resp_segments(end) = [];
            BEEDAdata.TOI.undo_deleted(end) = [];
            %replot
            delete(axhandle)
            axhandle = plot_twins();
            disp(sprintf('Undo: Data segment added back to trial #%i/%i',selected_trial4resp,numel(BEEDAdata.TOI.index_start)));
        else
            del_SCRpoint = BEEDAdata.TOI.deleted_SCRs{selected_trial}(2,end);
            del_SCRindex = BEEDAdata.TOI.deleted_SCRs{selected_trial}(3,end);
            %put SCRpoint & SCRindex back in it's right place
            BEEDAdata.TOI.SCRs{selected_trial} = sort(horzcat(BEEDAdata.TOI.SCRs{selected_trial},del_SCRpoint));
            BEEDAdata.TOI.SCRs_index{selected_trial} = sort(horzcat(BEEDAdata.TOI.SCRs_index{selected_trial},del_SCRindex));
            %delete info from undo data & deleted SCRs
            BEEDAdata.TOI.undo_deleted(end) = [];
            BEEDAdata.TOI.deleted_SCRs{selected_trial}(:,end) = [];
            %replot
            delete(axhandle)
            axhandle = plot_twins();
            disp(sprintf('Undo: SCR added back to trial #%i/%i',selected_trial,numel(BEEDAdata.TOI.index_start)));
        end
    end

    function remove_artifacts(source,eventdata)
        
        pause(remove_pause) %
        
        switch allow_delete
            case 'yes'
                if drag2select == 0 %normal behavior, single select
                    curr_SCRdata = findobj(eventdata.Source.CurrentAxes.Children,'Type','Scatter');
                    curr_SCRdata = curr_SCRdata.XData; %find based on X coordinate
                    if isempty(curr_SCRdata)
                        %do nothing
                    else
                        selected_point = eventdata.Source.CurrentAxes.CurrentPoint;
                        check4outside_Y = selected_point(1,2);
                        check4outside_X = selected_point(1,1);
                        check_curr_Ylim = eventdata.Source.CurrentAxes.YLim;
                        check_curr_Xlim = eventdata.Source.CurrentAxes.XLim;
                        if check4outside_Y > max(check_curr_Ylim) | check4outside_Y < min(check_curr_Ylim) |...
                                check4outside_X > max(check_curr_Xlim) | check4outside_X < min(check_curr_Xlim)
                            %donothing
                        else
                            selected_point = selected_point(1); %just take X coord
                            %find the trial you're in
                            selected_trial = max(find(selected_point >= BEEDAdata.sampletimes(BEEDAdata.TOI.index_start)));
                            if selected_point <  BEEDAdata.sampletimes(BEEDAdata.TOI.index_start(selected_trial)) | selected_point >  BEEDAdata.sampletimes(BEEDAdata.TOI.index_end(selected_trial))
                                disp(sprintf('ERROR: only select points within trial range'))
                            else
                                %find actual SCR
                                [~,selected_SCRidx] = min(abs(curr_SCRdata - selected_point));
                                %save it
                                BEEDAdata.TOI.deleted_SCRs{selected_trial} = horzcat(BEEDAdata.TOI.deleted_SCRs{selected_trial},...
                                    [curr_SCRdata(selected_SCRidx);BEEDAdata.TOI.SCRs{selected_trial}(selected_SCRidx);...
                                    BEEDAdata.TOI.SCRs_index{selected_trial}(selected_SCRidx)]); %save time, "point" form, SCRindex
                                BEEDAdata.TOI.undo_deleted = horzcat(BEEDAdata.TOI.undo_deleted,selected_trial); %save last trial for undo
                                %delete it from TOI.SCRs & SCRs_index
                                BEEDAdata.TOI.SCRs{selected_trial}(selected_SCRidx) = [];
                                BEEDAdata.TOI.SCRs_index{selected_trial}(selected_SCRidx) = [];
                                %replot
                                delete(axhandle)
                                axhandle = plot_twins();
                                set(axhandle(selected_trial),'Color','r')
                                pause(.2)
                                set(axhandle(selected_trial),'Color',[1 1 1])
                                disp(sprintf('Delete: SCR deleted from trial #%i/%i',selected_trial,numel(BEEDAdata.TOI.index_start)))
                            end
                        end
                    end
                    
                elseif drag2select == 1 %drag selecting active, drag2select
                    drag_selection = drag_selection + 1;
                    curr_SCRdata = findobj(eventdata.Source.CurrentAxes.Children,'Type','Scatter');
                    curr_SCRdata = curr_SCRdata.XData; %find based on X coordinate
                    % if isempty(curr_SCRdata)
                    %do nothing
                    % else
                    selected_point = eventdata.Source.CurrentAxes.CurrentPoint;
                    check4outside_Y = selected_point(1,2);
                    check4outside_X = selected_point(1,1);
                    check_curr_Ylim = eventdata.Source.CurrentAxes.YLim;
                    check_curr_Xlim = eventdata.Source.CurrentAxes.XLim;
                    if check4outside_Y > max(check_curr_Ylim) | check4outside_Y < min(check_curr_Ylim) |...
                            check4outside_X > max(check_curr_Xlim) | check4outside_X < min(check_curr_Xlim)
                        %donothing
                    else
                        selected_point = selected_point(1); %just take X coord
                        %find the trial you're in
                        selected_trial = max(find(selected_point >= BEEDAdata.sampletimes(BEEDAdata.TOI.index_start)));
                        if selected_point <  BEEDAdata.sampletimes(BEEDAdata.TOI.index_start(selected_trial)) | selected_point >  BEEDAdata.sampletimes(BEEDAdata.TOI.index_end(selected_trial))
                            disp(sprintf('ERROR: only select points within trial range'))
                        else
                            dragdata.Xvals(drag_selection) = selected_point;
                            dragdata.trial(drag_selection) = selected_trial;
                            if drag_selection == 2
                                if dragdata.trial(1) ~= dragdata.trial(2)
                                    disp(sprintf('ERROR: cannot drag select over multiple trials. Turn drag delete on/off to reset'))
                                    %donothing
                                else
                                    if dragdata.Xvals(1) > dragdata.Xvals(2)
                                        dragdata = swapXcoords(dragdata);
                                    end
                                    %find SCRs for deletion
                                    draggedSCRs2delete = find(curr_SCRdata > min(dragdata.Xvals) & curr_SCRdata < max(dragdata.Xvals));
                                    draggedSCRs2delete = curr_SCRdata(draggedSCRs2delete);
                                    for drag_delete_idx = 1:numel(draggedSCRs2delete)
                                        selected_point = draggedSCRs2delete(drag_delete_idx);
                                        
                                        [~,selected_SCRidx] = min(abs(curr_SCRdata - selected_point));
                                        %save it
                                        BEEDAdata.TOI.deleted_SCRs{selected_trial} = horzcat(BEEDAdata.TOI.deleted_SCRs{selected_trial},...
                                            [curr_SCRdata(selected_SCRidx);BEEDAdata.TOI.SCRs{selected_trial}(selected_SCRidx);...
                                            BEEDAdata.TOI.SCRs_index{selected_trial}(selected_SCRidx)]); %save time, "point" form, SCRindex
                                        BEEDAdata.TOI.undo_deleted = horzcat(BEEDAdata.TOI.undo_deleted,selected_trial); %save last trial for undo
                                        %delete it from TOI.SCRs & SCRs_index
                                        BEEDAdata.TOI.SCRs{selected_trial}(selected_SCRidx) = [];
                                        BEEDAdata.TOI.SCRs_index{selected_trial}(selected_SCRidx) = [];
                                        disp(sprintf('Delete: SCR deleted from trial #%i/%i',selected_trial,numel(BEEDAdata.TOI.index_start)));
                                        curr_SCRdata(selected_SCRidx) = [];
                                    end
                                    BEEDAdata.TOI.undo_deleted = horzcat(BEEDAdata.TOI.undo_deleted,9999); %undo marked with respriation edit
                                    BEEDAdata.TOI.undo_deleted_resp_segments =  horzcat(BEEDAdata.TOI.undo_deleted_resp_segments,selected_trial);
                                    badresp_timewindow_idx = find(BEEDAdata.sampletimes > dragdata.Xvals(1) & BEEDAdata.sampletimes < dragdata.Xvals(2));
                                    badresp_timewindow = BEEDAdata.sampletimes(badresp_timewindow_idx);
                                    scrubmask_points2flip = find(ismember(BEEDAdata.TOI.resp_segment_scrubmasks{selected_trial}(1,:),badresp_timewindow_idx));
                                    badresp_timewindow = {[badresp_timewindow;scrubmask_points2flip]};
                                    BEEDAdata.TOI.deleted_resp_segments{selected_trial} = horzcat(BEEDAdata.TOI.deleted_resp_segments{selected_trial},...
                                        badresp_timewindow);
                                    BEEDAdata.TOI.resp_segment_scrubmasks{selected_trial}(2,scrubmask_points2flip) = 1;
                                    %replot
                                    delete(axhandle)
                                    axhandle = plot_twins();
                                    set(axhandle(selected_trial),'Color','r')
                                    pause(.2)
                                    set(axhandle(selected_trial),'Color',[1 1 1])
                                    disp(sprintf('Delete: Data segment deleted from trial #%i/%i',selected_trial,numel(BEEDAdata.TOI.index_start)))
                                    %reset
                                    drag2select = 0;
                                    drag_selection = [];
                                    dragdata = []; %reset
                                    uicontrol(delete_but)
                                    delete_but_Callback(delete_but,[]);
                                    
                                end
                            end
                        end
                    end
                end
            case 'no'
                %do nothing
        end
        
    end
end



