function [simu] = map_simu()
% Simulate the MaxAoI policy
% Declare global variables
% See aoi_main.m
global K D T
global lambdas channels weights
global simu_indept

simu = zeros(1, simu_indept);

parfor si = 1:simu_indept
    % Run independent numerical experiments
    % Initialize the local age of each end node
    z = ones(K, 1);
    % Initialize the AoI of each end node at the monitor
    h = ones(K, 1) * 2;
    
    for t = 1:T
        simu(si) = simu(si) + dot(weights, h);
        if t < T
            % Determine the action
            [~, pi] = max(weights .* channels .* h);
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
    end
    
end

% Compute the EWSAoI (simu)
simu = sum(simu) / T / K / simu_indept;

% Print the EWSAoI (simu)
fprintf("map_simu = %.6f\n", simu);