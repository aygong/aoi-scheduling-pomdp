function [Z,G]=sigl_func(K,D,la,ch)
Z = zeros(D,D,K);
for i = 1:K
    for zo = 1:D
        for zx = 1:D
            if zx == 1
                Z(zo,zx,i) = la(i);
                continue;
            end
            if zo+1 == zx || (zx == D && zo == D)
                Z(zo,zx,i) = 1-la(i);
            end
        end
    end
end
G = zeros(K,D,D+1);
for i = 1:K
    for z = 1:D
        G(i,z,z) = ch(i);
        G(i,z,D+1) = 1-ch(i);
    end
end