%  This Matlab code is meant to check whether certain paths are possible
%  for a given car based off restriction and constraints

clear
clc

%Constraints
%The Maximum pick up delay for a person isset here as well as the maximum 
%delay for passengers currently in the car is placed here

MaxTpick=5; %Maximum number of Edge increased allowed to pick up someone
MaxTdel=4;  %Maximum number of final edge delay on passengers allowed 

%Build the world. This portion of this code is created from the previous
%code a direcct copy and paste
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

G=graph(s,t);

plot(G,'XData',Xcoor,'YData',Ycoor)
d=distances(G); %Calculates the shortest distance between 2 points
%To use the distance function use d('insert initial point', target point')
%the shortest path can be tracked using the function
%shortestpath('function','initial point','target point')

%The information for cars should be stored as follows ('current
%location','number of passengers','max capcity','passenger 1','passenger 2'
%'passenger 3', etc) for passenger slots with no passenger fill in with 0
%The information for passenger should be stoed as follows ('spawn point',
%'end point')

Sample_Pass=[6 5; 7 3; 15 8; 14 10;1 4];
Car_1=[1 ,0;0,3;0,0;0,0;0,0];
%This car is located at position 5 has 0 passengers space for 3 passenger. 
%The last 3 rows represent the passenger information is meant to be used as
%a slot to store information for the passenger
Car_2=[18,0;0,3;0,0;0,0;0,0];

%Making possible paths with only one car in consideration  in this case
%only car 1 will be used for this analysis. 


%Counting the number of nearby people for pickup
[num_pass,nodes_of_interest]=size(Sample_Pass);


for i=1:num_pass
    
    distcheck(i)=d(Car_1(1,1),Sample_Pass(i,1)); %Distance from each person
    %A check to make sure that a target is not too far to pick up
    if distcheck(i)>MaxTpick 
        distcheck(i)=-1;
    end
    
end

k=0; %initiallizing a counter used to filter out certain trips

%This for loop filters out all the passenger that exceeds the pickup
%distance as well as create a list of passengers that can be picked up
%within the constraints written from before
for i=1:num_pass

    if distcheck(i)==-1
        k=k+1;
    else
       passenger_allowed(i-k)=i;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NOTE: THIS IS ONLY FOR VEHICALS WITH SMALLER CAPACITIES ELSE THE
%COMPUTATION TIME WILL BE MUCH MUCH LARGER 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Creating a vector that will be used to find all possible combination based
%off the avaiable people to pick up

Car_Pass=[0 passenger_allowed]; 
for i=1:Car_1(2,2)
    
    Array{i}=Car_Pass; %Creating the Cell Array for ndgrid function
    
end

D = Array;
[D{:}] = ndgrid(Array{:});

%Create all possible combination of trips without taking account of the no
%passenger state '0' and duplicate passenger pickup
PosTrip = cell2mat(cellfun(@(m)m(:),D,'uni',0));
[PosTrip1,PosTrip2]=size(PosTrip); 

%Finding the '0' stat among all the data point

k=1; %initiallizing a counter
for i=1:length(PosTrip)
   
    TripTest=PosTrip(i,:); %Calling out an individual combination
    ZeroFind=(TripTest~=0); %Checking what values are not 0 in the call out
    for ii=1:PosTrip2
        j=ii+1;
        if ZeroFind(1)==0 %Finding out trips where the first column is 0
            NumCount(k)=i;
            k=k+1;
            break
        %Finding out the trips that have a zero sandwhiched between
        %passengers
        elseif ii~=PosTrip2 && ZeroFind(j)~=0 && ZeroFind(j-1)==0
            NumCount(k)=i;
            k=k+1;
            break
        end
    end
        
end

PosTrip(NumCount,:)=[]; %Removing trips based off the NumCount

%There are still some repeated passengers in the list the next portion is
%dedicated to removing those repeats

k=1; %Initialize new counter
for i=1:length(PosTrip)
    TripTest=PosTrip(i,:); %Calling out an individual combination
    if sum(TripTest)> sum(unique(TripTest)) %Checking if the trip is unique
        NumCount2(k)=i;
        k=k+1;
    end
end

PosTrip(NumCount2,:)=[];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NOTE: THE CURRENT WAY NUMBERS ARE STORED IN POSTRIP REPRESENTS PICKUP
%ORDER NOT DROPOFF, SO IT IS IMPORTANT TO CHECK WHETHER THE PICKUP
%ORDER DOES NOT EXCEED THE PICKUP TARGET TIMING. THIS IS WHAT THE NEXT
%SECTION COVERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

k=1; %Initialize a counter
for i=1:length(PosTrip)
    TripTest=PosTrip(i,:);
    Tdistance=0; 
    CCar=Car_1(1,1); %Locks the current location of the car 
    for ii=1:PosTrip2        
        if TripTest(ii)~=0
            %Calculate the distance from one point to another and then
            %update car location to the pick up area
            Tdistance=Tdistance+d(CCar,Sample_Pass(TripTest(ii),1));
            CCar=Sample_Pass(TripTest(ii),1);
            if ii==PosTrip2
                TotalDistance(i)=Tdistance;
                if TotalDistance(i)>MaxTpick
                    NumCount3(k)=i;
                    k=k+1;
                end
            end
        elseif TripTest(ii)==0
            %store the calculated pickup distance
            TotalDistance(i)=Tdistance;
            %Check if total pickup distance exceeds the pickup time
            %constraint and record those that do not fit
            if TotalDistance(i)>MaxTpick
                NumCount3(k)=i;
                k=k+1;
            end
            break
        end   
    end    
end

PosTrip(NumCount3,:)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CURRENTLY POSTRIP REPRESENTS ALL THE POSSIBLE TRIPS FOR THE PASSENGERS 
% THAT ARE WITHIN ITS PICKUP RANGE. THIS DOES NOT ACCOUNT FOR WHETHER THE
% PASSANGERS CAN GET DROPPED OFF WITHIN THE CONSTRAINED TIME. THE NEXT STEP
% WILL BE TO FILTER THE OPTIONS OF THE VEHICAL TO THE DROP OFF CONSTRAINT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PermToMin=[];
for i=1:length(PosTrip)

    TripTest=PosTrip(i,:);
    %Creates a Permuation matrix to see poss based on passengers
    Permut=perms(TripTest);
    UniPerm=unique(Permut,'row'); %Unique Permutation only
    

    for ii=1:length(UniPerm)       
        %Last Passenger to get picked up for car location purpose
        LastPickUp=TripTest(find(TripTest,1,'last'));
        CCar=Sample_Pass(LastPickUp,1); %Location of Pick up
        for iii=1:size(UniPerm,2)
            if UniPerm(ii,iii)==0
                %If in the permuation happens to have a 0 add nothing
                dist(iii)=0;
            elseif UniPerm(ii,iii)~=0
                dist(iii)=d(CCar,Sample_Pass(UniPerm(ii,iii),2));
                CCar=Sample_Pass(UniPerm(ii,iii),2);
            end
        end
        TotDrpTim(ii)=sum(dist); %sum the total reavel time for 1 perm.

    end
    
    %Find the path that will lead to the least travel distance required to
    %drop people off as well as the pathing required to complete it.
    MinPLoc=find(TotDrpTim==min(TotDrpTim));
    if length(MinPLoc)>1
        MinPLoc=MinPLoc(1);
    end
    PermToMin(i,:)=UniPerm(MinPLoc,:);
    
    %Minimum edge required for each Permutation
    OptTotDrpTim(i)=min(TotDrpTim);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %NOTE: THE MINIMUM EDGE DROPOFF IS NOT ABSOULUTE. OCCASIONALLY THERE
    %ARE SOME DROP OFF PATHS WITH THE SAME NUMBER OF EDGES TRAVELED
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NOTE:THE NEXT GOAL IS TO TEST WHETHER TAKING THE OPITIMUM PATH WILL
%VIOLATE THE CONSTRAINTS BEFORE MAINLY WHETHER THE DROP OFF WILL INCREASE
%THE TOTAL WAIT TIME THAT PEOPLE HAVE TO DO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

k=1;%%initialize a counter
for i=1:length(PosTrip)
    
    PickUpOrder=PosTrip(i,:);
    %Calling best possible time for that combination
    DropoffOrder=PermToMin(i,:); 
    TripTime=OptTotDrpTim(i);
    LastPickUp=PickUpOrder(find(PickUpOrder,1,'last'));
    CCar=Sample_Pass(LastPickUp,1); %Location of Pick up
    DistTrav=0;
    PreTrav=zeros(1,size(PosTrip,2));
    kk=1; %Initialize a counter to find delay per trip so it can be summed
    cnt=1; %setting counter
    %Adding Prre drop off travel delay
    for ii=1:nnz(PickUpOrder) %nnx counts the non 0 elements
        if PickUpOrder(ii)~=0
            %What order passengers are getting dropped off in
            PassDropOrd(ii)=find(DropoffOrder==PickUpOrder(ii));
        end
        
        if nnz(PickUpOrder)>ii && PickUpOrder(ii+1)~=0
            limit=nnz(PickUpOrder)-1; %setting up a a limit to how many times it runs
            PT1=[];
            for iii=cnt:limit
                PT1(iii)=d(Sample_Pass(PickUpOrder(iii),1),Sample_Pass(PickUpOrder(iii+1),1));
                PreTrav(PassDropOrd(ii))=sum(PT1);
            end
            cnt=cnt+1;         
        end
        
    end
    
    
    for iiii=1:size(PosTrip,2)
        
        
        if DropoffOrder(iiii)~=0
            
            Movement=d(CCar,Sample_Pass(DropoffOrder(iiii),2));
            DistTrav=DistTrav+Movement;
            TotalMov=DistTrav+PreTrav(iiii);
            RecDelay(kk)=TotalMov-d(Sample_Pass(DropoffOrder(iiii),1),Sample_Pass(DropoffOrder(iiii),2));
            CCar=Sample_Pass(DropoffOrder(iiii),2);
            kk=kk+1;
        end 
        
        if PosTrip(i,iiii)~=0
           %Time if it was just a single passenger riding
           BaseTripTime=d(Sample_Pass(PosTrip(i,iiii),1),...
               Sample_Pass(PosTrip(i,iiii),2));
           %Delay incurred because people are RideSharing
           Delay=TripTime-BaseTripTime;
           
           if Delay>MaxTdel
               NumCount4(k)=i;
               k=k+1;
               break
           end
           
        end
       
    end
    RecDelSum(i)=sum(RecDelay);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NOTE: THE  VALUES BELOW SHOW THE POSSIBLE PICKUP ORDER, THE COORESPONDING
%DROPOFF ORDER, AND THE TOTAL DISTANCE NEEDED TO COMPLETE THE ENTIRE TRIP
%FOR CAR 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AllowedPickUpOrder=PosTrip;
DropOffOrder=PermToMin;
TotalTime=OptTotDrpTim;

AllowedPickUpOrder(NumCount4,:)=[]
DropOffOrder(NumCount4,:)=[]
TotalTime(NumCount4)=[]
RecDelSum(NumCount4)=[]
