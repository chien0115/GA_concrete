function [YY1, YY2, best_dispatch_times]=selection(P,F,p, dispatch_times)
%P=Population F=fitness value p=population size

F = abs(F);
[x y]=size(P);
YY1 = zeros(p, y); % Store selected chromosomes
YY2 = zeros(p, 1); % Store fitness values
best_dispatch_times = zeros(p,y); % Store dispatch times for selected chromosomes

e=3;


for i=1:e%开始一个循环，选择前 s 个适应度最高的染色体。
    [r1, c1]=find(F==min(F));%找到适应度最高的染色体(也就是數字最小)的索引 r1：是满足条件 B == max(B) 的元素的行索引。 c1：是满足条件 B == max(B) 的元素的列索引。
    if length(find(F==min(F))) > 1
        % 如果有多个最小值，则选择第一个
        c1 = c1(1);
    end
    %在这个上下文中，B 是一个列向量，因此 find(B == max(B)) 只会返回列索引 c1，而行索引 r1 将始终为 1。不过，为了保持一致性和通用性，代码仍然使用 [r1, c1] 的形式来解包返回的索引值。
    %適應度值B表示為 = [0.1, 0.4, 0.3, 0.2, 0.5];轉換的話代表r1 = 1; c1 = 5
    YY1(i,:)=P(min(c1),:);%使用 max(c1) 确保在有多个最大适应度值的情况下，只选择其中一个。这是为了避免一次选择到两个染色体，并确保代码在处理多个相同适应度值时的稳定性。
    YY2(i)=F(min(c1));
    best_dispatch_times(i, :) = dispatch_times(c1, :); % Store the dispatch time
    P(min(c1),:)=[];%當你從矩陣或向量中刪除元素時，其後的元素會自動向前移動來填補被刪除的位置
    F(min(c1))=[];
    dispatch_times(c1, :) = [];
end

D=F/sum(F);%D=Determine selection probability 適應度值除以總合適應度值
E=cumsum(D);%E=Determine cumulative probability
N=rand(1);%N=generate a vector constaining normalised random numbers

d1=1;
d2=e;%用于标识当前选择的染色体数目，从 e 开始，因为前面已经选了 e 个最好的染色体
while d2<p-e
    if N<E(d1)%E(d1) 是第 d1 个染色体的累积选择概率。如果 N 小于等于 E(d1)，则选择第 d1 个染色体。
        %假设 p = 10，s = 2，这意味着每一代中需要选择 10 个染色体，其中 2 个是最优染色体。
        %因從2開始,所以是到p-1
        YY1(d2+1,:)=P(d1,:);%已經有選最好了 所以後面隨機選嗎?
        YY2(d2+1)=F(d1);
        best_dispatch_times(d2 + 1, :) = dispatch_times(d1, :);
        N=rand(1);
        d2=d2+1;
        d1=1;%因為前面d1已經被[],所以都是d1=1
    else
        d1=d1+1;
    end
end
end