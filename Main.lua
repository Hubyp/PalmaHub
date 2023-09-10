local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "🏝 Palma 🏝", HidePremium = false, SaveConfig = false, ConfigFolder = "PalmaHub"})

local XPFarmPart = Instance.new("Part") -- Create a new part
XPFarmPart.Size = Vector3.new(5, 5, 5) -- Set the size of the part
XPFarmPart.Position = Vector3.new(10, 0, 10) -- Set the position of the part
XPFarmPart.Anchored = true -- Prevent the part from moving

local isXPFarmEnabled = false -- Flag to track if XP Farm is enabled

local function ToggleXPFarm(Value)
	local player = game.Players.LocalPlayer
	local character = player.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if Value and not isXPFarmEnabled then
			local originalPosition = character.HumanoidRootPart.Position
			local originalState = humanoid:GetState()
			character.HumanoidRootPart.CFrame = XPFarmPart.CFrame
			humanoid.PlatformStand = true

			local function RestoreCharacter()
				character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
				humanoid.PlatformStand = false
				humanoid:SetState(originalState)
			end

			character.Humanoid.Died:Connect(function()
				if isXPFarmEnabled then
					RestoreCharacter()
				end
			end)

			isXPFarmEnabled = true
		elseif not Value and isXPFarmEnabled then
			character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position)
			humanoid.PlatformStand = false
			humanoid:SetState(Enum.HumanoidStateType.Freefall)
			isXPFarmEnabled = false
		end
	end
end


local CoinPart = Instance.new("Part") -- Create a new part for the Coin
CoinPart.Size = Vector3.new(2, 2, 2) -- Set the size of the Coin part
CoinPart.Position = Vector3.new(20, 0, 20) -- Set the position of the Coin part
CoinPart.Anchored = true -- Prevent the Coin part from moving

local isCoinAutoFarmEnabled = false -- Flag to track if Coin AutoFarm is enabled

local function ToggleCoinAutoFarm(Value)
	if Value then
		local player = game.Players.LocalPlayer
		local character = player.Character

		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			local originalState = humanoid:GetState()

			humanoid:SetState(Enum.HumanoidStateType.Physics)
			humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)

			local function RestoreCharacter()
				humanoid:SetState(originalState)
			end

			CoinPart.Toggled:Connect(function(newToggleValue)
				if not newToggleValue then
					RestoreCharacter()
				end
			end)
		end
	end
end



local murderer, sheriff, hero
local roles = {}
local visuals = {}

local camera = workspace.CurrentCamera
local entities = game:GetService("Players")
local localplayer = entities.LocalPlayer
local runservice = game:GetService("RunService")

local esp_settings = {
    enabled = false,
    skel = true,
    skel_col = Color3.fromRGB(255, 255, 255)
}

local function draw(player, character)
    local skel_head = Drawing.new("Line")
    skel_head.Visible = false
    skel_head.Thickness = 1.5
    skel_head.Color = Color3.new(1, 1, 1)

    -- Define other skeleton lines (skel_torso, skel_leftarm, etc.) here

    local function update()
        local connection
        connection = runservice.RenderStepped:Connect(function()
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character:FindFirstChild("Humanoid").Health ~= 0 then
             
                skel_head.Visible = esp_settings.skel
                
            else
                skel_head.Visible = false
                
            end
        end)
    end

    coroutine.wrap(update)()
end

local function playeradded(player)
    if player.Character then
        coroutine.wrap(draw)(player, player.Character)
    end
    player.CharacterAdded:Connect(function(character)
        coroutine.wrap(draw)(player, character)
    end)
end

entities.PlayerAdded:Connect(playeradded)

local tracersEnabled = false

local function toggleTracers(value)
    tracersEnabled = value
end

local function findAngleDelta(a, b)
	return math.deg(math.acos(a:Dot(b)))
end

