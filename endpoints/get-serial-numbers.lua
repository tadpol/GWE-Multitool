--#ENDPOINTS GET /v1/serialNumbers

local ret = Keystore.get{key='serialNumbers'}

if ret.value ~= nil then
	response.message = ret.value
else
	response.code = ret.code
	response.message = ret
end

-- vim: set ai sw=2 ts=2 :
