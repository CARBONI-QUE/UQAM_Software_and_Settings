function [snowDepth_filtered,pts_removed] = snowDepthFilter(snowDepth, delta, windowSize)
%
% Rosie Howard
% 28 September 2026
%
% Adapted from PhD research, April 2011!
% 
% Filter for snowdepth. Sensor measures incorrect values during heavy/wet
% snowfall and/or dense fog/other path obstructions. 
% Filter out these values using an "X cm sliding window", whereby if the 
% new value is greater than X cm different to the old value, it is thrown 
% out and the previous value is used. If the value is within 5 cm of the 
% previous valid value, keep the new value!

% window_size = 9; % 9 points (4.5 hours) ensures a 3-point spike can't outvote clean data
% tv_dt = datetime(tv,'convertfrom','datenum');   % convert to Matlab's datetime object
deltaSnowAllowed = delta;
half_win = floor(windowSize / 2); 
N = length(snowDepth);

snowDepth_filtered = snowDepth;     % Initialize filtered array 
is_filtered = false(1, N);          % Initialize binary tracking array (0 = unchanged, 1 = edited)

% Loop through every single data point 
for i = 1:N
    % handle tails: dynamic window boundaries shrink at the edges
    start_idx = max(1, i - half_win);
    end_idx = min(N, i + half_win);
    
    % extract current subset
    subset = snowDepth(start_idx:end_idx);
    
    % calculate local median (ignores the 2-3 point spikes/drops)
    local_median = median(subset, 'omitmissing');
    
    % apply physical threshold to the specific current point 'i'
    % using abs() catches both upward spikes and deep downward drops
    if abs(snowDepth(i) - local_median) > deltaSnowAllowed
        snowDepth_filtered(i) = local_median;
        is_filtered(i) = true; 
    end
end

pts_removed = is_filtered;

% num_filtered = sum(is_filtered);
% 
% % plotting test
% figure(100)
% clf
% plot(tv_dt,snowDepth)
% hold on
% grid on
% plot(tv_dt(is_filtered),snowDepth(is_filtered),'ro')
% plot(tv_dt,snowDepth_filtered,'kx')
% legend('original','removed','remaining')
% annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', [num2str(num_filtered) ' points filtered'], 'EdgeColor', 'none')

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Based on snowdepth_filter.m written in April 2011!!
%
% % Filter for snowdepth. Sensor measures incorrect values during heavy/wet
% % snowfall and/or dense fog. Filter out these values using an "X cm sliding
% % window", whereby if the new value is greater than X cm different to the
% % old value, it is thrown out and the previous value is used. If the value
% % is within 5 cm of the previous valid value, keep the new value!
% 
% % load data
% load('snowdepth_measurements.mat');
% 
% SR50_height = 900;          % height above bare ground of snowdepth sensor (SR50) in cm
% %SR50_lastV = D2Gnd_cm(1);   % set 1st valid value (I know this measurement to be valid)
% SR50_new = zeros(length(D2Gnd_cm),1);
% SR50_new(1) = SR50_height - D2Gnd_cm(1);
% delta_snow = [];
% 
% % I know that the first measurement in array is "valid"
% for i = 1:length(D2Gnd_cm)-1
%     delta_snow = D2Gnd_cm(i+1) - (SR50_height - SR50_new(i));
%     if (delta_snow < 5 && delta_snow >= -5)
%         SR50_new(i+1) = SR50_height - D2Gnd_cm(i+1);
%     else
%         SR50_new(i+1) = SR50_new(i);        
%     end  
% end