% Requires that pointList and queryPoints are matrices N1xm and N2xm
% (N2<<N1 generally)

function [distances,selectedPoints,indices] = minPointDist(pointList,queryPoints)
if isempty(queryPoints)
    distances=[];
    selectedPoints=[];
    indices=[];
    return
end
if size(pointList,2)~=size(queryPoints,2)
    error('pointList and queryPoints must have the same row size')
end

Npts=size(queryPoints,1);
distances=zeros(Npts,1);
indices=zeros(Npts,1);
selectedPoints=zeros(Npts,size(pointList,2));
for ii=1:Npts
    [k,d] = dsearchn(pointList,queryPoints(ii,:));
    [distances(ii),minIndex]=min(d);    
    indices(ii)=k(minIndex);
    selectedPoints(ii,:)=pointList(indices(ii),:);
end

end