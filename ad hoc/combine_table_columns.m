function tbl = combine_table_columns(varargin);
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% keyboard

tbl = varargin{1};

for n=2:numel(varargin)
%     sub_tbl = varargin{n};
   f = varargin{n}.Properties.VariableNames;
   
   for k =1:numel(f)
      tbl.(f{k}) = varargin{n}.(f{k}); 
   end
end

end

