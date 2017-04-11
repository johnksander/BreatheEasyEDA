function [scs, kernel_sz] = smooth_mainfunc(data, max_kernel_sz, err_crit)

success = 0;
ce(1) = sqrt(mean(diff(data).^2)/2);
tvec = 0:4:max_kernel_sz;
if length(tvec) < 2
    tvec = [0, 2];
end

for idx = 2:numel(tvec)
    kernel_sz = tvec(idx);
    scs = smooth_util(data, kernel_sz);
    scd = diff(scs);
    ce(idx) = sqrt(mean(scd.^2)/2);  %conductance error
        if abs(ce(idx) - ce(idx-1)) < err_crit
            success = 1;
            break;
        end
end

if success  %take before-last result
    if idx > 2
        scs = smooth_util(data, tvec(idx-1));
        kernel_sz = tvec(idx-1);
    else %data already satisfy smoothness criteria
        scs = data;
        kernel_sz = 0;
    end 
end
