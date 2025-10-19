
function unitData = extractUnitFromCellArray(data, index, dim)

    ndimsData = ndims(data{1});
    ref = repmat({':'}, 1, ndimsData);
    ref{dim} = index;

    unitData = cell(size(data));
    for i = 1 : numel(data)
        unitData{i} = data{i}(ref{:});
    end

end%

