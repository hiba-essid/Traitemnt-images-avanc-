function filter_image = Nagao(orig_image)
%-----------------------------------------------------------------------
%   Description: Edge Preserving Smoothing Filter based on Nagao &
%   Matsuyama. 
%-----------------------------------------------------------------------
orig_image   = double(orig_image);
filter_image = orig_image;
[sizex, sizey] = size(orig_image);
m1 = [NaN NaN NaN NaN NaN;NaN 1 1 1 NaN;NaN 1 1 1 NaN;NaN 1 1 1 NaN;NaN NaN NaN NaN NaN];
m2 = [NaN 1 1 1 NaN;NaN 1 1 1 NaN;NaN NaN 1 NaN NaN;NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN];
m3 = [NaN NaN NaN NaN NaN;NaN NaN NaN 1 1;NaN NaN 1 1 1;NaN NaN NaN 1 1;NaN NaN NaN NaN NaN];
m4 = [NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN;NaN NaN 1 NaN NaN;NaN 1 1 1 NaN;NaN 1 1 1 NaN];
m5 = [NaN NaN NaN NaN NaN;1 1 NaN NaN NaN;1 1 1 NaN NaN;1 1 NaN NaN NaN;NaN NaN NaN NaN NaN];
m6 = [1 1 NaN NaN NaN;1 1 1 NaN NaN;NaN 1 1 NaN NaN;NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN];
m7 = [NaN NaN NaN 1 1;NaN NaN 1 1 1;NaN NaN 1 1 NaN;NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN];
m8 = [NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN;NaN NaN 1 1 NaN;NaN NaN 1 1 1;NaN NaN NaN 1 1];
m9 = [NaN NaN NaN NaN NaN;NaN NaN NaN NaN NaN;NaN 1 1 NaN NaN;1 1 1 NaN NaN;1 1 NaN NaN NaN];
for i = 3:sizex - 2
    for j = 3:sizey -2
        subwindow = orig_image(i-2:i+2,j-2:j+2);
        mean_array = zeros([1,9]);
        var_array = zeros([1,9]);
        temp = subwindow.*m1;
        mean_array(1) = mean(temp(~isnan(temp)));
        var_array(1)  = var(temp(~isnan(temp)));
        temp = subwindow.*m2;
        mean_array(2) = mean(temp(~isnan(temp)));
        var_array(2) = var(temp(~isnan(temp)));
        temp = subwindow.*m3;
        mean_array(3) = mean(temp(~isnan(temp)));
        var_array(3) = var(temp(~isnan(temp)));
        temp = subwindow.*m4;
        mean_array(4) = mean(temp(~isnan(temp)));
        var_array(4) = var(temp(~isnan(temp)));
        temp = subwindow.*m5;
        mean_array(5) = mean(temp(~isnan(temp)));
        var_array(5) = var(temp(~isnan(temp)));
        temp = subwindow.*m6;
        mean_array(6) = mean(temp(~isnan(temp)));
        var_array(6) = var(temp(~isnan(temp)));
        temp = subwindow.*m7;
        mean_array(7) = mean(temp(~isnan(temp)));
        var_array(7) = var(temp(~isnan(temp)));
        temp = subwindow.*m8;
        mean_array(8) = mean(temp(~isnan(temp)));
        var_array(8) = var(temp(~isnan(temp)));
        temp = subwindow.*m9;
        mean_array(9) = mean(temp(~isnan(temp)));
        var_array(9) = var(temp(~isnan(temp)));
        MIN_VARIANCE = min(var_array);
        for k = 1:9
            if MIN_VARIANCE == var_array(k)
                filter_image(i,j) = mean_array(k);
                break
            end
        end
    end
end