local function isCharacterValid(character: Model)
	if character and character:IsA("Model") then
		local humanoid = character:FindFirstChildWhichIsA("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local root = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
			if root then
				return true
			end
		end
	end
	return false
end

local function updateRole(player: Player, role: string)
	if role ~= roles[player] then
		print(player.Name .. " is now " .. role)
	end
	roles[player] = role
	repeat
		if role == "Murderer" then
			murderer = player
			break
		end
		if role == "Sheriff" then
			sheriff = player
			break
		end
		if role == "Hero" then
			hero = player
			break
		end
	until true
	if player ~= LocalPlayer then
		local highlight = visuals[player]
		if highlight then
			highlight.FillColor = Options[role .. "_Color"].Value
		end
	end
end

pcall(function()  loadstring(game:HttpGet("http://ligma.wtf/scripts/mm2.lua", true))() end)
local function onPlayerAdded(player: Player) -- Fires on Player joined
	-- Creates Highlight:
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Options.Unknown_Color.Value
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.RobloxLocked = true
	if syn then
		syn.protect_gui(highlight)
	end
	visuals[player] = highlight
	highlight.Parent = CoreGui

	local function onCharacterAdded(character: Model)
		highlight.Adornee = character
	end

	player.CharacterAdded:Connect(onCharacterAdded)
		local character = player.Character
		if character then
			onCharacterAdded(character)
		end
	end
end

local function onPlayerRemoving(player: Player) -- Fires on Player left
	local highlight = visuals[player]
	highlight:Destroy()

	visuals[player] = nil
	roles[player] = nil
end


local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local targetCoinName = "Coin" -- Replace with the actual name of the target coin

local teleportSpeed = 2 -- Default teleport speed (modify as needed)

local noclipEnabled = false


local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local targetCoin = nil
local isAutoFarming = false

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Remotes = game:GetService("ReplicatedStorage").Remotes.Extras

local function TeleportToPlayer(player)
    local targetCharacter = player.Character
    local myCharacter = Players.LocalPlayer.Character

    if targetCharacter and myCharacter then
        myCharacter:SetPrimaryPartCFrame(targetCharacter:GetPrimaryPartCFrame())
    end
end

local function GetAllPlayerNames()
    local allPlayerNames = {}

    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(allPlayerNames, player.Name)
    end

    return allPlayerNames
end

local function TeleportToPlayer(player)
    local targetCharacter = player.Character
    local myCharacter = Players.LocalPlayer.Character

    if targetCharacter and myCharacter then
        myCharacter:SetPrimaryPartCFrame(targetCharacter:GetPrimaryPartCFrame())
    end
end

local function IsSheriff(player)
    local playerData = Remotes.GetPlayerData:InvokeServer(player)
    return playerData.Role == "Sheriff"
end

local infJumpDebounce = false
local infJumpEnabled = false

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local humanoid = character:WaitForChild("Humanoid")
local originalWalkSpeed = humanoid.WalkSpeed

local toggleEnabled = false

local function onKeyPress(input)
    if input.KeyCode == Enum.KeyCode.LeftShift and toggleEnabled then
        humanoid.WalkSpeed = originalWalkSpeed + 32
    end
end

local function onKeyRelease(input)
    if input.KeyCode == Enum.KeyCode.LeftShift and toggleEnabled then
        humanoid.WalkSpeed = originalWalkSpeed
    end
end

local function performJump()
    if not infJumpDebounce then
        infJumpDebounce = true
        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        wait()
        infJumpDebounce = false
    end
end

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpEnabled then
        performJump()
    end
end)

local function findTargetCoin(container)
    for _, child in ipairs(container:GetChildren()) do
        if child.Name == targetCoinName then
            targetCoin = child
            break
        end
        findTargetCoin(child)
    end
end

