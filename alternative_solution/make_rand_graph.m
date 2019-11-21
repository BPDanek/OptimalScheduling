% make a random graph
rng(1001); % set seed

% min/max for randi draw in entries of adjacency matrix
RANGE = 1; % since this is an unweighted graph use binary edge weights 0/1
GRAPH_LENGTH = randi([0, 20]); % make random sized map in this range

% make adjacency matrix, also random
% this matrix maps the weights between nodes
A = randi([-RANGE, RANGE], GRAPH_LENGTH, GRAPH_LENGTH);
% A = ones(GRAPH_LENGTH);

% this is a short way to make negative entries of the matrix A zero, 
% thereby making a sparser matrix
A(A < 0) = 0;

% make sure that there is no weight for a path from node i to node i
A = A - diag(diag(A));

% make graph with adjacency matrix
% 'upper' flag only uses the upper half of the matrix, this is because the
% graph function in matlab only uses a symmetric adjacency matrix
% if you're curious as to why, see the wiki page for graphs
G = graph(A, 'upper');

plot(G)