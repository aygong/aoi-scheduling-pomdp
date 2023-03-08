function [EWSAoI] = mpf_simu(K,D,la,ch,wt,T0,SI)
EWSAoI = zeros(1,SI);
parfor si = 1:SI
    h = zeros(K,1); % the AoI of all end nodes
    h(1:K) = 2;
    z = ones(1,K); % the local age of all end nodes
    ac = zeros(1,K);
    for t = 1:T0
        EWSAoI(si) = EWSAoI(si) + dot(wt,h);
        if t < T0
            ews_max = 0;
            for na = 1:K
                ews = wt(na)*ch(na)*(h(na)-z(na));
                if ews > ews_max
                    ews_max = ews;
                    ac = ones(1,K);
                    ac(na) = 2;
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
fprintf("mpf_simu = %d\n",EWSAoI);