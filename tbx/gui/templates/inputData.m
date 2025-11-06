
%% Prepare input data holder 

% Load the input data table
inputTbl = tablex.fromFile(?INPUT_DATA_PATH?);
printTable(inputTbl);

% Create a data holder object
dataHolder = DataHolder(meta, inputTbl);

