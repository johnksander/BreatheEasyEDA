function smooth_data = smooth_util(data, kernel_sz)

if kernel_sz < 1
    smooth_data = data;
else
    data = data(:)'; %make row data
    data = [data(1) data data(end)]; %pad for border issues w/ conv()
    kernel_sz = floor(kernel_sz/2)*2;   %even kernel width
    kernel = normpdf(1:(kernel_sz+1), kernel_sz/2+1, kernel_sz/8); %gaussian smoothing kernel, can use alternate implementation here
    kernel = kernel / sum(kernel);  % normalize 
    data_ext = [ones(1,kernel_sz/2)*data(1), data, ones(1,kernel_sz/2)*data(end)]; %extend data for conv()
    sdata_ext = conv(data_ext, kernel); % convolve with smoothing window
    smooth_data = sdata_ext(2+kernel_sz : end-kernel_sz-1); %cut extra
end
