--#ENDPOINT GET /v1/dashboard

local got = Keystore.get{key='dashboard.0'}
if got.code ~= nil then
	response.code = got.code
	response.message = got
elseif got.value == nil then
	response.code = 500
	response.message = "No value, no error."
else
	local ex, err = from_json(got.value)
	if ex ~= nil then
		response.message = ex
	else
		response.code = 500
		response.message = err
	end
end


-- vim: set ai sw=2 ts=2 :
