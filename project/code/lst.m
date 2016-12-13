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

job_list = find(sum(dag_prec,1) == 0);  % no predecessor
scheduled = [];
remain_time = [];
finished = [];
available_machines = m;
weighted_sum = 0;
current_time = 0;

for i = 1 : T
    if length(finished) == n
       break 
    end
    
    while available_machines > 0 && ~isempty(job_list)
        scheduled(end+1) = job_list(1);
        remain_time(end+1) = p(job_list(1));
        job_list(1) = [];
        available_machines = available_machines - 1;
    end
    
    remain_time = remain_time - 1;
    current_time = current_time + 1;
    
    for j = 1 : length(remain_time)
       if remain_time(j) == 0
          weighted_sum = weighted_sum + w(scheduled(j)) * current_time;
          child_row = dag_prec(scheduled(j), :);
          finished(end+1) = scheduled(j);
          child = find(child_row);
          for k = 1 : length(child)
              parent = dag_prec(:, child(k));
              if all(ismember(find(parent), finished))
                  job_list(end+1) = child(k);
              end
          end
          available_machines = available_machines + 1;
          assert(available_machines <= m);
       end
    end
    
    scheduled(remain_time == 0) = [];
    remain_time(remain_time == 0) = [];
end

assert(length(finished) == n);
weighted_sum

