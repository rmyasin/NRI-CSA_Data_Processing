index=1;
% gtForceNorm = rowNorm(forceGTInterp);
% estForceNorm = rowNorm(output.force.data);
rat{1}=[];
rat{2}=[];
rat{3}=[];
for ii=1:length(output.force.data)
    for jj=1:3
        if sign(output.force.data(ii,jj)) == sign(forceGTInterp(ii,jj)) && abs(forceGTInterp(ii,jj))>0.1 && abs(output.force.data(ii,jj))>0.1
            rat{jj}(end+1)= output.force.data(ii,jj)./forceGTInterp(ii,jj);
        end
    end
end

mean(1./rat{2}) %This gives a gain of 1.30 which is what I wanted originally...