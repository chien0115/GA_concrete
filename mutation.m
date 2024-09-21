function [Y, dispatch_times_new2] = mutation(P, t, dispatch_times, m)
% P = Population
% dispatch_times = Matrix of dispatch times corresponding to the chromosomes
% n = Number of mutations to perform

[x1, y1] = size(P); % Size of the population and chromosomes 400,20
Z = zeros(m, y1); % Initialize matrix to store new chromosomes m,20
dispatch_times_new2 = zeros(m, size(dispatch_times, 2)); % Initialize matrix to store new dispatch times
% Define the range for the positions to be swapped (only in scheduling part)
num_scheduling_positions = y1; % Number of scheduling positions
odd_positions = 1:2:num_scheduling_positions; % Get all odd positions in the scheduling part
disp(['Size of dispatch_times: ', num2str(size(dispatch_times, 1)), ' x ', num2str(size(dispatch_times, 2))]);

for i = 1:m %目前x1=400 y1=20 n=5
    % Randomly select a chromosome
    disp(['x1: ', num2str(x1)]);
    r1 = randi(x1); % Randomly select an index within the range of population size
    disp(['Selected r1: ', num2str(r1)]);
    A1 = P(r1, 1:y1);%只有派遣順序
    dispatch_times1 = dispatch_times(r1, :);

    % Ensure only odd positions are used for swapping
    pos = randperm(length(odd_positions), 2); % Randomly select two different odd positions
    pos = odd_positions(pos); % Get the actual positions

    % Swap the values at the selected positions (dispatch order adjustment)
    A1([pos(1), pos(2)]) = A1([pos(2), pos(1)]);

    % Swap dispatch times at the same positions
    pos_dispatch = randperm(size(dispatch_times1, 2), 2); % Randomly select two different positions within dispatch_times1
    %2代表列數
    dispatch_times1([pos_dispatch(1), pos_dispatch(2)]) = dispatch_times1([pos_dispatch(2), pos_dispatch(1)]);

    % Store the new chromosome and dispatch times
    Z(i, :) = A1;
    dispatch_times_new2(i, :) = dispatch_times1;
end

Y = Z; % Return the new population

end
