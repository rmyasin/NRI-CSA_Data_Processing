function Tinv=invtrans(T)
Rinv=T(1:3,1:3)';
Tinv=[Rinv,-Rinv*T(1:3,4)
    zeros(1,3) 1];
end

