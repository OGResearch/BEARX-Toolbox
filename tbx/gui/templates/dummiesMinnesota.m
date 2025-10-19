
%% Create Minnesota prior dummy observations 

% Create a Minnesota prior dummy observations object
minnesota = dummies.Minnesota( ...
    ?SETTINGS?
);

% Include the object in the dummies array for the reduced-form model
dummies{end+1} = minnesota;

