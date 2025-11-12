
function gui_collectConditionalSettings(submission)

    gui_collectVanillaForm("tasks", "conditional" + submission);
    gui.populateConditionalSettingsHTML();

    gui.updateConditioningDataTable();
    gui.updateConditioningPlanTable();

    htmlPath = fullfile(".", "html", "tasks", "conditional.html");
    gui.web(htmlPath);

end%

