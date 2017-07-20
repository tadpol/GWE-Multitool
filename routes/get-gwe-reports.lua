--#ENDPOINT GET /v1/report/{sn}/{report}
-- luacheck: globals request response (magic variables from Murano)
local sn = request.parameters.sn
local report = request.parameters.report

if sn == nil or report == nil then
	response.code = 400
	response.message = {
		code = 400,
		message = 'missing parameters'
	}
else
	local key = string.gsub(report .. "." .. sn, '[^%w@.-]', '-')
	local ret = Keystore.get{key=key}
	if ret.value == nil then
		response.code = 500
		response.message = ret
	else
		-- value should be an array or strings.
		-- Try to decode json from string is they are json.
		local exp = {}
		for _,v in ipairs(ret.value) do
			local ex, _ = from_json(v)
			if ex ~= nil then
				exp[#exp + 1] = ex
			else
				exp[#exp + 1] = v
			end
		end
		response.message = exp
	end
end

-- vim: set ai sw=2 ts=2 :
