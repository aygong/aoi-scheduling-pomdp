function [EWSAoI] = rdp_simu(K,D,la,ch,wt,T0,SI)
EWSAoI = zeros(1,SI);
parfor si = 1:SI
    h = ones(1,K); % the AoI of all end nodes
    h(1:K) = 2;
    z = ones(1,K); % the local age of all end nodes
    for t = 1:T0
        EWSAoI(si) = EWSAoI(si) + dot(wt,h);
        ac = ones(1,K);
        ac(randi(K)) = 2;
        for i=1:K
            if ac(i) == 2 && rand() < ch(i)
                h(i) = z(i) + 1;
            else
                h(i) = h(i) + 1;
            end
            h(i) = min(h(i),D);
        end
        for i = 1:K
            if rand() < la(i)
                z(i) = 1;
            else
                z(i) = z(i) + 1;
            end
            z(i) = min(z(i),D);
        end
    end
end
EWSAoI = sum(EWSAoI)/K/SI/T0;
fprintf("rdp_simu = %d\n",EWSAoI);