% The set of trips that contain request k, or edges e(rk, Ti )
I_TR = zeros(4,10); %%%%% from RTV graph
I_TR(1,[1 2 3 7]) = 1; I_TR(2,[1 4 5 8]) = 1; I_TR(3,[2 4 6]) = 1; I_TR(4, [3 5 6 10]) = 1;
% The set of trips that can be serviced by a vehicle j , or edges e(Ti , vj )
I_TV = zeros(2,10);   %%%%% from RTV graph
I_TV(1,[1 4 7 8 9 10])=1; I_TV(2,:)=1;
% The set of vehicles that can service trip i , or edges e(Ti , vj )
I_VT = I_TV';

% individual costs of trips
c1 = [10; 0; 0; 12; 0; 0; 4; 2; 6; 6]; % Car 1
c2 = [4; 4; 4; 2; 6; 2; 0; 0; 0; 0]; % Car 2

% a large enough constant to penalize ignored requests
c_ko = [100; 100; 100; 100];

% the objective function vector 
f = [c1; c2; c_ko];

%  vector of integer variables
intcon = 1:18;

% linear inequality constraints. Constraint 1
A = [ones(1,10) zeros(1,10) zeros(1,4); zeros(1,10) ones(1,10) zeros(1,4);
     [diag(ones(1,20)) zeros(20,4)]];
b = [1;1;I_VT(:,1);I_VT(:,2)];

% linear equality constraints. Constraint 2
Aeq = [I_TR, I_TR, diag(ones(1,4))];
beq = [1;1;1;1]

%  bound constraints. Enforces x's are binary
lb = zeros(24,1);
ub = ones(24,1);

% Call intlinprog
x = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);

% Solutions
% edge e(Ti, vj), 2 columns: 2 vehicles. 7 rows: 7 trips
epsilon = [x(1:10),x(11:20)]
% ignored requests
chi = x(21:24) 