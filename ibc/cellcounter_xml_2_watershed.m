function gs_proc_region = cellcounter_xml_2_watershed(count_xml,img_dim);
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% keyboard

elem = @(x) x{1};
st=elem(count_xml.CellCounter_Marker_File.Marker_Data.Marker_Type(5));
c_ng2 = zeros(1, numel(st.Marker));
r_ng2 = zeros(1, numel(st.Marker));
for n=1:numel(st.Marker)
   c_ng2(n) = str2double(st.Marker{n}.MarkerX.Text);
   r_ng2(n) = str2double(st.Marker{n}.MarkerY.Text);
end
lind_ng2_t5 = sub2ind(img_dim, r_ng2, c_ng2);

st=elem(count_xml.CellCounter_Marker_File.Marker_Data.Marker_Type(6));
c_col4 = zeros(1, numel(st.Marker));
r_col4 = zeros(1, numel(st.Marker));
for n=1:numel(st.Marker)
   c_col4(n) = str2double(st.Marker{n}.MarkerX.Text);
   r_col4(n) = str2double(st.Marker{n}.MarkerY.Text);
end
lind_col4_t6 = sub2ind(img_dim, r_col4, c_col4);



gs_type = zeros(img_dim,'uint8');
gs_type(lind_ng2_t5)=5;
gs_type(lind_col4_t6)=6;

% Watershed of points
gs_ws = watershed(bwdist(gs_type));
cc = bwconncomp(gs_ws);

% Label each CC of watershed with type
gs_region_islands = zeros(img_dim,'uint8');
for n=1:cc.NumObjects
   idx = cc.PixelIdxList{n};
   vals = gs_type(idx);
   nzero_val = vals(vals>0);
   gs_region_islands(idx)=nzero_val;
end

gs_proc_region = imdilate(gs_region_islands,strel('arbitrary', ones(3,3)));






% figure; imshow()
% figure; imshow(gs_type>0)

end

