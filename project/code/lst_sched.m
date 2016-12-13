function weighted_sum = lst_sched(m, n, d, w, p, dag_prec)
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
       if remain_time(j) <= 0
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
    
    for j = 1 : length(job_list)
       if p(job_list(j)) == 0
           weighted_sum = weighted_sum + w(job_list(j)) * current_time;
           finished(end+1) = job_list(j);
       end
    end
    job_list(p(job_list) == 0) = [];
    
end

assert(length(finished) == n);

end