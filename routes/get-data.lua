--#ENDPOINT GET /v1/data/{sn}
-- luacheck: globals request response (magic variables from Murano)
-- Description: Get timeseries data for specific device

local identifier = request.parameters.sn

-- Grab saved metrics for this device. Or all of them if that fails.
local metrics
local key = string.gsub("_metric_names." .. identifier, '[^%w@.-]', '-')
metrics = Keystore.get{key=key}
if metrics.error ~= nil then
  metrics = Tsdb.listMetrics()
  metrics = metrics.metrics
else
  metrics = metrics.value
end

local out = Tsdb.query{
  tags={sn=identifier},
  metrics=metrics,
  limit = 100,
  epoch = 'ms',
}

return out

-- vim: set et ai sw=2 ts=2 :
