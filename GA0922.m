clear all
close all
clc


% 參數設置
n = 200; % 初始種群大小
c = 50; % 需要進行交叉的染色體對數
m = 20; % 需要進行突變的染色體數
tg = 500; % 總代數
num_sites = 5; % 工地
% num_sites_with_factory = num_sites + 1; % 包括工廠的總工地數
t = 1; % 卡車數
s=10;%adaptive stopping=no. of generations not improve quality自適應停止條件,即在這麼多沒有改善的情況下停止
r=10;%number of chromosomes passing between runs每次運行之間傳遞的染色體數 比較佳的染色體
crossoverRate = 0.8; % 定義交配率
mutationRate = 0.8; % 突變率



time_windows = [480, 1020; 490, 1020; 485, 1020; 495, 1020; 490, 1020;0, 1440]; % 每個工地的時間窗(每個工地每天開始、結束時間),0-1440代表工廠全天開放
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
demand_trips = [2, 1, 1, 1, 2]; % 各工地需求車次
penalty_rate_per_min = 30;% 每分鐘延遲的罰金


% start_time = [8*60, 8*60, 8*60+30]; % 各工地開始施工的時間 (以分鐘計算)
% travel_time_to = [30, 25, 40]; % 去程時間 (分鐘)
% travel_time_back = [25, 20, 30]; % 回程時間 (分鐘)
% penalty_site_value = 5; % 懲罰時間 (分鐘)




figure
title('Blue-Average      Red-Minimum');
xlabel('Generation')
ylabel('Objective Function Value')
hold on


[P,dispatch_times] = population(n, demand_trips, t, time_windows); % 初始化種群 P只包含派出順序 OK
for i = 1:tg
    % 初始化
    K = zeros(tg, 2); % 儲存適應度的矩陣
    [x1, y1] = size(P);

    % 初始化
    C = []; % 初始化 C 為空矩陣
    M = []; % 初始化 M 為空矩陣
    dispatch_times_cross = [];
    dispatch_times_mutation = [];
    rand_crossover = rand();
    rand_mutation = rand();

    % 交配操作
    if rand_crossover <= crossoverRate
        [C_temp, dispatch_times_cross_temp] = crossover(P, t, dispatch_times, c);
        C = [C; C_temp];
        dispatch_times_cross = [dispatch_times_cross; dispatch_times_cross_temp]; % 交配後的
    else
        % 保留原染色體
        C = P;
        dispatch_times_cross = [dispatch_times_cross; dispatch_times];
    end

    % 突變操作
    if rand_mutation <= mutationRate
        [M_temp, dispatch_times_mutation_temp] = mutation(C, t, dispatch_times_cross, m);
        M = [M; M_temp];
        dispatch_times_mutation = [dispatch_times_mutation; dispatch_times_mutation_temp];
    else
        % 如果不進行突變，保留交配後的結果
        M = C;
        dispatch_times_mutation = [dispatch_times_mutation; dispatch_times_cross];
    end

    % 統整
    if rand_crossover <= crossoverRate && rand_mutation <= mutationRate % 皆交配與變異
        P = [C; M];
        dispatch_times = [dispatch_times_cross; dispatch_times_mutation];
    elseif rand_crossover <= crossoverRate && rand_mutation > mutationRate % 交配進行，突變無進行
        P = M;
        dispatch_times = dispatch_times_cross;
    elseif rand_crossover > crossoverRate && rand_mutation <= mutationRate % 交配無進行，突變進行
        P = [C; M];
        dispatch_times = [dispatch_times; dispatch_times_mutation];
    else % 交配與突變皆無進行
        P = M;
        dispatch_times = dispatch_times_mutation;
    end

    % 評估操作
    E = evaluation(P, t, time_windows, num_sites, dispatch_times, work_time, time, max_interrupt_time, truck_max_interrupt_time, demand_trips, penalty_rate_per_min); % 評估族群 P 中每個染色體的適應度

    % 選擇最好的染色體
    [P, S, best_dispatch_times] = selection(P, E, t, n, dispatch_times);

    % 記錄適應度
    K(i, 1) = sum(S) / n; % 平均適應度
    K(i, 2) = min(S); % 最佳適應度

    % 更新圖形
    plot(K(:,1), 'b.'); drawnow
    hold on
    plot(K(:,2), 'r.'); drawnow

    % 在每次迭代後，將選擇出的 P 和 dispatch_times 更新為下一次迭代的初始值
    dispatch_times = best_dispatch_times; % 使用最佳調度時間更新
end


[minValue, index] = min(K(:, 2)); % 提取出最小適應度值
best_chromosome_dispatch_times=best_dispatch_times(index, :);
% 提取最佳適應度值和最優解
% 提取最佳染色體基因和最優解
best_chromosome = P(index, :); % 提取基因部分


% 更新 P2 包含基因和对应的调度时间
P2 = [best_chromosome, best_chromosome_dispatch_times];

disp('Best Chromosome:');
disp(best_chromosome);

disp('Best Dispatch Times:');
disp(best_chromosome_dispatch_times);

