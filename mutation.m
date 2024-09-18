function Y = mutation(P, n)
[x1, y1] = size(P); % 獲取 P 的尺寸 (染色體數量和基因數量)
Z = zeros(n, y1); % 初始化一個 n 行 y1 列的矩陣 Z，用來存儲變異後的新染色體

for i = 1:n
    % 隨機選擇一條染色體
    r1 = randi(x1);
    A1 = P(r1, :);

    % 隨機選擇兩個不同的位置進行交換
    pos = randperm(y1, 2);
    % 交換兩個位置的值
    A1([pos(1), pos(2)]) = A1([pos(2), pos(1)]);

    % 確保變異後的染色體中不包含0
    % while any(A1 == 0)
    %     % 如果染色體中包含0，重新選擇一條染色體進行變異
    %     r1 = randi(x1);
    %     A1 = P(r1, :);
    % 
    %     % 隨機選擇兩個不同的位置進行交換
    %     pos = randperm(y1, 2);
    %     % 交換兩個位置的值
    %     A1([pos(1), pos(2)]) = A1([pos(2), pos(1)]);
    % end

    % 將變異後的染色體存儲到 Z 中
    Z(i, :) = A1;
end
Y = Z; % 返回變異後的族群
end
