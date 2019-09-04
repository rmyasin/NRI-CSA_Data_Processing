function [selectedOnMesh,extraPoints] = reduceSpheres(selectedOnMeshIn,userNumber,ii,jj)

selectedOnMesh = selectedOnMeshIn;
extraIndices=[];
if all([userNumber,ii,jj]==[17,5,2])
    extraIndices=[3,4,8];
elseif all([userNumber,ii,jj]==[18,5,1]) 
    extraIndices=[2,4:18];
end

extraPoints= selectedOnMesh(:,extraIndices);
selectedOnMesh(:,extraIndices)=[];

