
function ptOutput = findClosestOnMesh(queryPoints,Vmesh,Fmesh,projectMethod)
if nargin<4
    projectMethod='closest';
end
P1=Vmesh(Fmesh(:,1),:);
P2=Vmesh(Fmesh(:,2),:);
P3=Vmesh(Fmesh(:,3),:);

Npts=size(queryPoints,2);
ptOutput=zeros(3,Npts);
switch projectMethod
    case 'z'
        for jj=1:Npts
            dir=[0;0;1];
            [intersect,~,~,~,xcoor] = TriangleRayIntersection(queryPoints(:,jj),dir, P1,P2,P3,'lineType','line','border','inclusive','eps',1e-8);
            ptOutput(:,jj)=xcoor(intersect,:)';
        end
    case 'organ'
        [n,~]=fitPlane(Vmesh');
        dir=n;
        for jj=1:Npts
            [intersect,~,~,~,xcoor] = TriangleRayIntersection(queryPoints(:,jj),dir, P1,P2,P3,'lineType','line','border','inclusive','eps',1e-8);
            ptOutput(:,jj)=xcoor(intersect,:)';
        end
        
    case 'closest'
        % Find the distance between each point on the sphere and the mesh,
        % use a simple upsampling method
        upsampling=1;
        
        P = upsamplemesh(Fmesh,Vmesh,upsampling);
        for jj=1:Npts
            [k,d] = dsearchn(P,queryPoints(:,jj)');
            [~,i]=min(d);
            ptOutput(:,jj)=P(k(i),:);
        end
    otherwise
        error('Invalid projection method');
end

end