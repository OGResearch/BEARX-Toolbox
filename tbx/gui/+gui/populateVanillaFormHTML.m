
function populateVanillaFormHTML(formPath, action)

    arguments
        formPath (1, 2) cell
        action (1, 1) string = ""
    end

    formPath = { string(formPath{1}), string(formPath{2}) };
    htmlEndPath = {"html", formPath{1}, formPath{2} + ".html"};

    if isequal(action, "")
        action = "gui_collectVanillaForm " + formPath{1} + " " + formPath{2} + " ";
    end

    guiFolder = gui_getFolder();
    sourcePath = fullfile(guiFolder, htmlEndPath{:});
    targetPath = fullfile(".", htmlEndPath{:});

    form = gui.readFormsFile(formPath);
    html = gui.generateFreeForm(form, action=action);
    gui.copyCustomHTML(sourcePath, targetPath, "?FORM?", html);

end%

