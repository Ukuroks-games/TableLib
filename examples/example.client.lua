local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tablelib = require(ReplicatedStorage.Packages.TableLib)

if not Players.LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") then
	local frame = Instance.new("Frame", Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui))
	frame.Size = UDim2.fromScale(1, 1)

	local t = tablelib.new(frame, {
		X = 10,
		Y = 10,
	})

	t:AddNewRow()
	t:AddNewColumn()

	t:ReplaceTableCell(1, 1, t:Copy().Container) -- table in table
	t:ReplaceTableCell(2, 3, tablelib.new(t.Data[2][3], { X = 2, Y = 8 }, nil, "TextLabel"))
end
