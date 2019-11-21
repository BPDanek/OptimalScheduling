
% sample of requests:
% Request: r = {or,dr,trr,tplr,tpr,tdr,tstarr}
% Requests: R = {r1, ..., rn}

% random number generating parameters
seed = 494598;
rng(seed);

% draw random requests from problem params
% there isn't a 0th node, start at 1
MIN = 1; 
% note: GRAPH_LENGTH comes from the make_rand_graph.m method, it is random
MAX = GRAPH_LENGTH; 
NUM_REQUESTS = 5; % arbitrary number

% length of an episode, the maximum time a request can occur during
MAX_TIME_LEN = 80; % the max time a request can come in (minutes)

% problem parameters
OMEGA = 4; % maximum wait time in minutes
DELTA = 3; % maximum travel time in minutes

% make list of requests
% I am not familiar with matlab oop so this is how I will init
request_stencil = struct('id', -1, ...
                         'or', -1, 'dr', -1, ...
                         'trr', -1, 'tplr', -1, 'tpr', -1, 'tdr', -1, 'tstarr', -1, 'vehicle_id', -1);
                     
requests = struct(request_stencil);

% need to make requests, drawing them arbitrarily here
random_or = randi([MIN, MAX], [NUM_REQUESTS, 1]);
random_dr = randi([MIN, MAX], [NUM_REQUESTS, 1]);
random_trr = randi([MIN, MAX_TIME_LEN], [NUM_REQUESTS, 1]);

for v = 1:NUM_VEHICLES
    
    for r = 1:NUM_REQUESTS
        % make a new request structure
        request = request_stencil;
        request.id = r;

        % populate requests
        vehicle = vehicles(v);
        request.vehicle_id = vehicle.id;

    %     No need to examine closest vs. furthest distance vehicles, just compute for both
    %     % calculate distance from current vehicle to request. Used to find closest vehicle
    %     % a setncil/declaration that will be copied and filled out, and discarded when not needed
    %     distance_v_r_stencil = struct('vehicle_id', -1, 'dist_to_r', -1);
    %     
    %     distance_v_r = distance_v_r_stencil; % make a copy  of the stencil, we'll  populate these fields
    %     for v = 1:size(vehicles') % shape is 1xn, make it nx1 to iterate over n axis. n: number vehicles, 1: shape of vehicle (since its a single structure, its shape is 1) 
    %         distance = distances(G, vehicles(v).location, request.or);
    %         if v == 1
    %             distance_v_r.vehicle_id = vehicles(v).id;
    %             distance_v_r.dist_to_r = distance;
    %         else
    %             new_entry = distance_v_r_stencil; % copy a new distance_v_r structure
    %             
    %             % populate structure fields
    %             new_entry.vehicle_id =  vehicles(v).id; 
    %             new_entry.dist_to_r = distance;
    %             
    %             % add the new structure to the set of already obseverd distances
    %             distance_v_r = struct([distance_v_r, new_entry]);
    %             
    %         end
    %     end
    %     clear v; % may be useful to have later, clear it now
    %     clear distance_v_r_stencil; % discard stencil for space
    %     clear distance;
    %     clear new_entry;
    %     
    %     % sort, smallest to largest, need to convert to table first
    %     table_v_r = struct2table(distance_v_r);
    %     table_v_r = sortrows(table_v_r, 'dist_to_r'); % sort the table by distance (smallest to greatest)
    %     sorted_ids = table_v_r.vehicle_id;
    %     
    %     closest_vehicle_id = sorted_ids(1); % closest vehicle to the current request
    %     closest_vehicle = vehicles(closest_vehicle_id);
    %     
    %     furthest_vehicle_id = sorted_ids(end); % furthest vehicle (assume only 2 vehicles in the map)
    %     furthest_vehicle = vehicles(furthest_vehicle_id);
    %     
    %     clear table_v_r; clear sorted_ids;

        % draw arbitrary origin and destination for a request
        request.or = random_or(r);
        request.dr = random_dr(r);
        request.trr = random_trr(r);
        request.tplr = request.trr + OMEGA;
        request.tpr = request.trr + distances(G, vehicle.location, request.or);  % travel directly to vehicle is current car state
        request.tdr = request.tpr + distances(G, request.or, request.dr); % assuming go to location directly (updated later if a ride share is possible)
        request.tstarr = request.trr + distances(G, request.or, request.dr); % travel time between or and dr, on graph G;

        % add request to list of all requests
        if (r == 1) && (v == 1) % re-populate init
            requests = request;
        else % normally append request to list or requests
            requests = struct([requests, request]);
        end
    end
end

clear r;
clear v;
clear vehicle;
clear request; % free up redundant space
clear request_stencil; % free up redundant space
clear random_or;
clear random_dr;
clear random_trr;