function [simu] = mpp_simu()
% Simulate the myopic policy (partial knowledge)
% Declare global variables
% See aoi_main.m
global K D T
global lambdas channels weights
global simu_indept

% Define the basic components of the POMDP functions
num_action = K;

% Return the POMDP functions of each end node
[transF, obserF] = sigl_func();

z_next = min(D, (1:D) + 1);
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
            acR = zeros(1, num_action);
            h_next = min(D, h + 1);
            for na = 1:num_action
                acR(na) = dot(weights, h_next) - weights(na) * h_next(na);
                acR(na) = acR(na) + weights(na) ...
                    * (channels(na) * dot(B(na, :), z_next) ...
                    + (1 - channels(na)) * h_next(na));
            end
            [~, pi] = min(acR);
            action = ones(1, K);
            action(pi) = 2;
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
fprintf("mpp_simu = %.6f\n", simu);