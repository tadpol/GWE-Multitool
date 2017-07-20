--#ENDPOINT POST /v1/dashboard
-- luacheck: globals request response (magic variables from Murano)
-- Body is the JSON to save

local db = request.body
local ex, err = to_json(db)
if ex ~= nil then
	local got = Keystore.set{key='dashboard.0', value=ex}
	if got.code ~= nil then
		response.code = got.code
		response.message = got
	end
else
	response.code = 500
	response.message = err
end

-- vim: set ai sw=2 ts=2 :
