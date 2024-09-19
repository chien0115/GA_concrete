function [Y, dispatch_times_new] = crossover(P, t, dispatch_times, c)
    % P = Population
    % dispatch_times = Matrix of dispatch times corresponding to the chromosomes
    % c = Number of chromosome pairs to be crossed

    [x1, y1] = size(P); % Size of the population and chromosomes (with dispatch times)
    Z = zeros(2*c, y1); % Initialize matrix to store new chromosomes
    dispatch_times_new = zeros(2*c, size(dispatch_times, 2)); % Initialize matrix to store new dispatch times

    for i = 1:c
        r1 = randi(x1, 1, 2); % Randomly select two different chromosomes
        while r1(1) == r1(2)
            r1 = randi(x1, 1, 2);
        end
        
        % Select the parent chromosomes and their dispatch times
        A1 = P(r1(1), 1:y1-t); % 只有派遣順序
        A2 = P(r1(2), 1:y1-t);
        dispatch_times1 = dispatch_times(r1(1), :); % 派遣時間部分
        dispatch_times2 = dispatch_times(r1(2), :);


        
        % Randomly select crossover point
        crossover_point = randi([2, y1 - t-1]);%派遣順序交配

        % Perform crossover on chromosomes
        B1 = A1(crossover_point:end);
        A1(crossover_point:end) = A2(crossover_point:end);
        A2(crossover_point:end) = B1;
        
        % Perform crossover on dispatch times 派遣時間交配
        crossover_dispatch = randi([2, t-1]);%派遣順序交配
        B_dispatch_times = dispatch_times1( crossover_dispatch:end);
        dispatch_times1( crossover_dispatch:end) = dispatch_times2( crossover_dispatch:end);
        dispatch_times2( crossover_dispatch:end) = B_dispatch_times;
        
        % Store new chromosomes and dispatch times
        Z(2*i-1, :) = [A1, dispatch_times1];
        Z(2*i, :)   = [A2, dispatch_times2];
        dispatch_times_new(2*i-1, :) = dispatch_times1;
        dispatch_times_new(2*i, :) = dispatch_times2;
    end

    Y = Z; % Return the new population

    % Display the results for debugging
    disp('Chromosomes after Crossover:');
    disp(Y);
    disp('Dispatch Times after Crossover:');
    disp(dispatch_times_new);
end
