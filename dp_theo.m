function [theo,simu] = dp_theo(K,D,la,ch,wt,T0,SI,ksi)
%% the state transition function and observation function
n_st = D;
n_ac = K;
n_ob = D + 1;
ob = 1:(D+1);
[Z,G] = sigl_func(K,D,la,ch);
%% generate the finite set of belief states
[h_set,bp_set,bp_num,re_map] = beli_prod(K,D,T0,Z,G);
T_max = length(h_set(1,1,:));
%% dynamic programming
vt = zeros(1,bp_num(T_max));
for nb = 1:bp_num(T_max)
    vt(nb) = sum(dot(h_set(:,nb,T_max),wt));
end
pl = zeros(bp_num(T_max),T0); % the optimal policy
for t = (T0-1):(-1):1
    if t > T_max
        k = T_max;
    else
        k = t;
    end
    vt_pr = zeros(1,bp_num(k));
    parfor nb_1 = 1:bp_num(k)
        dot_min = 1e+10;
        vt_ac = zeros(1,n_ac);
        for na = 1:n_ac
            vt_ac(na) = sum(dot(h_set(:,nb_1,k),wt));
            for no = 1:n_ob
                if ob(no) < D + 1
                    eta = bp_set(na,ob(no),nb_1,k)*ch(na);
                else
                    eta = 1 - ch(na);
                end
                nb_2 = re_map(na,no,nb_1,k);
                if nb_2 > 0
                    vt_ac(na) = vt_ac(na) + eta*vt(nb_2);
                end
            end
        end
        [vt_pr(nb_1),pl(nb_1,t)] = min(vt_ac);
    end
    vt(1:bp_num(k)) = vt_pr(1:bp_num(k));
end
theo = vt(1)/T0/K;
fprintf("dp_theo = %d\n",theo);
simu = 0;
if ksi == 1
    simu = dp_simu(K,D,la,ch,wt,T0,SI,pl,bp_num,h_set,bp_set);
end