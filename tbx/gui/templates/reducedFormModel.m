
%% Prepare meta information 

% Create a meta information object
meta = Meta( ...
    ?META_SETTINGS?
);


%% Prepare input data holder 

% Load the input data table
inputTbl = tablex.fromCsv(?INPUT_DATA_PATH?);
printTable(inputTbl);

% Create a data holder object
dataHolder = DataHolder(meta, inputTbl);


%% Prepare reduced-form estimator 

% Create a reduced-form estimator object
estimator = estimator.?ESTIMATOR?( ...
    meta ...
    , ?ESTIMATOR_SETTINGS?
);


%% Create reduced-form model 

% Assemble a reduced-form model from the components
redModel = ReducedForm( ...
    Meta=meta ...
    , DataHolder=dataHolder ...
    , Estimator=estimator ...
    , Dummies=dummies ...
);
printObject(redModel);