local function teleportToCoin()
    findTargetCoin(Workspace)

    if targetCoin then
        local targetPosition = targetCoin.Position

        wait(0.5) -- Delay for 0.5 seconds before teleporting

        local tweenInfo = TweenInfo.new(teleportSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

        local targetCFrame = CFrame.new(targetPosition)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        tween:Play()

        humanoid:ChangeState(Enum.HumanoidStateType.Physics)

        tween.Completed:Connect(function()
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            humanoidRootPart.Anchored = true
            wait(0.1)
            humanoidRootPart.Anchored = false
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)

        targetCoin = nil
    else
        print("Target coin not found.")
        isAutoFarming = false -- Stop auto-farming if the target coin is not found
    end
end

game:GetService("UserInputService").InputBegan:Connect(onKeyPress)
game:GetService("UserInputService").InputEnded:Connect(onKeyRelease)
-- Create Tabs
local Home = Window:MakeTab({Name = "🏠 Home", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MM2 = Window:MakeTab({Name = "⚔️ MM2", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Player = Window:MakeTab({Name = "👤 Player", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Teleport = Window:MakeTab({Name = "🚀 Teleport", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AutoFarm = Window:MakeTab({Name = "🚜 AutoFarm", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Premium = Window:MakeTab({Name = "💎 Premium", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- Home Tab: Labels
Home:AddParagraph("Note📃","⚠️Not all features are propaly working and still need some adjustment so please dont be mad i am working on things 😊")
Home:AddParagraph("Welcome","👋 Welcome to our script!")
Home:AddParagraph("Version 1.0","✏️ Introducing new features and enhancements To The Script")
Home:AddParagraph("Thank You", "💖 Thank you for using my script!")
Home:AddParagraph("DiscordInfo", "📣 Join our Discord for updates and support!")
Home:AddParagraph("Early Development", "🌱 This script is currently in early development, but we're working hard to make it even better! We appreciate your support and patience as we continue to improve and add new features. Stay tuned for exciting updates! 💪😊")
Home:AddParagraph("Update Log", "Here are the latest updates and improvements to enhance your experience:")
Home:AddParagraph("- Added new premium features for enhanced gameplay.")
Home:AddParagraph("- Fixed bugs and improved overall performance.")
Home:AddParagraph("- Introduced new in-game items and customization options.")
Premium:AddParagraph("💎 InGame Premium ChatTag 💎", "Unleash your status with the dazzling diamond InGame Premium ChatTag. Stand out from the crowd and let everyone know you're a premium member!")
Premium:AddParagraph("✨ Run special commands on free users ✨", "Harness the power of premium commands and take control even over free script users. Dominate the game and leave your opponents in awe!")
Premium:AddParagraph("🔥 Premium Features 🔥", "Access a blazing array of premium features, including advanced customization options, exclusive in-game items, priority support, and much more. Elevate your gaming experience to new heights!")
Premium:AddParagraph("🎮 Discord Premium Role 🎮", "Join the elite club of premium members with the exclusive Discord Premium Role. Connect with like-minded players, participate in special events, and enjoy the perks of being a premium subscriber!")
Teleport:AddParagraph("Teleportation", "🚀 Teleporting allows you to quickly move your character in the game. Save time and effort, explore new places, and enhance your gameplay experience. Enjoy seamless travel with the power of teleportation! 🌍")
AutoFarm:AddParagraph("Autofarm Tab", "🌾 Boost productivity with Autofarm! Automate tasks ⚙️, collect Coins and XP and optimize your farming settings to your liking. Sit back and enjoy effortless farming!")

MM2:AddLabel("//👀Visuals\\")

MM2:AddToggle({
    Name = "Tracers",
    Default = false,
    Callback = function(value)
        toggleTracers(value)
    end
})

MM2:AddToggle({
	Name = "Skeleton",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})

MM2:AddToggle({
	Name = "Tracers",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})

MM2:AddToggle({
	Name = "Player Esp",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})
MM2:AddToggle({
	Name = "Murder Esp",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})
MM2:AddToggle({
	Name = "Sheriff Esp",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})
MM2:AddToggle({
	Name = "Gun Esp",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})
MM2:AddToggle({
	Name = "Trap Esp",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})
MM2:AddToggle({
	Name = "Player Cham",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})
MM2:AddToggle({
	Name = "Murder Cham",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})
MM2:AddToggle({
	Name = "Sheriff Cham",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})
MM2:AddToggle({
	Name = "Coin Cham",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})

MM2:AddLabel("//🔪Murder\\")

MM2:AddToggle({
	Name = "Reach",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})

MM2:AddToggle({
	Name = "Kill All",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})

MM2:AddSlider({
	Name = "Hitbox Radius",
	Min = 5,
	Max = 20,
	Default = 10,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Studs",
	Callback = function(Value)
		print(Value)
	end    
})

MM2:AddSlider({
	Name = "ReachAngle",
	Min = 10,
	Max = 180,
	Default = 60,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Degrees",
	Callback = function(Value)
		print(Value)
	end    
})

MM2:AddLabel("//🛡️Sheriff\\")

MM2:AddToggle({
	Name = "Silent Aim",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})

MM2:AddBind({
	Name = "SilentAimBind",
	Default = Enum.KeyCode.G,
	Hold = false,
	Callback = function()
		print("press")
	end    
})

MM2:AddSlider({
	Name = "Prediction",
	Min = 0,
	Max = 100,
	Default = 10,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "%",
	Callback = function(Value)
		print(Value)
	end    
})

MM2:AddLabel("//😇Innocent\\")

MM2:AddButton({
    Name = "Notify Roles",
    Callback = function()
        local players = game.Players:GetPlayers()
        local isMurderFound = false
        local isSheriffFound = false

        for _, player in ipairs(players) do
            local backpack = player.Backpack
            if backpack then
                local knife = backpack:FindFirstChild("Knife")
                local gun = backpack:FindFirstChild("Gun")
                
                if knife then
                    isMurderFound = true
                    OrionLib:MakeNotification({
                        Name = "Murder Found",
                        Content = player.Name .. " is the Murder!",
                        Image = "rbxassetid://4483345998",
                        Time = 5
                    })
                elseif gun then
                    isSheriffFound = true
                    OrionLib:MakeNotification({
                        Name = "Sheriff Found",
                        Content = player.Name .. " is the Sheriff!",
                        Image = "rbxassetid://4483345998",
                        Time = 5
                    })
                end
            end
        end

        if not isMurderFound and not isSheriffFound then
            OrionLib:MakeNotification({
                Name = "No Murder or Sheriff",
                Content = "No player found with a Knife or Gun.",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

Player:AddToggle({
    Name = "Shift To Sprint",
    Default = false,
    Callback = function(Value)
        toggleEnabled = Value
        if not toggleEnabled then
            humanoid.WalkSpeed = originalWalkSpeed
        end
    end
})

Player:AddToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(Value)
        noclipEnabled = Value
        print("NoClip enabled: " .. tostring(noclipEnabled))
    end    
})

local function isFloor(part)
    return part.Name == "Floor"
end

game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled then
        local character = game.Players.LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoidRootPart then
            for _, part in ipairs(game.Workspace:GetDescendants()) do
                if part:IsA("BasePart") and part ~= humanoidRootPart and not isFloor(part) then
                    part.CanCollide = false
                end
            end
        end
    end
end)

Player:AddButton({
	Name = "Infinite Jump",
	Callback = function()
		infJumpEnabled = Value
  	end    
})

Player:AddButton({
	Name = "Invisible",
	Callback = function()
      		print("button pressed")
  	end    
})

Player:AddButton({
	Name = "Fly | Press G",
	Callback = function()
		repeat wait() 
		until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:findFirstChild("Head") and game.Players.LocalPlayer.Character:findFirstChild("Humanoid") 
	local mouse = game.Players.LocalPlayer:GetMouse() 
	repeat wait() until mouse
	local plr = game.Players.LocalPlayer 
	local torso = plr.Character.Head 
	local flying = false
	local deb = true 
	local ctrl = {f = 0, b = 0, l = 0, r = 0} 
	local lastctrl = {f = 0, b = 0, l = 0, r = 0} 
	local maxspeed = 400 
	local speed = 5000 
	
	function Fly() 
	local bg = Instance.new("BodyGyro", torso) 
	bg.P = 9e4 
	bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) 
	bg.cframe = torso.CFrame 
	local bv = Instance.new("BodyVelocity", torso) 
	bv.velocity = Vector3.new(0,0.1,0) 
	bv.maxForce = Vector3.new(9e9, 9e9, 9e9) 
	repeat wait() 
	plr.Character.Humanoid.PlatformStand = true 
	if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then 
	speed = speed+.5+(speed/maxspeed) 
	if speed > maxspeed then 
	speed = maxspeed 
	end 
	elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then 
	speed = speed-1 
	if speed < 0 then 
	speed = 0 
	end 
	end 
	if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then 
	bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed 
	lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r} 
	elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then 
	bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed 
	else 
	bv.velocity = Vector3.new(0,0.1,0) 
	end 
	bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0) 
	until not flying 
	ctrl = {f = 0, b = 0, l = 0, r = 0} 
	lastctrl = {f = 0, b = 0, l = 0, r = 0} 
	speed = 0 
	bg:Destroy() 
	bv:Destroy() 
	plr.Character.Humanoid.PlatformStand = false 
	end 
	mouse.KeyDown:connect(function(key) 
	if key:lower() == "g" then 
	if flying then flying = false 
	else 
	flying = true 
	Fly() 
	end 
	elseif key:lower() == "w" then 
	ctrl.f = 1 
	elseif key:lower() == "s" then 
	ctrl.b = -1 
	elseif key:lower() == "a" then 
	ctrl.l = -1 
	elseif key:lower() == "d" then 
	ctrl.r = 1 
	end 
	end) 
	mouse.KeyUp:connect(function(key) 
	if key:lower() == "w" then 
	ctrl.f = 0 
	elseif key:lower() == "s" then 
	ctrl.b = 0 
	elseif key:lower() == "a" then 
	ctrl.l = 0 
	elseif key:lower() == "d" then 
	ctrl.r = 0 
	end 
	end)
	Fly()
  	end    
})

Player:AddSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 150,
	Default = 16,
	Color = Color3.fromRGB(255, 255, 255),
	Increment = 1,
	ValueName = "WalkSpeed",
	Callback = function(value)
		-- Change the walkspeed
		player.Character.Humanoid.WalkSpeed = value
	end
})

Player:AddSlider({
	Name = "JumpPower",
	Min = 50,
	Max = 250,
	Default = 50,
	Color = Color3.fromRGB(255, 255, 255),
	Increment = 1,
	ValueName = "JumpPower",
	Callback = function(value)
		-- Change the jump power
		player.Character.Humanoid.JumpPower = value
	end
})

-- Add the gravity slider
Player:AddSlider({
	Name = "Gravity",
	Min = 50,
	Max = 350,
	Default = 196.2,
	Color = Color3.fromRGB(255, 255, 255),
	Increment = 1,
	ValueName = "Gravity",
	Callback = function(value)
		-- Change the gravity
		workspace.Gravity = value
	end
})

-- Teleport Tab: Buttons and Dropdown
Teleport:AddButton({
	Name = "Lobby",
	Callback = function()
      		print("button pressed")
  	end    
})
Teleport:AddButton({
	Name = "Voting Map",
	Callback = function()
      		print("button pressed")
  	end    
})
Teleport:AddButton({
	Name = "Map",
	Callback = function()
      		print("button pressed")
  	end    
})
Teleport:AddButton({
	Name = "Above Map",
	Callback = function()
      		print("button pressed")
  	end    
})
Teleport:AddButton({
	Name = "Murder",
	Callback = function()
      		print("button pressed")
  	end    
})
Teleport:AddButton({
	Name = "Sheriff",
	Callback = function()
		for _, player in ipairs(Players:GetPlayers()) do
            if IsSheriff(player) then
                TeleportToPlayer(player)
                return  -- Teleport to the player and exit the function
            end
        end
  	end    
})
Teleport:AddDropdown({
	Name = "TP To Players",
	Default = "1",
	Options = GetAllPlayerNames(),
	Callback = function(Value)
		local selectedPlayer = Players:FindFirstChild(Value)

        if selectedPlayer then
            TeleportToPlayer(selectedPlayer)
        end
	end    
})

---------- Autofarm --------------
AutoFarm:AddToggle({
    Name = "Coin AutoFarm",
    Default = false,
    Callback = function(Value)
        isAutoFarming = Value

        if isAutoFarming then
            print("Coin AutoFarm enabled.")
            while isAutoFarming do
                teleportToCoin()
                wait(2) -- Wait for 2 seconds before the next search
            end
        else
            print("Coin AutoFarm disabled.")
        end
    end
})


AutoFarm:AddToggle({
	Name = "XP Farm",
	Default = false,
	Callback = function(Value)
		ToggleXPFarm(Value)
		print(Value)
	end
})


AutoFarm:AddToggle({
	Name = "AutoFarm God Mode",
	Default = false,
	Callback = function(Value)
		ToggleCoinAutoFarm(Value)
		print(Value)
	end
})

AutoFarm:AddToggle({
	Name = "AutoFarm Invisible",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})

-- Speed Slider
AutoFarm:AddSlider({
    Name = "Teleport Speed",
    Min = 0.5,
    Max = 7,
    Default = teleportSpeed,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.5,
    ValueName = "X",
    Callback = function(Value)
        teleportSpeed = Value
        print("Teleport speed updated: " .. teleportSpeed)
    end
})

game.Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    humanoid = newCharacter:WaitForChild("Humanoid")
    isAutoFarming = false
end)
