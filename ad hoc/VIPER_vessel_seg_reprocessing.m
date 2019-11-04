function batchProcessing(selectedDirectory)
	directoryContentsData			  = dir( [selectedDirectory,'\*.mat'] ) ;

	validDataFiles = {directoryContentsData.name}' ;
	
	validDataFiles( strcmp(validDataFiles,'Peer Verified Table.mat') ) = [] ;
	
	for i = 1:length(validDataFiles)
		allLoadedData{i}  = load( [selectedDirectory,'\',validDataFiles{i}] ) ; %#ok<AGROW>
	end
	
	correctedData = allLoadedData ;
	
	for i = 1:length(validDataFiles)
		tempCorrectedBW_2 = correctedData{i}.derivedPic.BW_2 & imdilate(full(correctedData{i}.derivedPic.wire),strel('disk',15,0)) ;
		tempCorrectedBW_2 = bwmorph(tempCorrectedBW_2,'thin',2) ;
		correctedData{i}.derivedPic.BW_2  = tempCorrectedBW_2 ;
	end
	
	if ~exist('C:\Users\richa\Documents\_vessel.images\blind 246_Copy\correctedData','dir')
		eval( sprintf('mkdir ''%s'' correctedData',selectedDirectory) )
	end
	
	for i = 1:length(validDataFiles)
		tempData = correctedData{i} ; %#ok<NASGU>
		save([selectedDirectory,'\correctedData\',validDataFiles{i}],'-struct','tempData')
	end
end