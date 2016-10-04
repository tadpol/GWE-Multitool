--#ENDPOINT GET /v1/serialNumbers
-- luacheck: globals request response (magic variables from Murano)

local ret = Keystore.get{key='serialNumbers'}

if ret.value ~= nil then
	response.message = ret.value
else
	response.code = ret.code
	response.message = ret
end

-- vim: set ai sw=2 ts=2 :
