function [minL, maxL] = findSCRpeaks(data, ndiff)

minL = [];
maxL = [];
diff_data = diff(data); 
responses = [];
start_idx = find(diff_data);
if isempty(start_idx) %kick it back out
    return;
end

start_idx = start_idx(1);
wavedir = sign(diff_data(start_idx)); 
for idx = start_idx+1:numel(diff_data)
    if sign(diff_data(idx)) ~= wavedir
        if (isempty(responses) && wavedir == 1)   %make sure everything has trough-peak pair
            predataidx = start_idx:idx-1;
            [~, idx] = min(data(predataidx));
            responses =  predataidx(idx);
        end
        responses = [responses, idx];
        wavedir = -wavedir;
    end
end

if ~mod(size(responses,2),2);  %make sure everything has trough-peak pair
    responses = [responses, length(data)];
end

if ndiff >= 2
    dd2 = diff(diff_data);
    f20 = [];
    wavedir = sign(dd2(1)); 
    for idx = 1:numel(dd2)
        if sign(dd2(idx)) ~= wavedir 
            if diff_data(idx) > 0 && wavedir < 0 
                if ndiff > 1
                    responses = [responses, idx, idx]; 
                end
            elseif diff_data(idx) > 0 && wavedir > 0
                f20 = [f20, idx];
            end
            wavedir = -wavedir;
        end
    end
    responses = [responses, f20];
end
responses = sort(responses);
minL = responses(1:2:end);      % troughs 
maxL = responses(2:2:end);      % peaks


