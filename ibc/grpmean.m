function [avg_tbl, row_score]= grpmean(tbl,groupvar_bv,datavar_bv,num_replicates,score_vect,DATA_IS_PAIRED, select_fcn)
% Average images from same biological replicate, with preference given to
% image quality and vessel density
% if ~exist('paired_var_ind','var'); DATA_IS_PAIRED=0; end

% keyboard

[set_tbl, a,b] = unique(tbl(:,groupvar_bv),'rows');
n_groups = size(set_tbl,1);

var_types = cellfun(@(x) regexprep(x,'cell','string'), ...
    varfun(@class,tbl(1,:),'OutputFormat','cell'),'UniformOutput',0);


data_var_names = tbl.Properties.VariableNames(datavar_bv);

group_var_names = tbl.Properties.VariableNames(groupvar_bv);


% Initially make struct of averaged values, convert to table after
avg_st =struct();

row_score = zeros(size(tbl,1),1);

% Index for removal of entries that fail to meet min replicate requirement
remove_ind = false(1,size(n_groups,1));
ind = 1:size(tbl,1);
for n=1:n_groups
    
    % Grab all table entries that match the unique group table 
    matched_grp_bv = sum(bsxfun(@eq,table2array(set_tbl(n,:)),...
        table2array(tbl(:,groupvar_bv))),2)==sum(groupvar_bv);
    
    % Change to linear index
    match_ind = ind(matched_grp_bv);
    
    % If not enough replicates are found, discard
    if numel(match_ind)<num_replicates
      remove_ind(n)=1;
      continue;
    end
    
    % Calculate quality score
%     keyboard
%     qual_score =  score_metric(
    qual_score = select_fcn(score_vect(match_ind),set_tbl(n,:));
%     qual_score = score_vect(match_ind);
    [~,ix] = sort(qual_score);
    
    % Prioritize lower scores for entries included in average
    sorted_match_ind = match_ind(ix);
    
    row_score(sorted_match_ind(1:num_replicates))=1;
    row_score(sorted_match_ind(num_replicates+1:end))=2;
    
    % Adding group vars to averaged table
      for v = 1:numel(group_var_names)
        avg_st.(group_var_names{v})(n,1) = tbl.(group_var_names{v})...
            (sorted_match_ind(1));
      end
    
	% Fill in averaged data vars for each variable seperately according to
	% score, removing nan values (just for that variable)
%     keyboard
    for v = 1:sum(datavar_bv)
%         tbl.Properties.VariableNames{v}
        sorted_vals = tbl.(data_var_names{v})(sorted_match_ind);
        % If all values Nan, just Nan the average value
        if ~all(isnan(sorted_vals))    
           sorted_vals(isnan(sorted_vals))=[];
        end
        avg_st.(data_var_names{v})(n,1)=mean(sorted_vals(1:num_replicates),1);
%         keyboard
    end
    
    
  
%     % Fill in group vars (group metadata)
%     curr_row = table2cell(tbl(sorted_match_ind(1),:));
% %     keyboard
% %     avg_tbl(n, logical([~datavar_bv 0]))= curr_row(~datavar_bv);
%     avg_st(n, logical([groupvar_bv 0]))= curr_row(groupvar_bv);
% %     avg_tbl.num_replicates(n)=num_replicates;
    
end

% Remove entries without enough replicates
f=fields(avg_st);
for n=1:numel(f)
    avg_st.(f{n})(remove_ind)=[];
end
avg_tbl = struct2table(avg_st);

%     keyboard
% keyboard
% for each unique row of exp_num,tp,mouse_num, check to see if members of
% boths groups present
% Remove unpaired data if data is paired
if DATA_IS_PAIRED
%     keyboard
    grp_vars = sort(tbl.Properties.VariableNames(groupvar_bv));
    nonpair_grp_vars = sort(setdiff(grp_vars,'group_id'));
%     keyboard
    unq_stdy_grp_tbl = avg_tbl(:,grp_vars);
    unq_no_pair_tbl = unique(unq_stdy_grp_tbl(:,...
        nonpair_grp_vars),'rows');
    
    % For each cohort (study group ignoring paired data), check if there is
    % a match for both paired data points, else remove all entries
    for n=1:size(unq_no_pair_tbl,1) 
        bv_match = sum(bsxfun(@eq,table2array(unq_no_pair_tbl(n,:)),table2array(unq_stdy_grp_tbl(:,...
            nonpair_grp_vars))),2)==size(unq_no_pair_tbl,2);
        
        bv_cull(n) = numel(unique(unq_stdy_grp_tbl(bv_match,'group_id')))~=2;
        
    end
    
    
    % For each cull_group, find matching indices in avg_tbl and cull
    ind = 1:numel(bv_cull); lind_cull = ind(bv_cull);
    bv_avg_tbl_cull = false(1,size(avg_tbl,1));
    for n=1:numel(lind_cull)
        cull_entry = unq_no_pair_tbl(lind_cull(n),:);
        
%         avg_tbl(:,unq_no_pair_tbl.Properties.VariableNames)
        
         bv_match = sum(bsxfun(@eq,table2array(cull_entry),...
             table2array(avg_tbl(:,unq_no_pair_tbl.Properties.VariableNames))),2)==...
             size(unq_no_pair_tbl,2);
        bv_avg_tbl_cull(bv_match)=1;
    end
        
    % Cull unpaired entries
        avg_tbl(bv_avg_tbl_cull,:)=[];
    end
end

% Remove entries so same n is preserved across all study groups
% study_grp_tbl = grpstats(avg_tbl, setdiff(tbl.Properties.VariableNames(groupvar_bv),{'mouse_num'}));
% min_bio_reps = min(study_grp_tbl.GroupCount);
% remove_ind = zeros(1,1:size(avg_tbl,1));
% for n=1:size(bio_rep_tbl,1)
%     % Identify groups over the count
%     if table2array(bio_rep_tbl(n,'GroupCount')) > min_bio_reps
%         
%         
%     end
%     
% end


% keyboard
