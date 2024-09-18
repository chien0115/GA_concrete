function [E, dispatch_times] = evaluation(P, t, time_windows,num_sites, dispatch_times, work_time, time, max_interrupt_time, truck_max_interrupt_time, demand_trips, penalty_rate_per_min)
    [x1, y1] = size(P);  % 獲取染色體數量和每個染色體的位元數
    H = zeros(1, x1);  % 初始化適應度值
    num_sites_with_factory = num_sites + 1; % 包括工廠的總工地數

    for i = 1:x1 % 遍歷每個染色體
        truck_availability = zeros(1, t); % 追踪每台卡車何時可以再次使用
        disp(size(num_sites));
        site_dispatch_info = cell(num_sites, 1); % 每個工地的派遣信息  工廠應該是只有到工廠時間
        
        % 初始化懲罰值
        penalty_side_time = zeros(1, num_sites); % 每個工地和工廠的懲罰時間
        penalty_truck_time = 0; % 每個染色體的卡車等待懲罰時間
        
        for k = 1:y1
            site_id = P(i, k);

            % 檢查 site_id 是否是有效的工地或工廠
            if site_id < 1 || site_id > num_sites_with_factory % 如果超出範圍
                error('site_id 超出有效範圍: %d', site_id);
            end

            % 初始化工地和工廠的派遣信息（如果尚未初始化）
            if isempty(site_dispatch_info{site_id})
                site_dispatch_info{site_id} = struct('arrival_time', [], 'start_time', [], 'finish_time', []);
            end

            % 確保 k 不超出 dispatch_times 的範圍
            if k <= t
                % 前 t 台卡車使用固定的派遣時間
                truck_id = k;
                if k > size(dispatch_times, 2)
                    error('k 值超出了 dispatch_times 的列數: %d', k);
                end
                actual_dispatch_time = dispatch_times(i, k);
            else
                % 後續卡車使用回程時間作為派遣時間
                [next_available_time, truck_id] = min(truck_availability);
                % 從之前的回程時間中確定派遣時間
                if truck_id <= t
                    actual_dispatch_time = max(next_available_time, dispatch_times(i, mod(k-1, t) + 1));
                else
                    actual_dispatch_time = next_available_time;
                end
            end

            % 取得去程和回程時間
            if site_id < num_sites_with_factory
                %則表示當前要前往的點是工地
                travel_to_site = time(site_id, 1);
                work_start_time_site = max(actual_dispatch_time + travel_to_site, time_windows(site_id, 1));
                finish_time_site = work_start_time_site + work_time(site_id);
            else%則表示當前要前往的點是工廠
                % 工廠 (site_id == num_sites_with_factory)
                travel_to_site = time(site_id, 1);
                work_start_time_site = max(actual_dispatch_time + travel_to_site, time_windows(site_id, 1));
                finish_time_site = work_start_time_site + work_time(site_id);
                travel_back = time(site_id, 2);
                return_time = finish_time_site + travel_back;
            end

            % 更新卡車的可用時間
            truck_availability(truck_id) = return_time;

            % 記錄工地和工廠的派遣信息
            site_dispatch_info{site_id}.arrival_time = [site_dispatch_info{site_id}.arrival_time, actual_dispatch_time + travel_to_site];
            site_dispatch_info{site_id}.start_time = [site_dispatch_info{site_id}.start_time, work_start_time_site];
            site_dispatch_info{site_id}.finish_time = [site_dispatch_info{site_id}.finish_time, finish_time_site];

            % 計算工地的中斷時間(卡車慢到)
            if site_id < num_sites_with_factory && length(site_dispatch_info{site_id}.finish_time) > 1
                previous_finish_time = site_dispatch_info{site_id}.finish_time(end-1);
                interruption_time = actual_dispatch_time + travel_to_site - previous_finish_time;

                if interruption_time > max_interrupt_time(site_id)
                    penalty_side_time(site_id) = penalty_side_time(site_id) + (interruption_time - max_interrupt_time(site_id));
                end
            end

            % 計算卡車的等待時間(卡車快到)
            truck_waiting_time = work_start_time_site - (actual_dispatch_time + travel_to_site);
            if truck_waiting_time > 0
                if truck_waiting_time > truck_max_interrupt_time
                    penalty_truck_time = penalty_truck_time + truck_waiting_time;
                end

            end
        end

        % 計算總懲罰時間
        total_penalty_time = sum(penalty_side_time) + penalty_truck_time;

        % 計算總懲罰值（基於每小時的懲罰率）
        total_penalty = total_penalty_time * penalty_rate_per_min;

        % 計算適應度值（假設目標是最小化總懲罰值）
        H(i) = -total_penalty;
    end

    E = H;
end
