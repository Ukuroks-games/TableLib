# How use it

Guide to how use this lib.

For use this lib

Include this lib:
```
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableLib = require(ReplicatedStorage.Packages.TableLib)
```

Table structure have members:
+ `Container` - table in this frame
+ `Data` - array of table elements

## Create table

```
local Table = TableLib.new(
	Instance.new("Frame", game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui),
	{
		X = 10,	-- columns
		Y = 10	-- rows
	}
)
```

## Edit table content

access to elements is:
```
Table.Data[Row][Column]: Frame
```

> Do not change a size and position of frames from `Table.Data[Row][Column]` 


## Clone table

Use function `Copy`

```
local copyTable = Table:Copy()
```

## Delete table

use function `DeleteTable`

```
Table:Destroy()
```

## Add new row

```
Table:AddNewRow()
```

## Add new column

```
Table:AddNewColumn()
```

## Get size of table

### Rows

```
local rowsNum: number = Table:GetRowsNum()
```

### Columns

```
local colsNum: number = Table:GetRowsNum()
```

or num of columns for row:

```
local colsNum: number = Table:GetRowsNum(NumOfRow)
```
