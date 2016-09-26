--#EVENT device datapoint

-- If the alias is in [device_info, usage_report, update_interval, engine_report,
-- engine_fetch] don't write to TS.
-- Instead append them to the KV logs.
local gwe_fields = ['device_info', 'usage_report', 'update_interval', 'engine_report', 'engine_fetch']

if table.contains(gwe_fields, data.alias) then
  Keystore.command{
    key = data.alias .. "." .. data.device_sn,
    command = 'lpush',
    args = { data.value[2] }
  }
  Keystore.command{
    key = data.alias .. "." .. data.device_sn,
    command = 'ltrim',
    args = { 0, 20 }
  }
else

  -- Write Device Resource Data to timeseries database
  local stamped = nil
  if data.api == "record" then
    stamped = tostring(data.value[1]) .. '000000000'
  end

  -- Coming from GWE, we don't want to just store some of these.
  Timeseries.write{
    query = TSW.write('data', {identifier=data.device_sn}, {[data.alias] = data.value[2]}, stamped)
  }
end

-- vim: set et ai sw=2 ts=2 :
