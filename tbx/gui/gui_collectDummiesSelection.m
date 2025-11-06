
function gui_collectDummiesSelection(submission)

    arguments
        submission (1, 1) string
    end

    FORM_PATH = {"dummies", "selection"};
    TARGET_PAGE = {"html", "dummies", "selection.html"};

    submission = gui.resolveRawFormSubmission(submission);
    newSelection = submission.selection;
    gui.updateSelection(FORM_PATH, newSelection);
    gui.populateDummiesSelectionHTML();

    % Move on the prerequisites page
    targetPage = fullfile(".", TARGET_PAGE{:});
    web(targetPage);

end%
