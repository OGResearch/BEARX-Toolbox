
%% Create a structural model 

structModel = Structural( ...
    reducedForm=redModel ...
    , identifier=ident ...
);
printObject(structModel);


%% Initialize and presample the structural model 

structModel.initialize();
info = structModel.presample(?NUM_SAMPLES?);
printInfo(info);

?SAVE_MAT?save(fullfile(outputFolder, "structuralModel.mat"), "structModel");

