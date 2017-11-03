function IRRinfo = IRR_intro()


IRRinfo.FN = [];
IRRinfo.Fdir = [];
IRRinfo.Tmode = [];


f = figure('Visible','on','Position',[360,500,450,335],'NumberTitle','off','MenuBar', 'none','ToolBar', 'none');
f.Name = 'Inter-rater reliability';


SCRonly = uicontrol('Style','pushbutton',...
    'String','Only trials with SCRs','Units','normalized',...
    'Position',[.15,.65,.7,.25],'Callback',@SCRonly_Callback,'FontSize',20);


alltrials = uicontrol('Style','pushbutton',...
    'String','All trials','Units','normalized',...
    'Position',[.15,.2,.7,.25],'Callback',@alltrials_Callback,'FontSize',20);

uiwait(f)

    function SCRonly_Callback(source,eventdata)
        IRRinfo.Tmode = 'SCRonly';
        [IRRinfo.FN,IRRinfo.Fdir] = get_my_file();
        close(f)
    end

    function alltrials_Callback(source,eventdata)
        IRRinfo.Tmode = 'allTOI';
        [IRRinfo.FN,IRRinfo.Fdir] = get_my_file();
        close(f)
    end


    function [FN,Fdir] = get_my_file()
        [GMFname,Fdir] = uigetfile('*.csv','Select rater info .csv file');
        FN = fullfile(Fdir,GMFname);
    end
end
