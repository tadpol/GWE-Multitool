--#EVENT r1po61hj3qmhsckkw event
-- luacheck: globals event (magic variable from Murano)

-- Keep a set of devices (aka serial numbers)
Keystore.command{
	key='serialNumbers',
	command = 'sadd',
	args = { event.identity }
}

if event['type'] ~= 'data_in' then
	return
end

--
-- [ {timestamp=<ts>, values = {<alias>= value, …} }, … ]

-- All of this below is trying to be proactivily smart about grabbing who-knows-what
-- and saving it to TSDB.
--
--[======[
local function is_array(o)
	local mt = getmetatable(o)
	local tp = (mt or {})['__type']
	return tp == 'slice'
end
--]======]
local function flatten_json(json, path, depth, metrics)
	path = path or ''
	metrics = metrics or {}
	depth = (depth or 0) + 1
	if type(json) == 'table' then
		for k,v in pairs(json) do
			metrics = flatten_json(v, path .. '.' .. tostring(k), depth, metrics)
		end
		return metrics
	else
		-- Make numeric things numbers.
		if type(json) == 'number' or tostring(tonumber(json)) == json then
			metrics[path] = tonumber(json)
		end
		metrics[path] = json
		return metrics
	end
end


for _, tsval in ipairs(event.payload) do
	local ts = tsval.timestamp
	print(event.payload)
	for alias, value in pairs(tsval.values) do
		print("Looking at :" .. alias .. ": with :" .. value .. ":")
		if table.contains(GWE.Fields, alias) then
			local key = string.gsub(alias .. "." .. event.identity, '[^%w@.-]', '-')
			Keystore.command{
				key = key,
				command = 'lpush',
				args = { value }
			}
			Keystore.command{
				key = key,
				command = 'ltrim',
				args = { 0, 20 }
			}
			--
		else
			local toWrite = {
				tags = { sn = event.identity },
				metrics = {},
				ts = ts
			}
			if type(value) == 'number' or tostring(tonumber(value)) == value then
				toWrite.metrics[alias] = tonumber(value)
			else
				local jvals, err = from_json(value)
				if err ~= nil then
					-- A string that is not JSON.
					toWrite.metrics[alias] = value
				else
					toWrite.tags.gwe = event.identity
					--	if there is a sn field, add that serial number too.
					if jvals.sn ~= nil then
						toWrite.tags.sn = jvals.sn
						Keystore.command{
							key='serialNumbers',
							command = 'sadd',
							args = { jvals.sn }
						}
						jvals.sn = nil
					end
					-- flatten the JSON to key paths and values
					toWrite.metrics = flatten_json(jvals, alias)
				end
			end
			Tsdb.write(toWrite)
		end
	end
end

-- vim: set ai sw=2 ts=2 :
