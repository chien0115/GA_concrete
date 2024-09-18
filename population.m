function [Y, dispatch_times] = population(n, demand_trips, num_trucks, time_windows)
    % n: 染色體數量 (族群大小)
    % demand_trips: 各工地需求車次的陣列
    % num_trucks: 車輛數量
    % time_windows: 每個工地的時間窗 [最早派遣時間, 最晚派遣時間]

    num_sites = length(demand_trips); % 工地數量
    total_trips = sum(demand_trips); % 總需求車次

    % 初始化族群矩陣
    % 每個染色體包含去程、回程和每輛車的派遣時間
    Y = zeros(n, total_trips * 2 + num_trucks); % Adjusted size to include dispatch times
    dispatch_times = zeros(n, num_trucks); % 儲存每個染色體的派遣時間

    for i = 1:n
        % 隨機生成每輛車的派遣時間，並確保每輛車的時間在工地的時間窗內
        dispatch_time = zeros(num_trucks, 1); % Initialize dispatch times for trucks
        for j = 1:num_trucks
            % Generate a random dispatch time for each truck within the time window of the site
            site_idx = randi(num_sites); % Randomly select a site for the truck
            dispatch_time(j) = randi([time_windows(site_idx, 1), time_windows(site_idx, 2)]); % Random time within the selected site’s time window
        end
        dispatch_times(i, :) = dispatch_time'; % 儲存派遣時間
        
        % 生成工地的派遣順序和回程
        dispatch_order = [];
        truck_assignment = []; % 初始化車輛分配
        truck_counter = 1; % 車輛計數器

        for j = 1:num_sites
            % 將工地 j 需求的次數添加到派遣順序中
            site_trips = repmat(j, 1, demand_trips(j)); % 工地需求車次
            dispatch_order = [dispatch_order, site_trips];
            
            % 為每個派遣次數分配車輛
            truck_assignment = [truck_assignment, truck_counter * ones(1, demand_trips(j))];
            truck_counter = mod(truck_counter, num_trucks) + 1; % 保證車輛循環使用
        end
        
        % 將派遣順序和車輛分配隨機打亂
        shuffle_idx = randperm(total_trips);
        dispatch_order = dispatch_order(shuffle_idx);
        truck_assignment = truck_assignment(shuffle_idx);

        % 生成每個染色體的完整路徑，包括去程和回程
        full_route = zeros(1, total_trips * 2); % Initialize full_route to the correct size
        for j = 1:total_trips
            site = dispatch_order(j);
            % 每次配送包括去程和回程
            full_route(2*j-1) = site; % 去程
            full_route(2*j) = num_sites + 1; % 回程 (num_sites + 1 表示返回工廠)
        end
        
        % 存儲去程、回程和派遣時間
        Y(i, 1:total_trips * 2) = full_route; % 存儲去程和回程的路徑
        Y(i, total_trips * 2 + 1:end) = dispatch_times(i, :); % 存儲派遣時間 後面三個代表三輛車的隨機派遣時間
    end
end
