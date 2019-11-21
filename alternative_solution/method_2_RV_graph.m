% main, delete previous workspace data
clc; clear;

% the main problem:
% i.   wait time of a request must be below max wait time, wr = trp - trr <= omega
% ii.  travel delay must be below max travel time, dr = tdr - tstarr < delta
%      (this includes wait time and travel time)
% iii. passengers in a vehicle doesnt exceed max capacity, nvpass <= v

% cost/objective = (sum_{v in V} sum_{r in Pv} dr) + (sum_{r in Rok} dr) + (sum_{r in Rko} cko)

% Rok: set of requests that have been assigned to some vehicle
% Rko: set of unassigned requests (constraint on fleet size)
% cko: large constant/penalty for unassigned request

%   https://www.pnas.org/content/pnas/suppl/2017/01/01/1611675114.DCSupplemental/pnas.1611675114.sapp.pdf
%   page 4, 6
%   Given
%       requests, R = {r1,...,rn}
%       vehicles, V = {v1,...,vm} 
%       at their current state (including passengers)
%   anytime optimal algorithm computes an incrementally optimal solution 
%   and consists 
%   of thefollowing three steps (only one shown in this implementation): 
%   Pairwise request-vehicle RV graph, which entails computing:
%     (a) which requests can be pairwise combined, taking into account
%         both their origin and destination
%     (b) which vehicles can serve whichrequests individually, given 
%         their current passengers
% 
%   Two requests r1 and r2 are connected in the graph if they can 
%   potentially  be combined. This is, if a virtual vehicle starting 
%   at the origin of one of them could pick-up and drop-off both
%   requests while satisfying the constraints Z of maximum waiting time and
%   delay. 
%   A cost SUM_r={1,2} (tdr-tstarr) can be associated to each edge, e(r1,r2).

%   Likewise, a request r and a vehicle v are connected if the request can 
%   be served by the vehicle while satisfying the constraints Z. 
%   This is, if travel(v,r)returns a valid trip that drops the current 
%   passengers of the vehicle and the picked request r within the specified 
%   maximum waiting and delay times. The edge is denoted by e(r,v).

%   Limits on the maximum number of edges per node can be imposed, 
%   trading-off optimality at the laterstages. Speed-ups such as the ones 
%   proposed in T-share [4] could be employed in this stage to prune the 
%   most likely vehicles to pick up a request.

% make a new map
% make_rand_graph
make_grid_graph

% makes a new vehicle
make_vehicle 

% make unique vehicles, update their ids, place them at opposite ends of the map
vehicle1 = vehicle_init; vehicle1.id = 1; vehicle1.location = 1;
vehicle2 = vehicle_init; vehicle2.id = 2; vehicle2.location = GRAPH_LENGTH;

% easier to keep track of vehicles with a single data structure
% THE VEHICLE ID NEEDS TO BE CONSISTENT WITH ITS PLACEMENT IN "vehicles"
% we can remove this necessity in the future by having a map from id to vehicle index in vehicles (to-do)
vehicles = [vehicle1, vehicle2];
NUM_VEHICLES = size(vehicles);
NUM_VEHICLES = NUM_VEHICLES(2);

clear vehicle_init;
clear vehicle1;
clear vehicle2;

% collect requests from a separate script
get_requests


% Ride-Sharing:
% requests can be connected if an empty virtual vehicle starting at the
% origin of one of the requests could pick up and drop off both requests
% while satisfying the constraints
% a cost (dr1 + dr2) is associated with each edge e(r1, r2).

% A request r and vehicle v are connect if the request can be served by the
% vehicle while satisfying constraints. Given by travel(v, r). e(v, r)

% travel(v, Rv) returns optimal vehicle route to satisfy travel of all
% passengers, Pv on the vehicle.

% start off with request 1
% grab a request 2
% check if request 2 and request 1 can be connected (feasibly)
% % check this condition for all requests
% % return indeces of requests which can be combined
% % % this will be permutation of requests, since order matters

% we need to check which requests can be combined. This means we need to check
% each request to each request, and see if their union will meet the constraints
requests_which_can_be_combined = [-1, -1];

