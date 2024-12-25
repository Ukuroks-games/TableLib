local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tablelib = require(ReplicatedStorage.Packages.TableLib)

if not Players.LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") then
	local t = tablelib.new(Instance.new("Frame", Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)), {
		X = 10,
		Y = 10,
	})

	t:AddNewRow()
	t:AddNewColumn()

	t.Data[1][1] = t:Copy().Container -- table in table
end
