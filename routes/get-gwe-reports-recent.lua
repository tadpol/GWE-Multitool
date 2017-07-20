--#ENDPOINT GET /v1/report/{sn}
-- luacheck: globals request response (magic variables from Murano)
local sn = request.parameters.sn

if sn == nil then
	response.code = 400
	response.message = {
		code = 400,
		message = 'missing parameter'
	}
else
	local ret = {}
	for _,report in ipairs(GWE.Fields) do
		local key = string.gsub(report .. "." .. sn, '[^%w@.-]', '-')
		local got = Keystore.command{key=key, command='lindex', args={0}}
		ret[report] = got.value
		if got.code ~= nil then
			ret[report] = got
		elseif got.value ~= nil then
			-- Try to decode json from string is they are json.
			local ex, _ = from_json(got.value)
			if ex ~= nil then
				ret[report] = ex
			else
				ret[report] = got
			end
		else -- got.value is nil
			ret[report] = {}
		end
	end
	response.message = ret
end

-- vim: set ai sw=2 ts=2 :

