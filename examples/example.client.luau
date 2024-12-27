local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableLib = require(ReplicatedStorage.Packages.TableLib)

if not Players.LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") then
	local gui = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)
	gui.ResetOnSpawn = false
	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.fromScale(1, 1)

	local t = TableLib.new(frame, {
		X = 10,
		Y = 10,
	})

	t:AddNewRow()
	t:AddNewColumn()

	t:ReplaceTableCell(4, 4, t:Copy().Container) -- table in table
	t:ReplaceTableCell(5, 5, TableLib.new(t.Data[2][3], { X = 2, Y = 8 }, nil, "TextLabel").Container)
end
