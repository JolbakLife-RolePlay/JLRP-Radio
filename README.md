# JLRP-Radio
Radio item to work with JLRP-Framework and ox_inventory

put this in ox_inventory/data/items.lua :
```lua
['radio'] = {
		label = 'Radio',
		weight = 1000,
		consume = 0,
		allowArmed = false,
		client = {
			export = 'JLRP-Radio.radio',
		}
	},
```
