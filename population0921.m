function [Y, dispatch_times] = population(n, demand_trips, num_trucks, time_windows)
    % n: 染色體數量 (族群大小)
    % demand_trips: 各工地需求車次的陣列
    % num_trucks: 車輛數量
    % time_windows: 每個工地的時間窗 [最早派遣時間, 最晚派遣時間]

    num_sites = length(demand_trips); % 工地數量
    total_trips = sum(demand_trips); % 總需求車次

    % 初始化族群矩陣
    % 每個染色體包含去程和回程
    Y = zeros(n, total_trips * 2); % Adjusted size to include dispatch and return trips
    dispatch_times = zeros(n, num_trucks); % 儲存每個染色體的派遣時間

    for i = 1:n
        % 隨機生成每輛車的派遣時間，並確保每輛車的時間在工地的時間窗內
        dispatch_time = zeros(num_trucks, 1); % Initialize dispatch times for trucks
        for j = 1:num_trucks
            % 隨機為每輛卡車分配時間，確保在任一工地的時間窗內
            site_idx = randi(num_sites); % 隨機選擇一個工地
            dispatch_time(j) = randi([time_windows(site_idx, 1), time_windows(site_idx, 2)]); % 在選擇工地的時間窗內隨機生成時間
        end
        dispatch_times(i, :) = dispatch_time'; % 儲存派遣時間

        % 初始化工地的派遣順序和回程
        dispatch_order = [];
        truck_assignment = []; % 初始化車輛分配
        truck_id = 1; % 初始化卡車ID

        % 確保每個工地的需求次數都被分配到卡車
        for site_id = 1:num_sites
            % 將工地的需求車次依次添加到派遣順序中
            site_trips = repmat(site_id, 1, demand_trips(site_id)); % 每個工地需求車次
            dispatch_order = [dispatch_order, site_trips]; % 加入工地需求次數

            % 為每次派遣分配卡車
            for trip = 1:demand_trips(site_id)
                truck_assignment = [truck_assignment, truck_id]; % 分配卡車
                truck_id = mod(truck_id, num_trucks) + 1; % 確保卡車循環使用
            end
        end

        % 將派遣順序和卡車分配隨機打亂，模擬隨機派遣
        shuffle_idx = randperm(total_trips);
        dispatch_order = dispatch_order(shuffle_idx);
        truck_assignment = truck_assignment(shuffle_idx);

        % 生成每個染色體的完整路徑，包括去程和回程
        full_route = zeros(1, total_trips * 2); % Initialize full_route with correct size
        for j = 1:total_trips
            site = dispatch_order(j);
            truck = truck_assignment(j);
            % 每次配送包括去程和回程
            full_route(2*j-1) = site; % 去程
            full_route(2*j) = num_sites + 1; % 回程 (num_sites + 1 表示返回工廠)
        end

        % 儲存完整的去程和回程路徑到 Y 矩陣
        Y(i, :) = full_route; % 儲存完整路徑 (去程和回程)
    end
end
