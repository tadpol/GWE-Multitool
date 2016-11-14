--#ENDPOINT GET /v1/data/{sn}
-- luacheck: globals request response (magic variables from Murano)
-- Description: Get timeseries data for specific device
-- Parameters: ?window=<number>
local identifier = request.parameters.sn
local window = request.parameters.window -- in minutes,if ?window=<number>

if window == nil then window = '30' end

local qq = TSQ.q():from('data')
qq:where_tag_is('sn', identifier)
qq:where_time_ago(window .. 'm')
qq:limit(5000)
qq:orderby('time',false)

if request.parameters.qr ~=nil then return tostring(qq) end
local out = Timeseries.query{ epoch='ms', q = tostring(qq) }
if request.parameters.raw ~= nil then return out end

if out.results ~= nil and out.results[1].series ~= nil then
  local result = {}
  for _, row in TSQ.series_ipairs(out.results[1].series) do
    result[#result + 1] = row
  end
  response.message = result
else
  response.message = {}
end

-- vim: set et ai sw=2 ts=2 :
