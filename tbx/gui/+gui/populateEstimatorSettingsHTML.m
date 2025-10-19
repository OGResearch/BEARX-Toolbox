
function targetPath = populateEstimatorSettingsHTML()

    NO_SELECTION_TEXT = "<p>Select an estimator first to edit its settings</p>";
    TARGET_PATH = {"estimation", "settings"};

    estimator = gui.getCurrentEstimator();

    if estimator ~= ""
        estimatorSettings = gui.getCurrentEstimatorSettings();
        htmlForm = gui.generateFreeForm( ...
            estimatorSettings ...
            , header=estimator ...
            , action="gui_collectEstimatorSettings" ...
            , getFields = @(x) sort(textual.fields(x)) ...
        );
    else
        htmlForm = NO_SELECTION_TEXT;
    end

    guiFolder = gui_getFolder();
    sourcePath = fullfile(guiFolder, "html", TARGET_PATH{:}) + ".html";
    targetPath = fullfile(".", "html", TARGET_PATH{:}) + ".html";
    gui.copyCustomHTML(sourcePath, targetPath, "?FORM?", htmlForm);

end%

