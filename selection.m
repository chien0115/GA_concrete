function [YY1, YY2, best_dispatch_times] = selection(P, F,t, p, dispatch_times)
% P = Population, F = fitness value, p = population size

F = abs(F);
[x, y] = size(P);%有包含mutation、crossover的P 尺寸260*23



YY1 = zeros(p, y); % Store selected chromosomes
YY2 = zeros(p, 1); % Store fitness values
best_dispatch_times = zeros(p, t); % Store dispatch times for selected chromosomes 200*3

e = 3; % Number of elite chromosomes to select

for i = 1:e % Select the top e chromosomes with the highest fitness values
    [r1, c1]=find(F==min(F)); % Find index of the best fitness value
    if length(find(F==min(F))) > 1
        % 如果有多个最小值，则选择第一个
        c1 = c1(1);
    end

    % Store selected chromosome, fitness value, and dispatch times
    YY1(i, :) = P(c1, :);
    YY2(i) = F(c1);
    disp('Size of best_dispatch_times:');
    disp(size(best_dispatch_times));

    disp('Size of dispatch_times:');
    disp(size(dispatch_times));
    best_dispatch_times(i, :) = dispatch_times(c1, :);

    % Remove selected chromosome from population
    P(c1, :) = [];
    F(c1) = [];
    dispatch_times(c1, :) = [];

    % Update dimensions
    [x, y] = size(P);
end

% Selection based on fitness probabilities
D = F / sum(F); % Fitness proportionate selection
E = cumsum(D); % Cumulative probabilities
N = rand(1); % Random number for selection

d1 = 1;
d2 = e; % Start from where we left off

while d2 < p
    if N < E(d1)
        % Select chromosome based on cumulative probability
        YY1(d2 + 1, :) = P(d1, :);
        YY2(d2 + 1) = F(d1);
        best_dispatch_times(d2 + 1, :) = dispatch_times(d1, :);

        % Generate a new random number and update counters
        N = rand(1);
        d2 = d2 + 1;
        d1 = 1;
    else
        d1 = d1 + 1;
    end
end
end
