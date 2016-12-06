local skynet = require "skynet"
require "skynet.manager"
local redis = require "redis"

local CMD = {}
local pool = {}

local maxconn
local function getconn()
    local db = pool[1]
    return db
end

function CMD.start()
    maxconn = tonumber(skynet.getenv("redis_maxconn")) or 1
    for i = 1, maxconn do
        local db = redis.connect{
            host = skynet.getenv("redis_host" .. i),
            port = skynet.getenv("redis_port" .. i),
            db = skynet.getenv("redis_db" .. i )
        }

        if db then
            db:flushdb() --测试期，清理redis数据
            table.insert(pool, db)
        else
            skynet.error("redis connect error")
        end
    end
end

function CMD.set(key, value)
    local db = getconn()
    local retsult = db:set(key,value)

    return retsult
end

function CMD.get(key)
    local db = getconn()
    local retsult = db:get(key)

    return retsult
end

function CMD.hmset(key, t)
    local data = {}
    for k, v in pairs(t) do
        table.insert(data, k)
        table.insert(data, v)
    end

    local db = getconn()
    local result = db:hmset(key, table.unpack(data))

    return result
end

function CMD.hmget(key, ...)
    if not key then return end

    local db = getconn()
    local result = db:hmget(key, ...)

    return result
end

function CMD.hset(key, filed, value)
    local db = getconn()
    local result = db:hset(key,filed,value)

    return result
end

function CMD.hget(key, filed)
    local db = getconn()
    local result = db:hget(key, filed)

    return result
end

function CMD.hgetall(key)
    local db = getconn()
    local result = db:hgetall(key)

    return result
end

function CMD.zadd(key, score, member)
    local db = getconn()
    local result = db:zadd(key, score, member)

    return result
end

function CMD.keys(key)
    local db = getconn()
    local result = db:keys(key)

    return result
end

function CMD.zrange(key, from, to)
    local db = getconn()
    local result = db:zrange(key, from, to)

    return result
end

function CMD.zrem(key, field)
    local db = getconn()
    local result = db:zrem(key, field)

    return result
end

function CMD.zrevrange(key, from, to ,scores)
    local result
    local db = getconn()
    if not scores then
        result = db:zrevrange(key,from,to)
    else
        result = db:zrevrange(key,from,to,scores)
    end

    return result
end

function CMD.zrank(key, member)
    local db = getconn()
    local result = db:zrank(key,member)

    return result
end

function CMD.zrevrank(key, member)
    local db = getconn()
    local result = db:zrevrank(key,member)

    return result
end

function CMD.zscore(key, score)
    local db = getconn()
    local result = db:zscore(key,score)

    return result
end

function CMD.zcount(key, from, to)
    local db = getconn()
    local result = db:zcount(key,from,to)

    return result
end

function CMD.zcard(key)
    local db = getconn()
    local result = db:zcard(key)

    return result
end

function CMD.incr(key)
    local db = getconn()
    local result = db:incr(key)

    return result
end

function CMD.del(key)
    local db = getconn()
    local result = db:del(key)

    return result
end

function CMD.pipeline(t)
    local db = getconn()
    local result = db:pipeline(t, {})
    return result
end


skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = assert(CMD[cmd], cmd .. "not found")
        skynet.retpack(f(...))
    end)

    skynet.register(SERVICE_NAME)
end)
