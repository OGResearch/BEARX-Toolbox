
function unitData = extractUnitFromNumericArray(data, index, dim)

    ndimsData = ndims(data);
    ref = repmat({':'}, 1, ndimsData);
    ref{dim} = index;
    unitData = data(ref{:});

end%

