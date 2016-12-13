rng(42);

experiment_num = 100;

m = 1;  % number of machines
n = 30;  % number of jobs

w_max = 2;

w = zeros(1, n); % weights
p = zeros(1, n); % processing time
assert(size(w, 2) == n);
assert(size(p, 2) == n);

lst_weighted_sums = zeros(1, experiment_num);
lst_time = zeros(1, experiment_num);
ilp_weighted_sums = zeros(1, experiment_num);
ilp_time = zeros(1, experiment_num);

for exp = 1 : experiment_num

disp(exp);

w = randi(w_max, 1, n) - 1;
p = 1 - w;

parent = find(p);
child = find(w);

d = 0;
% generate random DAG
disp('generating DAG..');
dag_prec = zeros(n);
for pa = parent
    mark = false;
    for c = child
       if randi(2) > 1
           mark = true;
           dag_prec(pa, c) = 1;
           d = d + 1;
       end
    end
    if ~mark
        dag_prec(pa, child(1)) = 1;
        d = d + 1;
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
