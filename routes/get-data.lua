--#ENDPOINT GET /v1/data/{sn}
-- luacheck: globals request response (magic variables from Murano)
-- Description: Get timeseries data for specific device

local identifier = request.parameters.sn

-- Grab saved metrics for this device. Or all of them if that fails.
local metrics
local key = string.gsub("_metric_names." .. identifier, '[^%w@.-]', '-')
metrics = Keystore.get{key=key}
if metrics.value == nil or #metrics.value == 0 then
  metrics = Tsdb.listMetrics()
  metrics = metrics.metrics
else
  metrics = metrics.value
end

-- TODO: Allow pulling in of some of the arguments to TSDB?
local out = Tsdb.query{
  tags={sn=identifier},
  metrics=metrics,
  limit = 100,
  epoch = 'ms',
  fill = 'null',
}

if request.parameters.raw ~= nil then
  return out
else

  -- As Array of Objects.
  local resulting = setmetatable({}, {['__type']='slice'})
  for _, row in ipairs(out.values) do
    local nrow = {}
    for cidx,cname in ipairs(out.columns) do
      nrow[cname] = row[cidx]
    end
    table.insert(resulting, nrow)
  end

  return resulting
end

-- vim: set et ai sw=2 ts=2 :
