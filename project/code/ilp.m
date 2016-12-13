rng(42);

m = 5;  % number of machines
n = 15;  % number of jobs
d = n;  % precedence dependencies

w = [2, 4, 5, 3, 4, 2, 4, 5, 3, 4, 2, 4, 5, 3, 4];  % weights
p = [2, 3, 4, 5, 6, 2, 3, 4, 5, 6, 2, 3, 4, 5, 6];  % processing time
assert(size(w, 2) == n);
assert(size(p, 2) == n);

% generate random DAG
while true
    nn = n; % Size of matrix
    nr = d; % number of random connections
    ident = eye(nn);       
    nd_idx = find(~ident); % Indices of non-diag elements
    con = randperm(numel(nd_idx), nr); % Pick random elements
    dag_prec = zeros(nn);
    dag_prec( nd_idx(con) ) = 1;
    if graphisdag(sparse(dag_prec))
        break
    end
end

assert(graphisdag(sparse(dag_prec)))
T = sum(p);

% precedence constraints
A_prec = zeros(d, T * n);
b_prec = zeros(d, 1);

insert_idx = 1;
for i = 1 : n
   child_idx = find(dag_prec(i, :));
   for k = 1 : length(child_idx)
       prec_j = (i - 1) * T + 1;
       child_j = (child_idx(k) - 1) * T + 1;
       T_prec = zeros(1, T * n);
       T_prec(prec_j : prec_j + T - 1) = 1 : T;
       T_prec(child_j : child_j + T - 1) = -(1 : T);
       A_prec(insert_idx, :) = T_prec;
       b_prec(insert_idx) = -p(child_idx(k));
       insert_idx = insert_idx + 1;
   end
end
assert(insert_idx == d+1);
% machine constraints 
T_ma = zeros(n, T);
for i = 1 : n
    T_ma(i, 1:p(i)) = 1;
end
A_ma = zeros(T - max(p), T * n);
for i = 1 : T - max(p) + 1
    A_ma(i, :) = reshape(T_ma', [], 1)';
    T_ma = circshift(T_ma, 1, 2);
end
b_ma = ones(T - max(p) + 1, 1) * m;

% == transformation == 
T_all = 1:T;
f = reshape(T_all' * w, [], 1);
intcon = 1 : (T * n);
A_p1 = eye(T * n);
A_n1 = -1 * eye(T * n);
b_p1 = ones(T * n, 1);
b_n1 = zeros(T * n, 1);
A_a1 = zeros(n, T * n);
b_a1 = ones(n, 1);
for i = 1 : n
   A_a1(i, (i - 1) * T + 1 : i * T) = 1; 
end
A_pro = zeros(n, T * n);
b_pro = p';
for i = 1 : n
   A_pro(i, (i - 1) * T + 1 : i * T) = 1:T; 
end

A = [A_prec; A_ma; A_p1; A_n1; A_a1; -A_a1; -A_pro];
b = [b_prec; b_ma; b_p1; b_n1; b_a1; -b_a1; -b_pro];

% == ILP solver ==
x = intlinprog(f,intcon,A,b);
f' * x