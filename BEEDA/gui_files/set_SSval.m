function single_selection = set_SSval(single_selection)
switch single_selection
    case 'off'
        setSS = 1;
    case 'on'
        setSS = 2;
end

if setSS == 1
    single_selection = 'on';
elseif setSS == 2
    single_selection = 'off';
end


end