% the  combination of two nodes is listed here. Case 1 and 2 is explained in the loop
% a stencil is what I am calling (what is usually called) [explicit] declaration (matlab doesn't have this built in)
% stencils are used if there are a lot of cases where I need to make the same object several times
RV_graph_entry_stencil = struct('request1_id', -1, 'request1', -1, ...
                                'request2_id', -1, 'request2', -1, ...
                                'case1', -1, ...
                                'case2', -1);
                            
RV_graph = struct(RV_graph_entry_stencil); % no stencil needed, there will only be one

% reduced request, assumes there is only one vehicle. This structure is used for the sub calculation where
% we calculate case1, case2 within rm, rn with a single vehicle. Since there are two vehicles we do this
% calculation twice, once to the "closest" vehicle and once to the "furthest" vehicle
pot_r1 = struct('id', -1, 'or', -1, 'dr', -1, 'trr', -1, 'tplr', -1, 'tpr', -1, 'tdr', -1, 'tstarr', -1);
pot_rn = pot_r1; % these fields will be populated later


for request_iterator_m = 1:(NUM_VEHICLES*NUM_REQUESTS)
     
    rm = requests(request_iterator_m);
    
    for request_iterator_n = 1:(NUM_VEHICLES*NUM_REQUESTS) % rn, new request is {r_2 ... r_n} where n = NUM_REQUESTS
        
        % make structure which will represent the results of tryig to make rm and rn rideshare
        RV_graph_entry = RV_graph_entry_stencil;

        rn = requests(request_iterator_n); % grab current request

        %   constraints, z, page 2 of supplement
        %   maximum pickup time less than omega
        %   z1      tpr <= tplr <= trr + omega (== 1.1 AND 1.2)
        %   z1.1        tpr <= tplr
        %   z1.2        tplr <= trr + omega, max wait time
        % 
        %   maximum delay is less than delta
        %   z2      tdr <= tstarr + delta         

        % the requests are valid if they meet these constraints. 
        % The constraints are initially true, they may be violated if we add more vehicles to the trip
        % the requests can be safely combined if their combination also meet the conditions
        % there are two cases, if neither case works, then the requests cannot be met

        % sample of requests:
        % Request: r = {or,dr,trr,tplr, tpr**, tdr**, tstarr}
        % Requests: R = {r1, ..., rn}

        % in this test we are trying to make rm rideshare with rn
        % to calculate cases for both vehicles
        % the reason why rm is r1, and rn is r2: rm is the outer loop, we are testing rm with every rn, then we are incrementing rm, and repeating.
        % yes, its redundant to have the request.id field and the request field since the request has the id in it,
        % and the id can be used to fetch the request, but I added both fields to the structure for easier debugging.
        RV_graph_entry.request1_id = rm.id; RV_graph_entry.request1 = rm; 
        RV_graph_entry.request2_id = rn.id; RV_graph_entry.request2 = rn; 
            
        % work with a copy of the request data; liable to change in future iterations of this program
        pot_r1 = rm;
        pot_rn = rn;

        % CASE 1, nodes visited: o1, o2, d1, d2
        % this will affect the time of pickup and time of drop off for r1 and rn

        % pick up for r1 stays the same
        % pick up for r2 = pick up for r1 + distance o1 to o2
        % drop off for r1 = pick up for r2 + distance o2 to d1
        % drop off for r2 = drop off for r1 + distance d1 to d2

        % now check if this potential trip violates the constraints for r1 and rn
        % check thes ame conditions
        %  (                 Z1.1        and             Z1.2          )        and (          Z2            )
        %  (                 Z1.1        and             Z1.2          )        and (          Z2            )
        if (((pot_r1.tpr <= pot_r1.tplr) && (pot_r1.tplr <= pot_r1.trr + OMEGA)) && (pot_r1.dr <= pot_r1.tstarr + DELTA)) && ...
           (((pot_rn.tpr <= pot_r1.tplr) && (pot_rn.tplr <= pot_rn.trr + OMEGA)) && (pot_rn.dr <= pot_rn.tstarr + DELTA))

            % r1 and rn cannot be combined if they are the same trip // trivail case
            if pot_rn.id == pot_r1.id
                RV_graph_entry.case1 = 0;
            else
                RV_graph_entry.case1 = 1; 
            end

        else % r1 and rn cannot be combined because they 
            RV_graph_entry.case1 = 0;
        end

        % again, since we are modifying data no real need hide the origional requests
        % pot_r1 = rm;
        % pot_rn = rn;

        % pick up for r1 stays the same
        % pick up for r2 = pick up for r1 + distance for o1 to o2
        % drop off for r2 = pick up for r2 + distance for o2 to d2
        % drop off for r1 = drop off for r2 + distance for d2 to d1
%         pot_rn.tpr = pot_r1.tpr + distances(G, pot_r1.or, pot_rn.or);
%         pot_rn.tdr = pot_rn.tpr + distances(G, pot_rn.or, pot_rn.dr);
%         pot_r1.tdr = pot_rn.tdr + distances(G, pot_rn.dr, pot_r1.dr);

        % check thes ame conditions
        %  (                 Z1.1        and             Z1.2          )        and (          Z2            )
        %  (                 Z1.1        and             Z1.2          )        and (          Z2            )
        if (((pot_r1.tpr <= pot_r1.tplr) && (pot_r1.tplr <= pot_r1.trr + OMEGA)) && (pot_r1.dr <= pot_r1.tstarr + DELTA)) && ...
           (((pot_rn.tpr <= pot_r1.tplr) && (pot_rn.tplr <= pot_rn.trr + OMEGA)) && (pot_rn.dr <= pot_rn.tstarr + DELTA))

            % r1 and rn cannot be combined if they are the same trip // trivial case
            if pot_rn.id == pot_r1.id
                RV_graph_entry.case2 = 0;
            else
                RV_graph_entry.case2 = 1; % r1 and rn can be combined the under constraints
            end

        else % r1 and rn cannot be combined because they 
            RV_graph_entry.case2 = 0;
        end
        
        % add the request we just evaluated to the RV Graph struct
        if (request_iterator_m == 1) && (request_iterator_n == 1)
            RV_graph = RV_graph_entry;
        else
            RV_graph = struct([RV_graph, RV_graph_entry]);
        end  
    end
       
end

% extract only filled entries, combinations which could potentially exist
RTV_graph = RV_graph_entry_stencil;
initialization_flag = false;
for entry = 1:((NUM_VEHICLES*NUM_REQUESTS)^2)
    
    % examine only valid entries
    if (RV_graph(entry).case1 == 1) || (RV_graph(entry).case2 == 1)
        if (initialization_flag == false)
           initialization_flag = true;
           RTV_graph = RV_graph(entry);
        else
           RTV_graph = struct([RTV_graph, RV_graph(entry)]);
        end
    end
end

% next step:
% see if we can get the same rtv graph given pre-made data
% an alternative test, implementing the e(T,r) and travel(r, V) type equations from the paper




