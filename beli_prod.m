function [h_set,bp_set,bp_num,re_map] = beli_prod(K,D,T0,Z,G)
n_st = D;
n_ac = K;
n_ob = D + 1;
ob = 1:(D+1);
%% generate the finite set of belief states
h_set = zeros(K,1,1);
bp_set = zeros(K,n_st,1,1);
bp_num = zeros(1,T0);
re_map = zeros(n_ac,n_ob,1,1);
bp_num(1) = 1;
h_set(1:K,1,1) = 2;
bp_set(1:K,1,1,1) = 1;
for t = 2:T0
    bp_nx = zeros(K,n_st);
    for nb_1 = 1:bp_num(t-1)
        for na = 1:n_ac
            for no = 1:n_ob
                if na == 1 || (ob(no) < D + 1 && na > 1)
                    h_nx = min(h_set(:,nb_1,t-1)+1,D);
                    if ob(no) < D + 1
                        h_nx(na) = min(ob(no)+1,D);
                    end
                    for i = 1:K
                        if i ~= na
                            bp_nx(i,:) = bp_set(i,:,nb_1,t-1)*Z(:,:,i);
                        else
                            bp_nx(i,:) = bp_set(i,:,nb_1,t-1).*G(i,:,ob(no))*Z(:,:,i);
                        end
                    end
                    if sum(bp_nx(na,:)) > 0
                        bp_nx(na,:) = bp_nx(na,:)./sum(bp_nx(na,:));
                        whes = 1;
                        for nb_2 = 1:bp_num(t)
                            if sum(abs(h_set(:,nb_2,t) - h_nx)) ~= 0
                                continue
                            else
                                if sum(sum(abs(bp_set(:,:,nb_2,t) - bp_nx))) < 1e-14
                                    re_map(na,no,nb_1,t-1) = nb_2;
                                    whes = 0;
                                    break
                                end
                            end
                        end
                        if sum(whes) > 0
                            bp_num(t) = bp_num(t) + 1;
                            h_set(:,bp_num(t),t) = h_nx;
                            bp_set(:,:,bp_num(t),t) = bp_nx;
                            re_map(na,no,nb_1,t-1) = bp_num(t);
                        end
                    end
                else
                    if ob(no) == D+1
                        re_map(na,no,nb_1,t-1) = re_map(1,no,nb_1,t-1);
                    end
                end
            end
        end
    end
%     fprintf("%d,%d\n",t,bp_num(t));
    df_num = bp_num(t) - bp_num(t-1);
    df_h = sum(sum(abs(h_set(:,:,t) - h_set(:,:,t-1))));
    df_bp = sum(sum(sum(abs(bp_set(:,:,:,t) - bp_set(:,:,:,t-1)))));
    if df_num == 0 && df_bp < 1e-12 && df_h == 0
        re_map(:,:,1:bp_num(t),t) = re_map(:,:,1:bp_num(t-1),t-1);
        break
    end
end