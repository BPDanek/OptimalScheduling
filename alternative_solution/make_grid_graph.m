% Copied Leo's code for making a grid graph, not sure how it works
s=[];
i=1;
for j=1:19 %Creating nodes and the coorisponding edges

    if j>=17
        s(i)=j;
        i=i+1;
    elseif floor(j/4)==j/4
        s(i)= j;
        i=i+1;
    else
        s(i)=j;
        s(i+1)=j;
        i=i+2;
    end
     
end

t=[];
i=1;
for j=1:19
   
    if j>=17
        t(i)=j+1;
        i=i+1;
    elseif floor(j/4)==j/4
        t(i)= j+4;
        i=i+1;
    else
        t(i)=j+1;
        t(i+1)=j+4;
        i=i+2;
    end
    
    
end

Xcoor=[0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3];
Ycoor=[0 0 0 0 -1 -1 -1 -1 -2 -2 -2 -2 -3 -3 -3 -3 -4 -4 -4 -4];
%X coor and Ycoor are only used to reorient G

% My (Bens) implementation of the RV graph relies on some parameters,
% we manually populate those now since Leo didn't use them in calculations.
GRAPH_LENGTH = 20;

G=graph(s,t);

plot(G,'XData',Xcoor,'YData',Ycoor)


% also clear unsued variables
clear Xcoor; clear Ycoor; clear i; clear j; clear s; clear t;