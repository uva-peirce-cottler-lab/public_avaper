function q = vect_2_quantile(v,n_quantiles,sort_order);
TRANSPOSE=0;

if size(v,1)==1;v=v'; TRANSPOSE=1; end


% Define quantile ranges
qn = linspace(0,1, n_quantiles+1);
qn(1)=[];qn(end)=[];

Y = quantile(v,qn);


q=sum(bsxfun(@gt,Y, repmat(v,[1 numel(Y)])),2)+1;
switch sort_order
    case 'LowerIsBetterRank'
        q = max(q) -q+1;
    case 'HigherIsBetterRank'
    otherwise
end


if TRANSPOSE; q=q';end

end