close all
clear
clc
set(0,'defaultfigurecolor',[1 1 1])
%%

datapath = 'C:/Users/dohuan/Documents/GitHub/wall-thickness/data/';
option = struct('begslice',7,'L',8,'x',7,'N',20,'pts',36,'spacing',1); % 7 100
[ID,scan, option.startID,option.endslice] = textread('./data/dataList.txt','%s %s %d %d',-1);


for i=1:length(ID) 
    wall{i} = getWall(ID{i},scan{i},datapath,option);
     % --- put save code here
end