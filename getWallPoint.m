function [ray_fit, wallpoint] = getWallPoint(img,rayinfo)
%% 
raystep = 2; % pixels
raynum = 10;
xc = rayinfo(3);
yc = rayinfo(4);
alpha = rayinfo(2);
%x = zeros(raynum,1);
%y = zeros(raynum,1);
xtrack = [];
ytrack = [];
for i=1:raynum
    x = raystep*i*cos(alpha)+xc;
    y = -raystep*i*sin(alpha)+yc; % 500 minus sign b/c of image coordinate
    ray(i,1) = double(img(round(x),round(y)));
    xtrack = [xtrack;x];
    ytrack = [ytrack;y];
end

t=(1:length(ray))';
f = polyfit(t,ray,3);
ray_fit = polyval(f,t);

[~,wallix] = max(gradient(ray_fit));
wallpoint = [xtrack(wallix) ytrack(wallix)];

end
