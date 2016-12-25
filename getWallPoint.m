function [ray, wallpoint] = getWallPoint(img,rayinfo)
%% 
raystep = 2; % pixels
raynum = 14;
xc = rayinfo(3);
yc = rayinfo(4);
alpha = rayinfo(2);
%x = zeros(raynum,1);
%y = zeros(raynum,1);
xtrack = [];
ytrack = [];
flag = 1;
for i=1:raynum
    x = raystep*i*cos(alpha)+xc;
    y = -raystep*i*sin(alpha)+yc; % minus sign b/c of image coordinate
    ray(i,1) = double(img(round(y),round(x))); % x and y are switched 
    % since matrix and image use different coordiates:X=row, Y=col
    if (ray(i,1)~=0)&&(flag==1)
        flag=0;
        wallix = i;
    end
    xtrack = [xtrack;x];
    ytrack = [ytrack;y];
end

%t=(1:length(ray))';
%f = polyfit(t,ray,3);
%ray_fit = polyval(f,t);

%[~,wallix] = max(gradient(ray_fit));
%[~,wallix] = max(gradient(ray));
wallpoint = [xtrack(wallix) ytrack(wallix)];

end
