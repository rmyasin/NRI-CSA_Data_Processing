function vplot3(inputMat,varargin)
if isempty(inputMat)
    return
end
if size(inputMat,2)~=3
    error('Must input an NX3 matrix');
end

if nargin<2
    plot3(inputMat(:,1),inputMat(:,2),inputMat(:,3));
else
    plot3(inputMat(:,1),inputMat(:,2),inputMat(:,3),varargin{:});
end

end