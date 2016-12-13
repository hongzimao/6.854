rng(42);

m = 3;  % number of machines
n = 30;  % number of jobs
d = n;  % precedence dependencies

w_max = 10;
p_max = 10;

experiment_num = 100;
lst_weighted_sums = zeros(1, experiment_num);
lst_time = zeros(1, experiment_num);
ilp_weighted_sums = zeros(1, experiment_num);
ilp_time = zeros(1, experiment_num);

for exp = 1 : experiment_num

disp(exp);

w = randi(w_max, 1, n); % weights
p = randi(p_max, 1, n); % processing time
assert(size(w, 2) == n);
assert(size(p, 2) == n);

% generate random DAG
disp('generating DAG..');
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

tic;
lst_weighted_sums(exp) = lst_sched(m, n, d, w, p, dag_prec);
lst_time(exp) = toc;
tic;
ilp_weighted_sums(exp) = ilp_sched(m, n, d, w, p, dag_prec);
ilp_time(exp) = toc;

end 

plot(lst_weighted_sums);
hold on;
plot(ilp_weighted_sums);
hold off;
