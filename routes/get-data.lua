--#ENDPOINT GET /v1/data/{sn}
-- luacheck: globals request response (magic variables from Murano)
-- Description: Get timeseries data for specific device
-- Parameters: ?window=<number>
local identifier = request.parameters.sn
local window = request.parameters.window -- in minutes,if ?window=<number>

if window == nil then window = '30' end

local out = Tsdb.query{
  tags={sn=identifier},
  relative_start = '-' .. window .. 'm',
  limit = 5000,
  epoch = 'ms',
}

return out

-- vim: set et ai sw=2 ts=2 :
