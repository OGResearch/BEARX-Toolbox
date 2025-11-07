
function code = assemble(options)

    arguments
        options.saveToFile (1, 1) string = ""
    end

    % Preparation and estimation

    isMixedFrequency = gui.isMixedFrequency();

    snippets = string.empty(0, 1);

    snippets = [snippets; scripter.codePreamble()];

    snippets = [snippets; scripter.codeDummies()];

    snippets = [snippets; scripter.codeMeta()];

    snippets = [snippets; scripter.codeInputData()];

    if isMixedFrequency
        snippets = [snippets; scripter.codeLowFrequencyInputData()];
    end

    snippets = [snippets; scripter.codeDataHolder()];

    snippets = [snippets; scripter.codeReducedFormModel()];


    % Tasks

    tasks = gui.getCurrentTasks();

    if ismember("ReducedFormEstimation", tasks)
        snippets = [snippets; scripter.codeReducedFormEstimation()];
    end

    if ismember("StructuralEstimation", tasks)
        snippets = [snippets; scripter.codeIdentifier()];
        snippets = [snippets; scripter.codeStructuralEstimation()];
    end

    if ismember("ReducedFormForecast", tasks)
        snippets = [snippets; scripter.codeReducedFormForecast()];
    end

    if ismember("StructuralForecast", tasks)
        snippets = [snippets; scripter.codeStructuralForecast()];
    end

    if ismember("ConditionalForecast", tasks)
        snippets = [snippets; scripter.codeConditionalForecast()];
    end

    if ismember("ShockResponses", tasks)
        snippets = [snippets; scripter.codeShockResponses()];
    end

    if ismember("FEVD", tasks)
        snippets = [snippets; scripter.codeFEVD()];
    end

    if ismember("ShockContributions", tasks)
        snippets = [snippets; scripter.codeShockContributions()];
    end

    code = join(snippets, "");

    if options.saveToFile ~= ""
        textual.write(code, options.saveToFile);
    end

end%

