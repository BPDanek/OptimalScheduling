% vehicle to be used in pnas paper
vehicle_init = struct('id', -1,            ... % id used for distinguishing vehicles
                      'location', -1,      ... % sentinel value, means the vehicle isn't used yet
                      'num_passengers', 0, ... % number of current passengers
                      'max_capacity', 2,   ... % capacity of vehicle
                      'pass1', [-1, -1],   ... % passenger represented by request or, dr
                      'pass2', [-1, -1]); 