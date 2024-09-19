clear all
close all
clc


% 參數設置
n = 200; % 初始種群大小
c = 10; % 需要進行交叉的染色體對數
m = 5; % 需要進行突變的染色體數
tg = 100; % 總代數
num_sites = 5; % 工地
% num_sites_with_factory = num_sites + 1; % 包括工廠的總工地數
t = 3; % 卡車數
crossoverRate = 0.5; % 定義交配率
mutationRate = 0.1; % 突變率



time_windows = [480, 600; 490, 700; 485, 550; 495, 660; 490, 700;0, 1440]; % 每個工地的時間窗(每個工地每天開始、結束時間),0-1440代表工廠全天開放
% route = [1, 2, 3, 4, 5]; % 染色體示例：工廠到工地的路徑

time = [
    30, 25;  % 去程到工地 1 需要 30 分鐘，回程需要 25 分鐘
    25, 20;  % 去程到工地 2 需要 25 分鐘，回程需要 20 分鐘
    40, 30;  % 去程到工地 3 需要 40 分鐘，回程需要 30 分鐘
    35, 30;  % 去程到工地 4 需要 35 分鐘，回程需要 30 分鐘
    20, 15;  % 去程到工地 5 需要 20 分鐘，回程需要 15 分鐘
    ];

% 定義各工地的參數
max_interrupt_time = [5, 5, 15,15,10]; % 工地最大容許中斷時間 (分鐘)
truck_max_interrupt_time = 25;
work_time = [20, 30, 25,20,15]; % 各工地施工時間 (分鐘)
demand_trips = [2, 2, 1, 3, 2]; % 各工地需求車次
penalty_rate_per_min = 30;% 每分鐘延遲的罰金


% start_time = [8*60, 8*60, 8*60+30]; % 各工地開始施工的時間 (以分鐘計算)
% travel_time_to = [30, 25, 40]; % 去程時間 (分鐘)
% travel_time_back = [25, 20, 30]; % 回程時間 (分鐘)
% penalty_site_value = 5; % 懲罰時間 (分鐘)




figure
title('Blue-Average      Red-Maximum');
xlabel('Generation')
ylabel('Objective Function Value')
hold on



for i = 1:tg
    % 初始化
    [P, dispatch_times] = population(n, demand_trips, t, time_windows); % 初始化種群
    K = zeros(tg, 2); % 儲存適應度的矩陣
    [x1, y1] = size(P);

    % 交配操作
    


    if rand() <= crossoverRate
        % 选择交叉的染色体对
        [C, dispatch_times_new1] = crossover(P, t,dispatch_times, n);
        % 输出交叉操作后的结果
        % disp('Chromosomes after Crossover:');
        % disp(C);
        % disp('Dispatch Times after Crossover:');
        % disp(dispatch_times_new);
        % 更新种群（将新生成的染色体和对应的派遣时间加入原有种群）
        dispatch_times = dispatch_times_new1; % 更新派遣時間
    end

    if rand() <= mutationRate
    % 設定每次要突變的染色體數量
    num_mutation = ceil(mutationRate * size(C, 1)); % 根據突變率計算需要突變的染色體數量
    mutation_indices = randperm(size(C, 1), num_mutation); % 隨機選擇需要突變的染色體索引

    % 初始化存放突變結果的矩陣
    M = C; % 先複製原來的染色體集合
    dispatch_times_new2 = dispatch_times_new1; % 複製派遣時間

    for j = 1:num_mutation
        idx = mutation_indices(j); % 獲取需要突變的染色體索引
        % 進行突變操作，並更新 M 和 dispatch_times_new2 中的值
        [M(idx,:), dispatch_times_new2(idx,:)] = mutation(C(idx,:), t, dispatch_times_new1(idx,:), 1); % 只對選中的染色體進行突變
    end
    end

    % % 输出更新后的种群和派遣时间
    % disp('Updated Population:');
    % disp(P);
    % disp('Updated Dispatch Times:');
    % disp(dispatch_times);


    % 評估操作
    [E, dispatch_times_for_chromosome] = evaluation(P, t, time_windows, num_sites, dispatch_times, work_time, time, max_interrupt_time, truck_max_interrupt_time, demand_trips, penalty_rate_per_min); % 評估族群 P 中每個染色體的適應度

    [P, S, best_dispatch_times] = selection(P, E,t, n,dispatch_times_for_chromosome); % 根據適應度值 E 選擇族群中的染色體


    K(i,1) = sum(S) / n; % 平均適應度
    K(i,2) = min(S); % 最佳適應度

    % 更新圖形
    plot(K(:, 1), 'b.'); drawnow
    hold on
    plot(K(:, 2), 'r.'); drawnow
end

[minValue, index] = min(K(:, 2)); % 提取出最小適應度值
best_chromosome_dispatch_times=best_dispatch_times(index, :);
% 提取最佳適應度值和最優解
% 提取最佳染色體基因和最優解
best_chromosome = P(index, 1:(y1 - t)); % 提取基因部分


% 更新 P2 包含基因和对应的调度时间
P2 = [best_chromosome, best_chromosome_dispatch_times];

disp('Best Chromosome:');
disp(best_chromosome);

disp('Best Dispatch Times in HH:MM format:');
for i = 1:length(best_chromosome_dispatch_times)
    time_str = convert_minutes_to_time(best_chromosome_dispatch_times(i));
    fprintf('Dispatch Time %d: %s\n', i, time_str);
end

function time_str = convert_minutes_to_time(minutes)
    hours = floor(minutes / 60);
    mins = mod(minutes, 60);
    time_str = sprintf('%02d:%02d', hours, mins);
end
