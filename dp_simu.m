function [simu] = dp_simu(h_set, B_set, num_belief, pi)
% Simulate the optimal policy (partial knowledge)
% Declare global variables
% See aoi_main.m
global K D T
global lambdas channels weights
global simu_indept

% Return the POMDP functions of each end node
[transF, obserF] = sigl_func();

% Set the finite horizon during which the set of belief states changes
T0 = length(h_set(1, 1, :));

belief_index = 1:num_belief(T0);
simu = zeros(1, simu_indept);

parfor si = 1:simu_indept
    % Run independent numerical experiments
    % Initialize the local age of each end node
    z = ones(K, 1);
    % Initialize the AoI of each end node at the monitor
    h = ones(K, 1) * 2;
    % Initialize \mathbb{B}^{t}
    B = zeros(K, D);
    B(:, 1) = 1;
    
    for t = 1:T
        simu(si) = simu(si) + dot(weights, h);
        if t < T
            % Determine the action
            t0 = min(t, T0);
            diff_h = sum(abs(h_set(:, :, t0) - h));
            diff_B = sum(abs(B_set(:, :, :, t0) - B), [1 2]);
            nb = belief_index(diff_h' + squeeze(diff_B) < 1e-12);
            action = ones(1, K);
            action(pi(nb, t)) = 2;
        else
            continue
        end
        % Update the AoI of each end node at the monitor
        no = zeros(1, K);
        for k = 1:K
            if action(k) == 2 && rand() < channels(k)
                no(k) = min(D, z(k));
                h(k) = z(k) + 1;
            else
                no(k) = D + 1;
                h(k) = h(k) + 1;
            end
        end
        h = min(h, D);
        % Update the local age of each end node
        for k = 1:K
            if rand() < lambdas(k)
                z(k) = 1;
            else
                z(k) = z(k) + 1;
            end
        end
        z = min(z, D);
        % Update \mathbb{B}^{t}
        for k = 1:K
            if action(k) == 2
                B(k, :) = B(k, :) .* obserF(:, no(k), k)' * transF(:, :, k);
                B(k, :) = B(k, :) / sum(B(k, :));
            else
                B(k, :) = B(k, :) * transF(:, :, k);
            end
        end
    end
    
end

% Compute the EWSAoI (simu)
simu = sum(simu) / T / K / simu_indept;

% Print the EWSAoI (simu)
fprintf("dp_simu = %.6f\n", simu);