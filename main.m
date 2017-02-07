close all
clear
clc
set(0,'defaultfigurecolor',[1 1 1])
%%
tic
datapath = 'C:/Users/dohuan.ME197/Documents/GitHub/wall_thickness/data/';
option = struct('begslice',7,'L',8,'x',7,'N',20,'pts',36,'spacing',1); % 7 100
[ID,scan, startID,endslice] = textread('./data/dataListP11.txt','%s %s %d %d',-1);
% --- the code starts 7 slices BELOW startID-th slice
% --- the code stops at (7 + endslice)-th slice

for i=1:length(ID) 
    fprintf('Processing the scan %s from patient %s...\n',scan{i},ID{i});
    option.startID = startID(i);
    option.endslice = endslice(i);
    wall = getWall(ID{i},scan{i},datapath,option);
     % --- put save code here
     saveName = ['./results/' ID{i} '_' scan{i}];
    save(saveName,'wall')
end
collapsedtime = toc;
fprintf('Run time: %.2f hours \n',collapsedtime/3600);