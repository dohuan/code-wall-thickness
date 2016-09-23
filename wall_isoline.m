i = 50;

im = double(project.original_images(i).image);
mask = project.masks.data{i};

figure
imshow(im,[])
alphamask(mask,[0 0 1], 0.5);
hold on

% avHUmask = sum(im(mask))/length(find(mask));
% 
% [~,hc] = imcontour(im,[-100:20:100]);
% set(hc,'linecolor','g','linewidth',1)

% LEVEL SET METHOD:
figure
dx=1;dy=1;
b = 0.3*ones(size(im));
phi = evolve2D(im,dx,dy,0.5,1,[],[],0,[],0,[],[],1,b);
hI = imshow(phi);
for i = 2:100 
    phi = evolve2D(im,dx,dy,0.5,i,[],[],0,[],0,[],[],1,b);
    set(hI,'cdata',phi)
    drawnow
end