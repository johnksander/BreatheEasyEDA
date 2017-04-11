function [FileName,PathName] = select_intro()

FileName = [];
PathName = [];

f = figure('Visible','on','Position',[360,500,450,335],'NumberTitle','off','MenuBar', 'none','ToolBar', 'none');
f.Name = 'BreatheEasyEDA';



Load_MWdata = uicontrol('Style','pushbutton',...
    'String','Load BioPac .txt files','Units','normalized',...
    'Position',[.15,.65,.7,.25],'Callback',@Load_MWdata_Callback,'FontSize',25);


Load_BEEDAmat = uicontrol('Style','pushbutton',...
    'String','Load BEEDA .mat file','Units','normalized',...
    'Position',[.15,.2,.7,.25],'Callback',@Load_BEEDAmat_Callback,'FontSize',25);



uiwait(f)

    function Load_MWdata_Callback(source,eventdata)
        [MWdata_fname,MWdata_path] = uigetfile('*.txt','Select .txt data file');
        [eventfile_fname,eventfile_path] = uigetfile('*.txt','Select event .txt file');
        MWdata = fullfile(MWdata_path,MWdata_fname);
        eventfile = fullfile(eventfile_path,eventfile_fname);
        set(Load_MWdata,'String','Loading... Please wait')
        drawnow
        BEEDAdata = makeBEEDAmatfile(MWdata,eventfile);
        [sv_FileName,sv_PathName] = uiputfile('*','Save BEEDA .mat file');
        save(fullfile(sv_PathName,sv_FileName),'BEEDAdata')
        FileName = sv_FileName;
        PathName = sv_PathName;
        close(f)
    end

    function Load_BEEDAmat_Callback(source,eventdata)
        [FileName,PathName] = uigetfile('*.mat','Select .mat file');
        close(f)
    end



end
