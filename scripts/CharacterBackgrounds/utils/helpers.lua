local helpers = {}

helpers.deepCopy = function(tbl)
    if type(tbl) ~= 'table' then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            copy[k] = helpers.deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

return helpers