
function code = codeReducedFormModel()

    module = gui.getCurrentModule();
    estimator = gui.getCurrentEstimator();
    estimatorSettings = gui.getCurrentEstimatorSettings();
    metaSettings = gui.getCurrentMetaSettings();
    dataSource = gui.getCurrentDataSource();

    mts = gui.MatlabToScript();

    place = struct();

    % Parts of the code
    place.ESTIMATOR = string(estimator);

    % Settings as code
    place.META_SETTINGS = scripter.printFormAsSettings(metaSettings);
    place.INPUT_DATA_PATH = mts.string(dataSource.FilePath.value);
    place.ESTIMATOR_SETTINGS = scripter.printFormAsSettings(estimatorSettings);

    % Create the code from the template
    code = scripter.readTemplate("reducedFormModel");
    code = scripter.replaceInCode(code, place);

end%

