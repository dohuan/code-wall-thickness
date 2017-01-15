close all
clear
clc
set(0,'defaultfigurecolor',[1 1 1])
%%
[ID,scan] = textread('./data/dataList.txt','%s %s',-1);
for i=1:length(ID)
    wall = getWall(ID{i},scan{i});
end