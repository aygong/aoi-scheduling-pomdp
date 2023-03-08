function [EWSAoI] = map_simu(K,D,la,ch,wt,T0,SI)
EWSAoI = zeros(1,SI);
parfor si = 1:SI
    h = zeros(K,1); % the AoI of all end nodes
    h(1:K) = 2;
    z = ones(1,K); % the local age of all end nodes
    ac = zeros(1,K);
    for t = 1:T0
        EWSAoI(si) = EWSAoI(si) + dot(wt,h);
        if t < T0
            h_max = 0;
            for i = 1:K
                if wt(i)*ch(i)*h(i) > h_max
                    h_max = wt(i)*ch(i)*h(i);
                    ac = ones(1,K);
                    ac(i) = 2;
                end
            end
        else
            continue
        end
        for i = 1:K
            if ac(i) == 2 && rand() < ch(i)
                h(i) = z(i) + 1;
            else
                h(i) = h(i) + 1;
            end
        end
        h = min(h,D);
        for i = 1:K
            if rand() < la(i)
                z(i) = 1;
            else
                z(i) = z(i) + 1;
            end
        end
        z = min(z,D);
    end
end
EWSAoI = sum(EWSAoI)/K/SI/T0;
fprintf("map_simu = %d\n",EWSAoI);