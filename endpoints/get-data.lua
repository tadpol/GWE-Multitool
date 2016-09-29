--#ENDPOINT GET /v1/data/{sn}
-- Description: Get timeseries data for specific device
-- Parameters: ?window=<number>
local identifier = request.parameters.sn
local window = request.parameters.window -- in minutes,if ?window=<number>

if window == nil then window = '30' end

local qq = TSQ.q():from('data')
qq:where_tag_is('sn', identifier)
qq:where_time_ago(window .. 'm')
qq:limit(5000)

if request.parameters.qr ~=nil then return tostring(qq) end
local out = Timeseries.query{ epoch='ms', q = tostring(qq) }
if request.parameters.raw ~= nil then return out end

if out.results ~= nil and out.results[1].series ~= nil then
  response.message = out.results[1].series
else
  response.message = {}
end

-- vim: set et ai sw=2 ts=2 :
