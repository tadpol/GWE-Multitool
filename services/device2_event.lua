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
					end
					-- only numbers.
					for k,v in pairs(jvals) do
						if type(v) == 'number' then
							toWrite.metrics[k] = v
						end
					end
				end
			end
			Tsdb.write(toWrite)
		end
	end
end

-- vim: set ai sw=2 ts=2 :
