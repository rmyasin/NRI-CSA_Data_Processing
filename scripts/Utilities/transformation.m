function T=transformation(R,p)
if size(p,2)>size(p,1) p=p'; end; %convert d to a column vector

T=[R p;zeros(1,3) 1];

end
