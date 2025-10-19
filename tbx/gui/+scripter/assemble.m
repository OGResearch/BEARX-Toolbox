
function code = assemble(options)

    arguments
        options.saveToFile (1, 1) string = ""
    end

    taskSelection = gui.getCurrentTaskSelection();

    snippets = string.empty(0, 1);

    snippets = [snippets; scripter.codePreamble()];

    snippets = [snippets; scripter.codeReducedFormModel()];

    if taskSelection.ReducedFormEstimation
        snippets = [snippets; scripter.codeReducedFormEstimation()];
    end

    if taskSelection.StructuralEstimation
        snippets = [snippets; scripter.codeIdentifier()];
        snippets = [snippets; scripter.codeStructuralEstimation()];
    end

    if taskSelection.ReducedFormForecast
        snippets = [snippets; scripter.codeReducedFormForecast()];
    end

    if taskSelection.StructuralForecast
        snippets = [snippets; scripter.codeStructuralForecast()];
    end

    if taskSelection.ConditionalForecast
        snippets = [snippets; scripter.codeConditionalForecast()];
    end

    if taskSelection.ShockResponses
        snippets = [snippets; scripter.codeShockResponses()];
    end

    if taskSelection.FEVD
        snippets = [snippets; scripter.codeFEVD()];
    end

    if taskSelection.ShockContributions
        snippets = [snippets; scripter.codeShockContributions()];
    end

    code = join(snippets, "");

    if options.saveToFile ~= ""
        textual.write(code, options.saveToFile);
    end

end%

