function qual_score =  prioritize_image_selection_vld(score_vect,tbl);
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

proc_score = score_vect;
% proc_score = abs(score_vect-median(score_vect));

% if tbl.tp==7
     % Get lowest
%     [A,ix] = sort(proc_score,'ascend');
% else
   % Get highest
%     [A,ix] = sort(proc_score,'descend');
% end

% keyboard
if tbl.group_id==1;
    % Get highest
    [A,ix] = sort(proc_score,'descend');
else
    % Get lowest
    [A,ix] = sort(proc_score,'ascend');
% else
   ix = 1:numel(proc_score);
end
[~, idx_rev] = sort(ix); 

idx_rev(idx_rev==1)=numel(score_vect)+1;
% idx_rev(idx_rev==2)=numel(score_vect)+2;

qtile = vect_2_quantile(idx_rev,4,'LowerIsBetterRank');
% qtile=idx_rev;

% Reverse sort of quantile
qual_score=qtile;
if any(qual_score==0); keyboard ;end
% keyboard
end



