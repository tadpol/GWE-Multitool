--#ENDPOINT GET /v1/report/{sn}/{report}
local sn = request.parameters.sn
local report = request.parameters.report

if sn == nil or report == nil then
	response.code = 400
	response.message = {
		code = 400,
		message = 'missing parameters'
	}
else
	local key = report .. '.' .. sn
	local ret = Keystore.get{key=key}
	if ret.value == nil then
		response.code = 500
		response.message = ret
	else
		response.message = ret.value
	end
end

-- vim: set ai sw=2 ts=2 :
