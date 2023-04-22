function [theo, simu] = dp_theo()
% Analyze the optimal policy (partial knowledge)
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
% V : the value function corresponding to the optimal policy
% pi: the optimal policy
V = zeros(num_belief(T0), T);
pi = zeros(num_belief(T0), T);
for nb = 1:num_belief(T0)
    V(nb, T) = dot(h_set(:, nb, T0), weights);
end
for t = T-1:-1:1
    t0 = min(t, T0);
    for nb_1 = 1:num_belief(t0)
        % Determine the optimal policy and compute the value function
        acV = ones(1, num_action) * dot(h_set(:, nb_1, t0), weights);
        for na = 1:num_action
            for no = 1:num_observation
                nb_2 = mapping(na, no, nb_1, t0);
                if nb_2 > 0
                    if no < D + 1
                        transP = B_set(na, no, nb_1, t0) * channels(na);
                    else
                        transP = 1 - channels(na);
                    end
                    acV(na) = acV(na) + transP * V(nb_2, t+1);
                end
            end
        end
        [V(nb_1, t), pi(nb_1, t)] = min(acV);
    end
end

% Compute the EWSAoI (theo)
theo = V(1, 1) / T / K;

% Print the EWSAoI (theo)
fprintf("dp_theo = %.6f\n", theo);

simu = 0;
if simu_switch
    % Return the EWSAoI (simu)
    simu = dp_simu(h_set, B_set, num_belief, pi);
end