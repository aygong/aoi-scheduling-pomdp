function [transF, obserF] = sigl_func()
% Compute the POMDP functions of each end node
% Declare global variables
% See aoi_main.m
global K D
global lambdas channels

% Create the state transition function and observation function
transF = zeros(D, D, K);
obserF = zeros(D, D+1, K);
for i = 1:K
    for zo = 1:D
        % Compute the state transition function
        transF(zo, 1, i) = lambdas(i);
        transF(zo, min(D, zo+1), i) = 1 - lambdas(i);
        % Compute the observation function
        obserF(zo, zo, i) = channels(i);
        obserF(zo, D+1, i) = 1 - channels(i);
    end
end