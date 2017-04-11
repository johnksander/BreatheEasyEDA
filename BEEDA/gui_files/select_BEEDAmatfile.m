function [FileName,PathName] = select_BEEDAmatfile()

FileName = [];
PathName = [];
f = figure('Visible','on','Position',[360,500,450,335],'NumberTitle','off','MenuBar', 'none','ToolBar', 'none');
f.Name = 'BreatheEasyEDA';

htext  = uicontrol('Style','text','String','Select BreatheEasyEDA .mat file',...
    'Position',[70,220,300,50],'FontSize',20);

filebrowser = uicontrol('Style','pushbutton',...
    'String','Browse Files','Position',[200,200,150,30],...
    'Callback',@filebrowser_Callback,'FontSize',12);

align([filebrowser,htext],'Center','None');


f.Units = 'normalized';
htext.Units = 'normalized';
filebrowser.Units = 'normalized';

uiwait(f)

  function filebrowser_Callback(source,eventdata) 
      [FileName,PathName] = uigetfile('*.mat','Select .mat file');
       close(f)
  end



end

