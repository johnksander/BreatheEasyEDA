function [FileName,PathName] = select_intro()

FileName = [];
PathName = [];

f = figure('Visible','on','Position',[360,500,450,550],'NumberTitle','off','MenuBar', 'none','ToolBar', 'none');
f.Name = 'BreatheEasyEDA';


winH = .25;
winW = .7;
winbuff = .075;
Load_MWdata = uicontrol('Style','pushbutton',...
    'String','Load BioPac .txt files','Units','normalized',...
    'Position',[.15,1-winH-winbuff,winW,winH],'Callback',@Load_MWdata_Callback,'FontSize',25);

Load_CSVdata = uicontrol('Style','pushbutton',...
    'String','Load generic .csv files','Units','normalized',...
    'Position',[.15,1-winH*2-winbuff*2,winW,winH],'Callback',@Load_CSVdata_Callback,'FontSize',25);

Load_BEEDAmat = uicontrol('Style','pushbutton',...
    'String','Load BEEDA .mat file','Units','normalized',...
    'Position',[.15,1-winH*3-winbuff*3,winW,winH],'Callback',@Load_BEEDAmat_Callback,'FontSize',25);



uiwait(f)

    function Load_MWdata_Callback(source,eventdata)
        t = 'Select data .txt file';fprintf(['\n', t,' ... \n'])
        [MWdata_fname,MWdata_path] = uigetfile('*.txt',t);
        t = 'Select event .txt file';fprintf(['\n', t,' ... \n\n'])
        [eventfile_fname,eventfile_path] = uigetfile('*.txt',t);
        MWdata = fullfile(MWdata_path,MWdata_fname);
        eventfile = fullfile(eventfile_path,eventfile_fname);
        set(Load_MWdata,'String','Loading... Please wait')
        drawnow
        BEEDAdata = makeBEEDAmatfile(MWdata,eventfile,'biolab');
        [sv_FileName,sv_PathName] = uiputfile('*','Save BEEDA .mat file');
        save(fullfile(sv_PathName,sv_FileName),'BEEDAdata')
        FileName = sv_FileName;
        PathName = sv_PathName;
        close(f)
    end


    function Load_CSVdata_Callback(source,eventdata)
        t = 'Select data .csv file';fprintf(['\n', t,' ... \n'])
        [CSVdata_fname,CSVdata_path] = uigetfile('*.csv',t);
        t = 'Select event .csv file';fprintf(['\n', t,' ... \n\n'])
        [eventfile_fname,eventfile_path] = uigetfile('*.csv',t);
        CSVdata = fullfile(CSVdata_path,CSVdata_fname);
        eventfile = fullfile(eventfile_path,eventfile_fname);
        set(Load_CSVdata,'String','Loading... Please wait')
        drawnow
        BEEDAdata = makeBEEDAmatfile(CSVdata,eventfile,'generic');
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
