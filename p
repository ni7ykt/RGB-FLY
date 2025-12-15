local whitelist = {
    "mknhghv",
    "Kadys5373",
    "HYHuiBai",
}

-- 检查是否在白名单中
local function isPlayerWhitelisted(playerName)
    -- 忽略大小写（可选优化，根据需求保留）
    local lowerPlayerName = string.lower(playerName)
    for _, whitelistedName in pairs(whitelist) do
        if string.lower(whitelistedName) == lowerPlayerName then
            return true
        end
    end
    return false
end

-- 执行远程脚本的函数（封装为独立函数，便于维护和异常处理）
local function executeRemoteScript(player)
    -- 防护：仅在服务器端执行时验证权限（如果是客户端脚本，可移除该判断）
    if game:GetService("RunService"):IsServer() then
        warn("注意：服务器端不建议直接执行loadstring，存在安全风险！")
        -- 若为服务器脚本，可改为向客户端发送指令让客户端执行
        -- 示例：game.ReplicatedStorage.RemoteEvent:FireClient(player, "executeScript")
        return
    end

    -- 异常处理：防止远程脚本加载失败导致整个程序崩溃
    local success, err = pcall(function()
        -- 加载并执行远程脚本
        local scriptFunc = loadstring(game:HttpGet("https://raw.githubusercontent.com/ni7ykt/RGB-FLY/refs/heads/main/rjr"))()
        if scriptFunc then
            scriptFunc() -- 执行远程脚本
            print(player.Name .. " 的远程脚本执行成功")
        else
            warn(player.Name .. " 的远程脚本加载失败：未获取到有效函数")
        end
    end)

    if not success then
        warn(player.Name .. " 的远程脚本执行出错：", err)
    end
end

-- 玩家进入游戏时检查白名单并执行操作
local function onPlayerAdded(player)
    local playerName = player.Name
    if isPlayerWhitelisted(playerName) then
        print(playerName .. " 被允许加入游戏，开始执行脚本")
        
        -- 等待玩家角色加载完成（避免执行脚本时角色未创建导致的错误）
        player.CharacterAdded:Connect(function(character)
            -- 可选：等待角色的核心部件加载（如HumanoidRootPart）
            local humanoid = character:WaitForChild("Humanoid", 5)
            local rootPart = character:WaitForChild("HumanoidRootPart", 5)
            
            -- 白名单验证成功后，执行远程脚本
            executeRemoteScript(player)
        end)

        -- 若玩家已有角色（比如脚本晚于玩家加入执行）
        if player.Character then
            executeRemoteScript(player)
        end
    else
        -- 延迟踢出（可选，避免因网络延迟导致的执行问题）
        task.delay(1, function()
            player:Kick(playerName .. " 不在白名单中，被踢出游戏.")
        end)
        print(playerName .. " 不在白名单中，已踢出")
    end
end

-- 监听玩家加入游戏事件
game.Players.PlayerAdded:Connect(onPlayerAdded)

-- 处理已加入的玩家（脚本启动时已经在游戏中的玩家）
for _, player in pairs(game.Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end
