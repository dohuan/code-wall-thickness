i = 550;

im = double(project.original_images(i).image);
mask = project.masks(2).data{i};

figure
imshow(im,[])
alphamask(mask,[0 0 1], 0.5);

[r,c] = find(mask);
set(gca,'Xlim',[min(c)-10 max(c)+10],...
    'Ylim',[min(r)-10 max(r)+10])

hold on

j =1;
for j = 1:50
    try delete(hP), end
    BW = activecontour(im,mask,j);
    b = bwboundaries(BW);
    pts = b{1};
    hP = plot(pts(:,2),pts(:,1),'r','linewidth',2);
    drawnow
end
