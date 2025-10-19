
% Starting a GUI application

function resume()

    guiFolder = gui_getFolder();

    % Recreate HTML files from originals
    guiHTMLFolder = fullfile(guiFolder, "html");
    customHTMLFolder = fullfile(".", "html");
    if exist(customHTMLFolder, "dir")
        rmdir(customHTMLFolder, "s");
    end
    copyfile(guiHTMLFolder, customHTMLFolder);


    %
    % Populate HTML files with current forms
    %

    % Input data tab
    gui.populateDataSourceHTML();

    % Reduced-form estimation tab
    gui.populateEstimatorSelectionHTML();
    gui.populateEstimatorSettingsHTML();

    % Meta information tab
    gui.populateMetaSettingsHTML();

    % Dummy observations tab
    gui.populateDummiesSelectionHTML();

    % Structural identification tab
    gui.populateIdentificationSelectionHTML();
    gui.populateVanillaFormHTML({"identification", "cholesky"});

    % Tasks to execute tab
    gui.populateTasksSelectionHTML();
    gui.populateVanillaFormHTML({"tasks", "prerequisites"});
    gui.populateVanillaFormHTML({"tasks", "estimation"});
    gui.populateVanillaFormHTML({"tasks", "identification"});
    gui.populateVanillaFormHTML({"tasks", "redForecast"});
    gui.populateVanillaFormHTML({"tasks", "structForecast"});
    gui.populateVanillaFormHTML({"tasks", "responses"});
    gui.populateVanillaFormHTML({"tasks", "fevd"});
    gui.populateVanillaFormHTML({"tasks", "contributions"});

    gui.populateConditionalSettingsHTML();

    % Matlab script tab
    gui.populateScriptSettingsHTML();
    gui.populateScriptExecutionHTML();
    gui.populateScriptListingHTML();


    %
    % Populate notes in all tabs
    %
    tabs = [
        "home", "data", "meta", "estimation", ...
        "identification", "tasks", "script"
    ];
    for i = tabs
        gui.populateNotesHTML(i);
    end


    %
    % Insert the correct paths to tables in the HTML files
    %
    currentFolder = pwd();
    wrapPath = @(n) fullfile(currentFolder, "tables", n);
    dispatcher = {
        fullfile(".", "html", "identification", "zeros.html"), "?PATH?", wrapPath("InstantZeros.xlsx")
        fullfile(".", "html", "identification", "inequality.html"), "?PATH?", wrapPath("IneqRestrict.xlsx")
        fullfile(".", "html", "identification", "generalRestrict.html"), "?PATH?", "matlab: edit(fullfile('tables', 'GeneraldRestrict.txt'))"
    };
    for i = 1 : height(dispatcher)
        htmlPath = dispatcher{i, 1};
        placeholder = dispatcher{i, 2};
        href = dispatcher{i, 3};
        gui.copyCustomHTML(htmlPath, htmlPath, placeholder, href);
    end


    %
    % Open Matlab web browser with the landing page
    %
    customHTMLFolder = fullfile(".", "html");
    indexPath = fullfile(customHTMLFolder, 'index.html');
    web(indexPath);

end%

