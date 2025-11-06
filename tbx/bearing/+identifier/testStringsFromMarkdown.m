
function testStrings = testStringsFromMarkdown(filePath)

    fileContent = textual.read(filePath);

    testStrings = extractBetween(fileContent, "```", "```");
    testStrings = strip(split(testStrings, newline()));
    testStrings(testStrings == "") = [];

end%

