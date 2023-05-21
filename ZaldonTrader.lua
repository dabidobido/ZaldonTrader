_addon.name = 'Zaldon Trader'
_addon.author = 'Dabidobido'
_addon.version = '1.0.0'
_addon.commands = {'zt'}

require('logger')
require('tables')

trade_item_ids = {
	["Malicious Perch"] =  5995,
	["Bloodblotch"] = 5951,
	["Pelazoea"] = 5815,
	["Giant Catfish"] = 4469,
	["Dark Bass"] = 4428,
	["Jungle Catfish"] = 4307,
	["Crocodilos"] = 5814,
	["Far East Puffer"] = 6489,
	["Gugrusaurus"] = 5127,
	["Lik"] = 5129,
	["Matsya"] = 5468,
	["Cave Cherax"] = 4309,
	["Sea Zombie"] = 4475,
	["Shen"] = 5597,
}
number_of_items = T{}
loop_update = 0

windower.register_event('addon command', function(...)
	local args = {...}
	if args[1] == "trade" then
		trade()
	elseif args[1] == "stop" or args[1] == "s" then
		number_of_items = T{}
		notice("Stopping trades.")
	elseif args[1] == "help" then
		notice("//zt trade: Trades items to Zaldon")
		notice("//zt stop: Trades items to Zaldon")
	end
end)

function trade()
	local inventory = windower.ffxi.get_items(0)
	number_of_items = T{}
	for name, id in pairs(trade_item_ids) do
		for i = 1, inventory.max, 1 do
			if inventory[i] and inventory[i].id == id then
				if number_of_items[name] == nil then
					number_of_items[name] = inventory[i].count
				else
					number_of_items[name] = number_of_items[name] + inventory[i].count
				end
			end
		end
	end
	if number_of_items:length() > 0 then
		for name, number in pairs(number_of_items) do
			notice("Found " .. number .. " " .. name)
		end
		loop_update = os.clock()
	else
		notice("Didn't find any trade items for Zaldon")
	end
end

function update_loop()
	if number_of_items:length() > 0 then
		local time_now = os.clock()
		if time_now >= loop_update then
			local player = windower.ffxi.get_player()
			if player.status == 0 then
				local item_name = nil
				for name, number in pairs(number_of_items) do
					if number > 0 then 
						windower.send_command('input /targetnpc;wait 0.1;input /item "' .. name .. '" <t>')
						notice(number .. " " .. name .. " left to trade.")
					end
					item_name = name
					break
				end
				if item_name ~= nil then 
					number_of_items[item_name] = number_of_items[item_name] - 1
					if number_of_items[item_name] == -1 then
						number_of_items[item_name] = nil
					end
				end
			elseif player.status == 4 then
				windower.send_command('setkey enter down;wait 0.1;setkey enter up')
			end
			loop_update = time_now + 3
		end
	end
end

windower.register_event("prerender", update_loop)