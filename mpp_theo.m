function [theo,simu] = mpp_theo(K,D,la,ch,wt,T0,SI,ksi)
%% the state transition function and observation function
n_st = D;
n_ac = K;
n_ob = D + 1;
ob = 1:(D+1);
[Z,G] = sigl_func(K,D,la,ch);
%% generate the finite set of belief states
[h_set,bp_set,bp_num,re_map] = beli_prod(K,D,T0,Z,G);
T_max = length(h_set(1,1,:));
%% backward induction
vt = zeros(1,bp_num(T_max));
for nb = 1:bp_num(T_max)
    vt(nb) = sum(dot(h_set(:,nb,T_max),wt));
end
pl = zeros(bp_num(T_max),T0); % the myopic policy
z_nx = min((1:D)+1,D);
for t = (T0-1):(-1):1
    if t > T_max
        k = T_max;
    else
        k = t;
    end
    vt_pr = zeros(1,bp_num(k));
    parfor nb_1 = 1:bp_num(k)
        ews_min = 1e+10;
        h_nx = min(h_set(:,nb_1,k)+1,D);
        for na = 1:n_ac
            ews = dot(wt,h_nx) - wt(na)*h_nx(na);
            ews = ews + wt(na)*(dot(z_nx,bp_set(na,:,nb_1,k))*ch(na) + h_nx(na)*(1-ch(na)));
            if ews < ews_min
                ews_min = ews;
                pl(nb_1,t) = na;
            end
        end
        vt_pr(nb_1) = sum(dot(h_set(:,nb_1,k),wt));
        for no = 1:n_ob
            if ob(no) < D + 1
                eta = bp_set(pl(nb_1,t),ob(no),nb_1,k)*ch(pl(nb_1,t));
            else
                eta = 1 - ch(pl(nb_1,t));
            end
            nb_2 = re_map(pl(nb_1,t),no,nb_1,k);
            if nb_2 > 0
                vt_pr(nb_1) = vt_pr(nb_1) + eta*vt(nb_2);
            end
        end
    end
    vt(1:bp_num(k)) = vt_pr(1:bp_num(k));
end
theo = vt(1)/T0/K;
fprintf("mpp_theo = %d\n",theo);
simu = 0;
if ksi == 1
    simu = mpp_simu(K,D,la,ch,wt,T0,SI);
end