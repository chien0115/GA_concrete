function [E, dispatch_times] = evaluation(P, t, start_time, work_time, travel_time_to, travel_time_back, max_interrupt_time, max_truck_interrupt_time, demand_trips, penalty_site_value, penalty_truck_value)
    [x1, y1] = size(P);  % 獲取染色體數量和每個染色體的位元數
    H = zeros(1, x1);  % 初始化適應度值
    dispatch_times = zeros(x1, y1);
    num_sites = length(start_time);

    %限制條件 工地的中斷時間要小於容許中斷時間
    %決策變數 派送順序
    %目標函式
    % 要先把染色體轉成x,在帶入目標函式

    % 在初始部分生成固定的 dispatch_time
    for i = 1:x1 % 遍歷每個染色體
        % 生成基於染色體P的派遣時間
        dispatch_time = zeros(y1, 1);
        for k = 1:y1
            dispatch_time(k) = k; % 可以根據P(i, k)設置實際的派遣時間
        end
        dispatch_time = sort(dispatch_time + 420); % 調整派遣時間
        
        truck_availability = zeros(1, t); % 追踪每台卡車何時可以再次使用
        site_dispatch_info = cell(num_sites, 1); % 每個工地的派遣信息
        
        % 初始化懲罰值
        penalty_side_count = zeros(1, num_sites); % 每個工地的懲罰值
        penalty_truck_count = 0; % 每個染色體的卡車等待懲罰值
        
        for k = 1:y1
            site_id = P(i, k);

            % 初始化工地派遣信息（如果尚未初始化）
            if isempty(site_dispatch_info{site_id})
                site_dispatch_info{site_id} = struct('arrival_time', [], 'start_time', [], 'finish_time', []);
            end

            if k <= t
                % 對於前 t 台卡車，直接分配
                truck_id = k;
                actual_dispatch_time = dispatch_time(k);
            else
                % 對於第 t 台及之後的卡車，選擇下一個可用的卡車
                [next_available_time, truck_id] = min(truck_availability);
                actual_dispatch_time = max(dispatch_time(k), next_available_time);
            end

            arrival_time = actual_dispatch_time + travel_time_to(site_id);
            if isempty(site_dispatch_info{site_id}.finish_time)
                work_start_time_site = max(arrival_time, start_time(site_id));
            else
                work_start_time_site = max(arrival_time, site_dispatch_info{site_id}.finish_time(end));
            end

            finish_time_site = work_start_time_site + work_time(site_id);
            return_time = finish_time_site + travel_time_back(site_id);

            % 更新卡車的可用時間
            truck_availability(truck_id) = return_time;

            % 記錄工地的派遣信息
            site_dispatch_info{site_id}.arrival_time = [site_dispatch_info{site_id}.arrival_time, arrival_time];
            site_dispatch_info{site_id}.start_time = [site_dispatch_info{site_id}.start_time, work_start_time_site];
            site_dispatch_info{site_id}.finish_time = [site_dispatch_info{site_id}.finish_time, finish_time_site];

            % 計算工地的中斷時間
            if length(site_dispatch_info{site_id}.finish_time) > 1
                previous_finish_time = site_dispatch_info{site_id}.finish_time(end-1);
                interruption_time = arrival_time - previous_finish_time;

                if interruption_time > max_interrupt_time(site_id)
                    penalty_side_count(site_id) = penalty_side_count(site_id) + 1;
                end
            end

            % 計算卡車的等待時間
            truck_waiting_time = work_start_time_site - (actual_dispatch_time + travel_time_to(site_id));
            if truck_waiting_time > 0
                penalty_truck_count = penalty_truck_count + 1;
            end
        end

        % 計算總懲罰值
        total_penalty = sum(penalty_side_count) * penalty_site_value + penalty_truck_count * penalty_truck_value;

        % 計算適應度值（假設目標是最小化總懲罰值）
        H(i) = -total_penalty;
        dispatch_times(i, :) = dispatch_time;
    end

    E = H;
end
