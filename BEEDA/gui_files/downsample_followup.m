function BEEDAdata = downsample_followup(downsample_answer,BEEDAdata)
if downsample_answer ~= 0
    factor = downsample_answer;
    BEEDAdata = downsample_BEEDAdata(BEEDAdata,factor);
    disp_downsamp = figure('Visible','on','Position',[360,500,400,200],'NumberTitle','off','MenuBar', 'none','ToolBar', 'none');
    disp_downsamp.Name = 'Downsampling';
    downsamp_numdisp = sprintf('Dataset downsampled to %.0fHz',(BEEDAdata.Hz_original/BEEDAdata.downsample_factor));
    disp_downsamptext  = uicontrol('Style','text','String',downsamp_numdisp,...
        'Units','normalized','Position',[.1,.40,.8,.2],'FontSize',20);
    disp(sprintf(downsamp_numdisp))
    pause(1.5)
    close(disp_downsamp)
elseif downsample_answer == 0
    %don't downsample
end


end
