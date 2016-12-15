local skynet = require "skynet"

skynet.start(function()
    skynet.newservice("debug_console", 8200)
    local mysqlpool = skynet.uniqueservice "mysqlpool"
    skynet.call(mysqlpool, "lua", "start")
    local redispool = skynet.uniqueservice "redispool"
    skynet.call(redispool, "lua", "start")
   	local datasync = skynet.uniqueservice "datasync"
   	skynet.call(datasync, "lua", "start")
    skynet.uniqueservice "webservice"
end)

