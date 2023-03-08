function [EWSAoI] = dp_simu(K,D,la,ch,wt,T0,SI,pl,bp_num,h_set,bp_set)
[Z,G] = sigl_func(K,D,la,ch);
T_max = length(h_set(1,1,:));
%% simulation
EWSAoI = zeros(1,SI);
parfor si = 1:SI
    bp_no = zeros(K,D);
    bp_no(:,1) = 1;
    h = zeros(K,1); % the AoI of all end nodes
    h(1:K) = 2;
    z = ones(1,K); % the local age of all end nodes
    ac = zeros(1,K);
    for t = 1:T0
        EWSAoI(si) = EWSAoI(si) + dot(wt,h);
        if t < T0
            if t > T_max
                k = T_max;
            else
                k = t;
            end
            for nb = 1:bp_num(k)
                if sum(sum(abs(bp_set(:,:,nb,k) - bp_no))) < 1e-14 &&...
                             sum(abs(h_set(:,nb,k) - h)) == 0
                    ac = ones(1,K);
                    ac(pl(nb,t)) = 2;
                    break
                end
            end
        else
            continue
        end
        ob = zeros(1,K);
        for i = 1:K
            if ac(i) == 2 && rand() < ch(i)
                ob(i) = min(z(i),D);
                h(i) = z(i) + 1;
            else
                ob(i) = D + 1;
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
        for i = 1:K
            if ac(i) == 2
                bp_no(i,:) = bp_no(i,:).*G(i,:,ob(i))*Z(:,:,i);
                bp_no(i,:) = bp_no(i,:)/sum(bp_no(i,:));
            else
                bp_no(i,:) = bp_no(i,:)*Z(:,:,i);
            end
        end
    end
end
EWSAoI = sum(EWSAoI)/K/SI/T0;
fprintf("dp_simu = %d\n",EWSAoI);