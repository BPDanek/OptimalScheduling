% The set of trips that contain request k, or edges e(rk, Ti )
I_TR = [1 0 0 0 1 0 0; 0 0 0 0 0 1 1; 0 0 1 0 0 1 0; 0 0 0 1 1 0 1]; %%%%% from RTV graph

% The set of trips that can be serviced by a vehicle j , or edges e(Ti , vj )
I_TV = [0 1 1 0 0 1 0; 1 1 1 1 1 1 1];   %%%%% from RTV graph

% The set of vehicles that can service trip i , or edges e(Ti , vj )
I_VT = I_TV'

% individual costs of trips
c = [1; 2; 3; 4; 5; 6; 7]; %%%%% from RTV graph

% a large enough constant to penalize ignored requests
c_ko = [100; 100; 100; 100];

% the objective function vector 
f = [c; c; c_ko];

%  vector of integer variables
intcon = 1:18;

% linear inequality constraints. Constraint 1
A = [1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 0 0 0;
     [diag(ones(1,14)) zeros(14,4)]];
b = [1;1;I_VT(:,1);I_VT(:,2)];

% linear equality constraints. Constraint 2
Aeq = [I_TR, I_TR, diag(ones(1,4))];
beq = [1;1;1;1]

%  bound constraints. Enforces x's are binary
lb = zeros(18,1)
ub = ones(18,1)

% Call intlinprog
x = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);

% Solutions
% edge e(Ti, vj), 2 columns: 2 vehicles. 7 rows: 7 trips
epsilon = [x(1:7),x(8:14)]
% ignored requests
chi = x(15:18) 