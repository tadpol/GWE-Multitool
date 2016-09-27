--#EVENT device datapoint

-- Get the timestamp for this data.
local stamped = nil
if data.api == "record" then
  stamped = tostring(data.value[1]) .. '000000000'
end

-- Keep a set of devices (aka serial numbers)
Keystore.command{
  key='serialNumbers',
  command = 'sadd',
  args = { data.device_sn }
}

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

  -- Now look at sensors_report,
elseif data.alias == "sensors_report" then
  local values, err = from_json(data.value[2])

  if values ~= nil then
    local tags = {gwe = data.device_sn, sn = data.device_sn}
    --  if there is a sn field, add that serial number too.
    if values.sn ~= nil then
      Keystore.command{
        key='serialNumbers',
        command = 'sadd',
        args = { value.sn }
      }
      tags.sn = value.sn
      value.sn = nil
    end

    -- only numbers.
    local fields = {}
    for k,v in pairs(value) do
      if type(v) == 'number' then
        fields[k] = v
      end
    end

    Timeseries.write{
      query = TSW.write('data', tags, fields, stamped)
    }
  end

else
  -- Some new alias; assume it goes in TSDB.
  -- well, if it is a number.
  if type(data.value[2]) == 'number' then
    Timeseries.write{
      query = TSW.write('data', {sn=data.device_sn}, {[data.alias] = data.value[2]}, stamped)
    }
  end
end

-- vim: set et ai sw=2 ts=2 :
