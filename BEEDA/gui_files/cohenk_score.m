function cohens_kappa = cohenk_score(trials)

N = numel(trials(:,1));

numyes_curr_rater = sum(trials(:,1));
numno_curr_rater = sum(trials(:,1) == 0);
numyes_paired_rater = sum(trials(:,2));
numno_paired_rater = sum(trials(:,2) == 0);

artifact_num_agreed = sum(sum(trials,2) == 2);
normal_num_agreed = sum(sum(trials,2) == 0);
PRa = (artifact_num_agreed + normal_num_agreed)/N;
PRe = ( ((numyes_curr_rater/N) * (numyes_paired_rater/N)) + ...
    ((numno_curr_rater/N) * (numno_paired_rater/N)) );

cohens_kappa = (PRa - PRe)/(1 - PRe);



