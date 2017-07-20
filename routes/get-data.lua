--#ENDPOINT GET /v1/data/{sn}
-- luacheck: globals request response (magic variables from Murano)
-- Description: Get timeseries data for specific device
-- Parameters: ?window=<number>
local identifier = request.parameters.sn
local window = request.parameters.window -- in minutes,if ?window=<number>

if window == nil then window = '30' end

-- For now, grab all metrics and query them.  In future, can we be smarter about
-- this?
local metrics = Tsdb.listMetrics()

local out = Tsdb.query{
  tags={sn=identifier},
  relative_start = '-' .. window .. 'm',
  metrics=metrics.metrics,
  limit = 5000,
  epoch = 'ms',
}

return out

-- vim: set et ai sw=2 ts=2 :
