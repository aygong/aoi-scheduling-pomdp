clc, clear

%% Declare global variables
% K: the number of end nodes
% T: the finite horizon
% D: the state truncation
global K T D
% lambdas : the status update arrival rate
% channels: the successful transmission probability
% weights : the importance weight
global lambdas channels weights
% simu_switch: the simulation switch
% simu_indept: the number of independent numerical experiments
global simu_switch simu_indept

% network_config: the type of the network configuration
% Set the type of the network configuration: 'small' and 'large'
% 'small': small network parameters
% 'large': large network parameters
network_config = 'small';

% Set the network configuration
switch network_config
    case 'small'
        K = 2;
        T = 50;
        D = 15;
        simu_indept = 1e+5;
    case 'large'
        K = 5;
        T = 1e+6;
        D = 50;
        simu_indept = 10;
    otherwise
        error("Unexpected network configuration.\n");
end

% Set the status update arrival rate
lambdas = ones(1, K) * 0.4;
% Set the successful transmission probability
channels = ones(1, K) * 0.923987309719834;
% Set the importance weight
weights = ones(1, K);

% Set the simulation switch
simu_switch = true;

%% Return the EWSAoI performance
switch network_config
    case 'small'
        [dp_ana, dp_sim] = dp_theo();
        [mpp_ana, mpp_sim] = mpp_theo();
    case 'large'
        mpf_sim = mpf_simu();
        mpp_sim = mpp_simu();
        map_sim = map_simu();
        rdp_sim = rdp_simu();
    otherwise
        error("Unexpected network configuration.\n");
end