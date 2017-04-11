function downsample_answer = downsample_menu(samplerate_original)

downsample_answer = [];

f = figure('Visible','on','Position',[360,500,450,335],'NumberTitle','off','NumberTitle','off','MenuBar', 'none','ToolBar', 'none');
f.Name = 'BreatheEasyEDA';

htext  = uicontrol('Style','text','String','Do you want to downsample this dataset?',...
    'Units','normalized','Position',[.1,.65,.8,.2],'FontSize',20);
f.Units = 'normalized';

YES = uicontrol('Style','pushbutton','String','Yes','Units','normalized',...
    'Position',[.2,.45,.2,.15],'Callback',@YES_Callback,'FontSize',20,...
    'BackgroundColor','g');
NO = uicontrol('Style','pushbutton','String','No','Units','normalized',...
    'Position',[.65,.45,.2,.15],'Callback',@NO_Callback,'FontSize',20,...
    'BackgroundColor','r');

bottom_message = sprintf('Original sampling rate = %.0fHz',samplerate_original);

bottomtext  = uicontrol('Style','text','String',bottom_message,...
    'Units','normalized','Position',[.1,.15,.8,.2],'FontSize',20);



f.Units = 'normalized';
htext.Units = 'normalized';

uiwait(f)

    function YES_Callback(source,eventdata)
        prompt = {'Enter downsampling factor:'};
        dlg_title = 'Downsample';
        factor = inputdlg(prompt,dlg_title);
        downsample_answer = str2double(factor);
        close(f)
    end


    function NO_Callback(source,eventdata)
        downsample_answer = 0;
        close(f)
    end



end

