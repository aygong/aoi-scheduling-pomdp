function [h_set, B_set, num_belief, mapping] = beli_prod(transF, obserF)
% Generate the finite sets of belief states
% Declare global variables
% See aoi_main.m
global K D T

% Define the basic components of the POMDP functions
num_state = D;
num_action = K;
num_observation = D + 1;

% Initialize the number of belief states
num_belief = zeros(1, T);
num_belief(1) = 1;

% Initialize the set of belief states
% h_set: the set of \mathbf{h}^{t}
% Shape: (K, num_belief, T0)
h_set = zeros(K, 1, 1);
h_set(1:K, 1, 1) = 2;
% B_set: the set of \mathbb{B}^{t}
% Shape: (K, num_state, num_belief, T0)
B_set = zeros(K, num_state, 1, 1);
B_set(1:K, 1, 1, 1) = 1;

% Initialize the mapping table
% Shape: (num_action, num_observation, num_belief, T0)
mapping = zeros(num_action, num_observation, 1, 1);

% Generate the set of belief states
fprintf("|> Start generation\n");
for t = 2:T
    fprintf("|> slot = %d, num_belief = %d\n", t - 1, num_belief(t-1));
    
    for nb_1 = 1:num_belief(t-1)
        for na = 1:num_action
            for no = 1:num_observation
                % Generate a new belief state in the present slot
                % Generate \mathbf{h}^{t}
                h_t = min(h_set(:, nb_1, t-1) + 1, D);
                if no < D + 1
                    h_t(na) = min(no + 1, D);
                end
                % Generate \mathbb{B}^{t}
                B_t = B_set(:, :, nb_1, t-1);
                B_t(na, :) = B_t(na, :) .* obserF(:, no, na)';
                for k = 1:K
                    B_t(k, :) = B_t(k, :) * transF(:, :, k);
                end
                
                if sum(B_t(na, :)) > 0
                    % Normalize the new belief state
                    B_t(na, :) = B_t(na, :) / sum(B_t(na, :));
                    % Check whether the new belief state has existed
                    % in the set of belief states in the present slot
                    exist = false;
                    if num_belief(t) > 0
                        diff_h = sum(abs(h_set(:, :, t) - h_t));
                        diff_B = sum(abs(B_set(:, :, :, t) - B_t), [1 2]);        
                        for nb_2 = 1:num_belief(t)
                            if diff_h(nb_2) == 0 && diff_B(nb_2) < 1e-12
                                mapping(na, no, nb_1, t-1) = nb_2;
                                exist = true;
                                break
                            end
                        end
                    end
                    if ~exist
                        % Update the set of belief states in the present slot
                        num_belief(t) = num_belief(t) + 1;
                        h_set(:, num_belief(t), t) = h_t;
                        B_set(:, :, num_belief(t), t) = B_t;
                        mapping(na, no, nb_1, t-1) = num_belief(t);
                    end
                end
            end
        end
    end
    
    if num_belief(t) == num_belief(t-1)
        % Check whether the set of belief states changes
        % If yes, the generation will continue
        % Otherwise, the generation will stop
        diff_h = sum(abs(h_set(:, :, t) - h_set(:, :, t-1)), 'all');
        diff_b = sum(abs(B_set(:, :, :, t) - B_set(:, :, :, t-1)), 'all');
        if diff_h == 0 && diff_b < 1e-12
            fprintf("|> Stop generation\n");
            h_set = h_set(:, :, 1:t-1);
            B_set = B_set(:, :, :, 1:t-1);
            break
        end
    end
end