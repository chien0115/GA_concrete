function [Y, dispatch_times_new] = mutation(P, t, dispatch_times, n)
% P = Population
% dispatch_times = Matrix of dispatch times corresponding to the chromosomes
% n = Number of mutations to perform

[x1, y1] = size(P); % Size of the population and chromosomes
Z = zeros(n, y1); % Initialize matrix to store new chromosomes
dispatch_times_new = zeros(n, size(dispatch_times, 2)); % Initialize matrix to store new dispatch times

% Define the range for the positions to be swapped (only in scheduling part)
num_scheduling_positions = y1 - size(dispatch_times, 2); % Number of scheduling positions
odd_positions = 1:2:num_scheduling_positions; % Get all odd positions in the scheduling part

for i = 1:n
    % Randomly select a chromosome 
    r1 = randi(x1); % Randomly select an index within the range of population size
    A1 = P(r1, :);
    dispatch_times1 = dispatch_times(r1, :);

    % Ensure only odd positions are used for swapping
    pos = randperm(length(odd_positions), 2); % Randomly select two different odd positions
    pos = odd_positions(pos); % Get the actual positions

    % Swap the values at the selected positions (dispatch order adjustment)
    A1([pos(1), pos(2)]) = A1([pos(2), pos(1)]);

    % Swap dispatch times at the same positions
    pos_dispatch = randperm(size(dispatch_times1, 2), 2); % Randomly select two different positions within dispatch_times1
    dispatch_times1([pos_dispatch(1), pos_dispatch(2)]) = dispatch_times1([pos_dispatch(2), pos_dispatch(1)]);

    % Store the new chromosome and dispatch times
    Z(i, :) = A1;
    dispatch_times_new(i, :) = dispatch_times1;
end

Y = Z; % Return the new population
end
