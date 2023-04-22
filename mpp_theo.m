function [theo, simu] = mpp_theo()
% Analyze the myopic policy (partial knowledge)
% Declare global variables
% See aoi_main.m
global K D T
global channels weights
global simu_switch

% Define the basic components of the POMDP functions
num_action = K;
num_observation = D + 1;

% Return the POMDP functions of each end node
[transF, obserF] = sigl_func();
% Return the finite sets of belief states
[h_set, B_set, num_belief, mapping] = beli_prod(transF, obserF);

% Set the finite horizon during which the set of belief states changes
T0 = length(h_set(1, 1, :));

% Compute the expected total reward from slot 1 to slot T
% V : the value function corresponding to the myopic policy
% pi: the myopic policy
V = zeros(num_belief(T0), T);
pi = zeros(num_belief(T0), T);
for nb = 1:num_belief(T0)
    V(nb, T) = dot(h_set(:, nb, T0), weights);
end
for t = T-1:-1:1
    t0 = min(t, T0);
    for nb_1 = 1:num_belief(t0)
        % Determine the myopic policy
        acR = zeros(1, num_action);
        h_next = min(D, h_set(:, nb_1, t0) + 1);
        z_next = min(D, (1:D) + 1);
        for na = 1:num_action
            acR(na) = dot(weights, h_next) - weights(na) * h_next(na);
            acR(na) = acR(na) + weights(na) ...
                * (channels(na) * dot(B_set(na, :, nb_1, t0), z_next) ...
                + (1 - channels(na)) * h_next(na));
        end
        [~, pi(nb_1, t)] = min(acR);
        % Compute the value function
        V(nb_1, t) = dot(h_set(:, nb_1, t0), weights);
        for no = 1:num_observation
            nb_2 = mapping(pi(nb_1, t), no, nb_1, t0);
            if nb_2 > 0
                if no < D + 1
                    transP = B_set(pi(nb_1, t), no, nb_1, t0) * channels(pi(nb_1, t));
                else
                    transP = 1 - channels(pi(nb_1, t));
                end
                V(nb_1, t) = V(nb_1, t) + transP * V(nb_2, t+1);
            end
        end
    end
end

% Compute the EWSAoI (theo)
theo = V(1, 1) / T / K;

% Print the EWSAoI (theo)
fprintf("mpp_theo = %.6f\n", theo);

simu = 0;
if simu_switch
    % Return the EWSAoI (simu)
    simu = mpp_simu();
end