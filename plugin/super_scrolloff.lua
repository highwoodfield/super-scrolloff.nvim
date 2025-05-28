-- GLOBAL VARIABLES:
--
-- g:super_scrolloff_enable = v:true
--		Set whether super scrolloff is enabled or not
-- g:super_scrolloff = 5
-- 		Set scrolloff (make sure 'scrolloff' is 0)
-- 

-- if you try to use 'scrolloff' at the same time, it conflicts when the value is 999

if vim.g.super_scrolloff_enable == nil then
	vim.g.super_scrolloff_enable = true
end
if vim.g.super_scrolloff == nil then
	vim.g.super_scrolloff = 5
end

local TYPE_CURSOR = 1
local TYPE_SCROLL = 2

local fn = vim.fn

local t_sum = 0
local t_cnt = 0

local last_cur_abs_line = -1

local on_move = function(evt_type)
	if not vim.g.super_scrolloff_enable then
		return
	end

	local cur_pos = vim.api.nvim_win_get_cursor(0)
	local cur_abs_line = cur_pos[1]
	local cur_abs_col = cur_pos[2]
	if evt_type == TYPE_CURSOR and last_cur_abs_line == cur_abs_line then
		return
	end
	last_cur_abs_line = cur_abs_line

	local bottom_rel_line = vim.api.nvim_win_get_height(0)

	-- the cursor's line number from the top of the window.
	local cur_rel_line = fn.winline()

	local bottom_lines_remain = bottom_rel_line - cur_rel_line
	local top_lines_remain = cur_rel_line - 1

	local scrolloff = vim.g.super_scrolloff

	-- set cursor position depending of the current window view
	local new_cursor_rel_line = nil
	if scrolloff > (bottom_rel_line / 2) then
		-- keep the cursor to the middle
		new_cursor_rel_line = math.floor(bottom_rel_line / 2) 
	elseif top_lines_remain < scrolloff then
		-- keep the cursor to the top
		new_cursor_rel_line = scrolloff + 1
	elseif bottom_lines_remain < scrolloff then
		-- keep the cursor to the bottom
		new_cursor_rel_line = bottom_rel_line - scrolloff
	end

	if new_cursor_rel_line == nil then
		return
	end

	-- how many you want to move UP the cursor
	local move_offset = cur_rel_line - new_cursor_rel_line
	-- when the cursor is moved, the window should be moved.
	-- when the window is scrolled, the cursor should be moved.
	if evt_type == TYPE_CURSOR then
		-- keep the cursor's absolute lnum, move the entire window
		-- you can move the entire window up by increasing win_data.topline
		-- and move the window down by decreasing it.
		--print(last_lnum .. " old: " .. cur_rel_line .. " new: " .. new_cursor_rel_line .. " off: " .. topline_offset)
		local new_topline = fn.winsaveview().topline + move_offset
		if new_topline < 1 then
			return
		end
		fn.winrestview({ topline = new_topline })
	elseif evt_type == TYPE_SCROLL then
		local new_cur_abs_line = cur_abs_line - move_offset
		if cur_abs_line <= scrolloff then
			-- do nothing around the top of file
			return
		end
		-- do nothing when the new cursor line is out of the file.
		if new_cursor_rel_line < 1 or new_cur_abs_line > fn.line("$") then
			return
		end
		fn.cursor(new_cur_abs_line, cur_abs_col)
	end
end

local group_id = vim.api.nvim_create_augroup("super_scrolloff", {})

vim.api.nvim_create_autocmd( {"CursorMoved", "CursorMovedI" }, { 
	group = group_id,
	callback = function() 
--		local begin = os.clock()
		on_move(TYPE_CURSOR)
--	local t_diff = os.clock() - begin
--	t_sum = t_sum + t_diff
--	t_cnt = t_cnt + 1
--	print(t_sum / t_cnt)
	end
})

vim.api.nvim_create_autocmd( "WinScrolled", { 
	group = group_id,
	callback = function()
		--local begin = os.clock()
		on_move(TYPE_SCROLL) 
	--local t_diff = os.clock() - begin
	--t_sum = t_sum + t_diff
	--t_cnt = t_cnt + 1
	--print(t_sum / t_cnt)
	end
})
