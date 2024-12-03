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
local Table = TableLib.CreateTable(
	UDim2.new(), 
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

Do not change a size and position of frames from `Table.Data[Row][Column]`

## Clone table

Use function `Copy`

```
local copyTable = TableLib.Copy(Table)
```

## Delete table

use function `DeleteTable`

```
TableLib.DeleteTable(Table)
```
