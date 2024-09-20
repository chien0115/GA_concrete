clear all
close all
clc


% 參數設置
n = 200; % 初始種群大小
c = 10; % 需要進行交叉的染色體對數
m = 5; % 需要進行突變的染色體數
tg = 500; % 總代數
num_sites = 5; % 工地
% num_sites_with_factory = num_sites + 1; % 包括工廠的總工地數
t = 3; % 卡車數
s=1000;%adaptive stopping=no. of generations not improve quality自適應停止條件,即在這麼多沒有改善的情況下停止
r=10;%number of chromosomes passing between runs每次運行之間傳遞的染色體數 比較佳的染色體
crossoverRate = 0.5; % 定義交配率
mutationRate = 0.1; % 突變率



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


[P,dispatch_times] = population(n, demand_trips, t, time_windows); % 初始化種群 P只包含派出順序 OK
w=1;%用來追蹤和紀錄適應度值
ww=1;%用來追蹤和紀錄適應度值
KK=0;%是一個矩陣，用來存儲每一代的平均適應度和最大適應度，以便進行自適應停止檢查
for i = 1:tg
    % 初始化
    K = zeros(tg, 2); % 儲存適應度的矩陣
    [x1, y1] = size(P);

    % 初始化
    C = []; % 初始化 C 為空矩陣
    M = []; % 初始化 M 為空矩陣
    dispatch_times_cross=[];
    dispatch_times_mutation=[];
    % 交配操作
    for j = 1:c
        if rand() <= crossoverRate
            [C_temp,dispatch_times_cross_temp] = crossover(P, t,dispatch_times, c);
            C = [C; C_temp];
            dispatch_times_cross=[dispatch_times_cross;dispatch_times_cross_temp];
        else
            % 保留原染色體
            C=P;
            dispatch_times_cross=dispatch_times;
        end
    end

    % 突變操作
    for j = 1:m
        if rand() <= mutationRate
            [M_temp,dispatch_times_mutation_temp] = mutation(C, t, dispatch_times_cross, m);
            M = [M; M_temp];
            dispatch_times_mutation=[dispatch_times_mutation;dispatch_times_mutation_temp];

        else
            M=C;
            dispatch_times_mutation=dispatch_times_cross;
        end
    end

    %合併crossover、mutation
    P=[C;M];%無dispatch time

    dispatch_times = [dispatch_times_cross;dispatch_times_mutation];


    % 評估操作
    E = evaluation(P, t, time_windows, num_sites, dispatch_times, work_time, time, max_interrupt_time, truck_max_interrupt_time, demand_trips, penalty_rate_per_min); % 評估族群 P 中每個染色體的適應度

    [P, S, best_dispatch_times] = selection(P, E,t, n,dispatch_times); % 根據適應度值 E 選擇族群中的染色體


    K(w,1)=sum(S)/n;%K(w, 1) 和 KK(ww, 1) 分別記錄當前代的平均適應度值（sum(S2) / p）。 K 是用来记录每代的适应度信息的矩阵
    K(w,2)=S(1,1);%K(w, 2) 和 KK(ww, 2) 分別記錄當前代的最大適應度值（S2(1, 1)，即最優染色體的適應度值）。
    KK(ww,1)=sum(S)/n;%記錄每一代的平均適應度值。
    KK(ww,2)=S(1,1);%記錄每一代的最佳適應度值（即該代中的最大適應度值）。
    w=w+1;
    ww=ww+1;
    %自適應停止機制 s 是設定的停止容忍代數，即若在 s 代中適應度值變化小於等於某個閾值，則認為演算法收斂。
    %K 的作用：K 用于记录当前代的适应度信息，并且在每一代的计算中都在更新。K 在每一代的循环中被更新，存储了每代的平均适应度和最大适应度，用于后续的绘图和分析。
    %KK 的作用：KK 用于记录所有代的适应度信息，并用于自适应停止机制的判断。KK 在整个算法运行过程中积累每一代的适应度信息，用于判断算法是否收敛。
    if ww-1>s%这个条件检查是否已经运行了至少 s 代 可以修改条件为 ww > s?
        A=KK(ww-s:ww-1,2);%記錄每代最高適應度
        B=abs(diff(A));%計算 A 中相鄰元素之間的差值。
        if sum(B)<=0.0001 %檢查變化量是否足夠小
            KK=0;
            ww=1;
            break
        end
    end
    if toc>t
        break
    end

    % 更新圖形
    plot(K(:,1),'b.'); drawnow
    hold on
    plot(K(:,2),'r.'); drawnow

    %select top chromosomes

    for k=1:r
        [x y]=find(S==min(S));%find(S2 == max(S2)) 找到 S2 中最大適應度值的位置。
        P1(k,:)=P(max(y),:);
        P(max(y),:)=[];%P(max(y), :) = [] 刪除族群 P 中的最優染色體，以防重複使用。
        S(:,max(y))=[];%S2(:, max(y)) = [] 刪除適應度矩陣 S2 中對應的適應度值
        clear x y
    end
    %Note:P1=top chromosomes
    if toc>t
        break
    end
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

