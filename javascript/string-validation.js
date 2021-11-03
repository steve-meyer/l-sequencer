function validate()
{
    var lSystemStringEvents = arrayfromargs(arguments);

    if ( validateLength(lSystemStringEvents) &&
         validateBranchChars(lSystemStringEvents) &&
         validateMetadataSymbols(lSystemStringEvents) )
    {
        outlet(0, lSystemStringEvents);
    }
}


function validateLength(list)
{
    if (list.length < 1)
    {
        error("Production rule may not be blank\n");
        return false;
    }

    return true;
}


function validateBranchChars(list)
{
    if (list[0] == "[" || list[0] == "]")
    {
        error("Production rule '" + list.join(" ") + "' starts with a branching symbol\n");
        return false
    }
    else if (list.filter(function(char) { return char == "["; }).length !=
             list.filter(function(char) { return char == "]"; }).length)
    {
        error("Production rule '" + list.join(" ") + "' contains unterminated branches\n");
        return false;
    }
    else if (hasAdjacentBranchingChars(list))
    {
        error("Production rule '" + list.join(" ") + "' has adjacent branch opening symbols: '[['\n");
        return false;
    }
    else if (closesUnopenedBranch(list))
    {
        error("Production rule '" + list.join(" ") + "' closes a branch that was never opened\n");
        return false;
    }

    return true;
}


function closesUnopenedBranch(list)
{
    var openBranches = 0;
    for (var i = 0; i < list.length; i++)
    {
        if (list[i] == "[") openBranches++;
        if (list[i] == "]") openBranches--;
        if (openBranches == -1) break;
    }
    return (openBranches != 0);
}


function hasAdjacentBranchingChars(list)
{
    var lastChar = null;
    for (var i = 0; i < list.length; i++)
    {
        if (lastChar == "[" && list[i] == "[") return true;
        lastChar = list[i];
    }
    return false;
}


function validateMetadataSymbols(list)
{
    var lastCharIsMetadata = false;
    for (var i = 0; i < list.length; i++)
    {
        if (list[i] == "[") continue;
        if (list[i] == "]" && lastCharIsMetadata) break;
        lastCharIsMetadata = (list[i] == "+" || list[i] == "-");
    }

    if (lastCharIsMetadata)
    {
        error("Production rule '" + list.join(" ") + "' contains metadata symbols with no pairing event symbol\n");
        return false;
    }

    return true;
}
