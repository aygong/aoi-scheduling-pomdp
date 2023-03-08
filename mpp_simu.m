function [EWSAoI] = mpp_simu(K,D,la,ch,wt,T0,SI)
[Z,G] = sigl_func(K,D,la,ch);
z_nx = min((1:D)+1,D);
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
            ews_min = 1e+10;
            h_nx = min(h+1,D);
            for na = 1:K
                ews = dot(wt,h_nx) - wt(na)*h_nx(na);
                ews = ews + wt(na)*(dot(z_nx,bp_no(na,:))*ch(na) + h_nx(na)*(1-ch(na)));
                if ews < ews_min
                    ews_min = ews;
                    ac = ones(1,K);
                    ac(na) = 2;
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
fprintf("mpp_simu = %d\n",EWSAoI);