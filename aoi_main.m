csl = 1; % 1 - small scale; 2 - large scale
K = 2; % the number of end nodes
T = 50; % the finite horizon
D = 15; % the state truncation
la = zeros(1,K); % the status update arrival rate
ch = zeros(1,K); % the successful transmission probability
wt = zeros(1,K); % the importance weight of end nodes
%% successful transmission probability
SNR = 25; % the signal-to-noise ratio (SNR) / dB
d = 5; % the distance from end nodes to the monitor / m
tau = 2; % the path loss factor
gth = 1; % the successful decoding threshold / bps/Hz
ps = exp(-(d^tau)*(2^gth-1)/(10^(SNR/10))); % the successful transmission probability
%% MAIN
la(1:K) = 0.4;
ch(1:K) = ps;
wt(1:K) = 1;
ksi = 1; % 1 - run simulation; others - do not run simulation
SI = 1e+6; % simulation time
switch csl
    case 1
        [dp_ana,dp_sim] = dp_theo(K,D,la,ch,wt,T,SI,ksi);
        [mpp_ana,mpp_sim] = mpp_theo(K,D,la,ch,wt,T,SI,ksi);
    case 2
        mpf_sim = mpf_simu(K,D,la,ch,wt,T,SI);
        mpp_sim = mpp_simu(K,D,la,ch,wt,T,SI);
        map_sim = map_simu(K,D,la,ch,wt,T,SI);
        rdp_sim = rdp_simu(K,D,la,ch,wt,T,SI);
end