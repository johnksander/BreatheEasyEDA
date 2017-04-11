function check_answer = checkUser4save()

check_answer = [];

f = figure('Visible','on','Position',[360,500,450,335],'NumberTitle','off','NumberTitle','off','MenuBar', 'none','ToolBar', 'none');
f.Name = 'BreatheEasyEDA';

htext  = uicontrol('Style','text','String','Exporting results will clear all unsaved changes, do you wish to continue?',...
    'Units','normalized','Position',[.1,.45,.8,.4],'FontSize',30,'HorizontalAlignment','center');
f.Units = 'normalized';

YES = uicontrol('Style','pushbutton','String','Yes','Units','normalized',...
    'Position',[.2,.25,.2,.15],'Callback',@YES_Callback,'FontSize',20,...
    'BackgroundColor','g');
NO = uicontrol('Style','pushbutton','String','No','Units','normalized',...
    'Position',[.65,.25,.2,.15],'Callback',@NO_Callback,'FontSize',20,...
    'BackgroundColor','r');


uiwait(f)

    function YES_Callback(source,eventdata)
        check_answer = 'go';
        close(f)
    end


    function NO_Callback(source,eventdata)
        check_answer = 'stop';
        close(f)
    end



end

