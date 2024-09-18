function Y = population(n, demand_trips)
    % n: 染色體數量 (族群大小)
    % demand_trips: 各工地需求車次的陣列
    num_sites = length(demand_trips); % 工地數量 決策變量
    total_trips = sum(demand_trips); % 總需求車次

    % 初始化族群矩陣
    Y = zeros(n, total_trips);

    % 為每個染色體生成隨機排列的派遣順序
    for i = 1:n
        % 生成工地的派遣順序
        dispatch_order = [];
        for j = 1:num_sites
            % 將工地 j 需求的次數添加到派遣順序中
            dispatch_order = [dispatch_order, repmat(j, 1, demand_trips(j))]; %dispatch_order = [1, 1, 2, 2, 2, 3]
        end

        % 將派遣順序隨機打亂
        chromosome = dispatch_order(randperm(total_trips));

        % 保存到族群矩陣
        Y(i, :) = chromosome;
    end
end
