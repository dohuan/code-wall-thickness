function [ray, wallpoint] = getWallPoint(img,rayinfo)
%%
raystep = 2; % pixels
raynum = 14;
raymax = 45;
xc = rayinfo(3);
yc = rayinfo(4);
alpha = rayinfo(2);

flag = 1;

while (flag==1&&raynum<=raymax)
    xtrack = [];
    ytrack = [];
    for i=1:raynum
        x = raystep*i*cos(alpha)+xc;
        y = -raystep*i*sin(alpha)+yc; % minus sign b/c of image coordinate
        ray(i,1) = double(img(round(y),round(x))); % x and y are switched
        % since matrix and image use different coordiates:X=row, Y=col
        if (ray(i,1)~=1)&&(flag==1)
            flag=0;
            wallix = i;
        end
        xtrack = [xtrack;x];
        ytrack = [ytrack;y];
    end
    raynum = raynum + 1;
end

if (flag==1)
    error('No wall point found!\n');
end

%t=(1:length(ray))';
%f = polyfit(t,ray,3);
%ray_fit = polyval(f,t);

%[~,wallix] = max(gradient(ray_fit));
%[~,wallix] = max(gradient(ray));
wallpoint = [xtrack(wallix) ytrack(wallix)];

end
