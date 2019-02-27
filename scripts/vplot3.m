function vplot3(data,legend)

if nargin>1
    plot3(data(:,1),data(:,2),data(:,3),legend)
else
    plot3(data(:,1),data(:,2),data(:,3))
end

end