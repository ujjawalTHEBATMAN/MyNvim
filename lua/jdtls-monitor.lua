-- lua/jdtls-monitor.lua
-- Advanced JDTLS Memory & CPU Monitoring Module
-- Provides real-time resource tracking, alerts, and management for JDTLS

local M = {}

-- Configuration
local config = {
  -- Thresholds
  memory_warning_mb = 400,      -- Warn when JDTLS uses > 400MB
  memory_critical_mb = 480,     -- Critical alert at > 480MB (near 512MB limit)
  cpu_warning_percent = 80,     -- Warn when CPU > 80%
  
  -- Monitoring intervals
  update_interval_ms = 2000,    -- Update every 2 seconds
  history_max_entries = 60,     -- Keep last 60 readings (2 minutes of history)
  
  -- Display options
  show_in_statusline = true,    -- Show compact stats in statusline
  auto_open_on_warning = false, -- Auto-open monitor on warnings
  log_to_file = false,          -- Log history to file
  
  -- Log file path (if logging enabled)
  log_file_path = vim.fn.stdpath('state') .. '/jdtls-monitor.log',
}

-- State
local monitor_timer = nil
local jdtls_pid = nil
local stats_history = {}
local current_stats = nil
local warning_active = false
local monitor_buf = nil
local monitor_win = nil

--- Get JDTLS client and PID
local function get_jdtls_info()
  local clients = vim.lsp.get_clients({ name = 'jdtls' })
  if not clients or #clients == 0 then
    return nil, nil
  end
  
  local client = clients[1]
  local pid = client.rpc and client.rpc.pid or nil
  
  -- Alternative: try to find via process name if rpc.pid is nil
  if not pid then
    local handle = io.popen("pgrep -f 'jdtls.*java' 2>/dev/null | head -1")
    if handle then
      local result = handle:read("*a")
      handle:close()
      pid = result and tonumber(result:trim()) or nil
    end
  end
  
  return client, pid
end

--- Get process memory and CPU usage (Linux/Mac compatible)
local function get_process_stats(pid)
  if not pid then return nil end
  
  local stats = {
    pid = pid,
    memory_mb = 0,
    memory_percent = 0,
    cpu_percent = 0,
    state = 'unknown',
    timestamp = os.time(),
  }
  
  -- Try Linux /proc filesystem first (most accurate)
  local statm_file = string.format('/proc/%d/statm', pid)
  local status_file = string.format('/proc/%d/status', pid)
  
  local statm = io.open(statm_file, 'r')
  if statm then
    local content = statm:read('*all')
    statm:close()
    
    -- Parse statm: size resident shared text lib data dt (in pages)
    local pages = {}
    for num in content:gmatch('%S+') do
      table.insert(pages, tonumber(num))
    end
    
    if #pages >= 2 then
      local page_size_kb = vim.fn.getpagesize() / 1024
      stats.memory_mb = (pages[2] * page_size_kb) / 1024  -- Resident Set Size in MB
    end
  end
  
  -- Get more detailed info from status
  local status = io.open(status_file, 'r')
  if status then
    local content = status:read('*all')
    status:close()
    
    -- Extract VmRSS (Resident Set Size)
    local vmrss = content:match('VmRSS:%s*(%d+)')
    if vmrss then
      stats.memory_mb = tonumber(vmrss) / 1024  -- Convert KB to MB
    end
    
    -- Extract VmSize (Virtual Memory)
    local vmsize = content:match('VmSize:%s*(%d+)')
    if vmsize then
      stats.virtual_memory_mb = tonumber(vmsize) / 1024
    end
    
    -- Extract state
    stats.state = content:match('State:%s*(%w+)') or 'unknown'
  end
  
  -- Get CPU usage from /proc/[pid]/stat
  local stat_file = string.format('/proc/%d/stat', pid)
  local stat = io.open(stat_file, 'r')
  if stat then
    local content = stat:read('*all')
    stat:close()
    
    -- Parse stat file (fields separated by spaces, but comm can contain spaces)
    -- Format: pid (comm) state ppid ... utime stime cutime cstime ...
    local comm_end = content:match('%)([^)]*)$')
    if comm_end then
      local fields = {}
      for field in comm_end:gmatch('%S+') do
        table.insert(fields, field)
      end
      
      if #fields >= 12 then
        local utime = tonumber(fields[12]) or 0
        local stime = tonumber(fields[13]) or 0
        local total_time = utime + stime
        
        -- Calculate CPU percentage (simplified, needs two samples for accuracy)
        -- We'll store cumulative time and calculate delta in next call
        stats.total_cpu_time = total_time
      end
    end
  end
  
  -- Calculate CPU percentage using top (fallback method)
  local top_cmd = string.format("top -bn1 -p %d 2>/dev/null | grep '%d' | awk '{print $9}'", pid, pid)
  local handle = io.popen(top_cmd)
  if handle then
    local cpu = handle:read('*a')
    handle:close()
    if cpu and cpu:trim() ~= '' then
      stats.cpu_percent = tonumber(cpu:trim()) or 0
    end
  end
  
  -- Get memory percentage
  local mem_cmd = string.format("ps -o %%mem= -p %d 2>/dev/null", pid)
  handle = io.popen(mem_cmd)
  if handle then
    local mem_pct = handle:read('*a')
    handle:close()
    if mem_pct and mem_pct:trim() ~= '' then
      stats.memory_percent = tonumber(mem_pct:trim()) or 0
    end
  end
  
  return stats
end

--- Calculate CPU percentage with delta (more accurate)
local prev_cpu_time = nil
local prev_timestamp = nil

local function calculate_cpu_percentage(stats)
  if not stats or not stats.total_cpu_time then
    return stats.cpu_percent
  end
  
  local current_time = os.clock()
  
  if prev_cpu_time and prev_timestamp then
    local delta_time = stats.total_cpu_time - prev_cpu_time
    local delta_wall = current_time - prev_timestamp
    
    if delta_wall > 0 then
      -- CPU percentage = (delta CPU time / delta wall time) * 100
      -- Note: This is per-core percentage, can exceed 100% for multi-threaded
      local cpu_pct = (delta_time / delta_wall) * 100
      stats.cpu_percent = math.min(cpu_pct, 100)  -- Cap at 100% for display
    end
  end
  
  prev_cpu_time = stats.total_cpu_time
  prev_timestamp = current_time
  
  return stats.cpu_percent
end

--- Check thresholds and trigger warnings
local function check_thresholds(stats)
  if not stats then return end
  
  local new_warning = false
  local messages = {}
  
  if stats.memory_mb >= config.memory_critical_mb then
    table.insert(messages, string.format('🔴 CRITICAL: JDTLS using %.0fMB (%.1f%%)', 
      stats.memory_mb, stats.memory_percent))
    new_warning = true
  elseif stats.memory_mb >= config.memory_warning_mb then
    table.insert(messages, string.format('🟡 WARNING: JDTLS using %.0fMB (%.1f%%)', 
      stats.memory_mb, stats.memory_percent))
    new_warning = true
  end
  
  if stats.cpu_percent >= config.cpu_warning_percent then
    table.insert(messages, string.format('⚠️ HIGH CPU: JDTLS at %.1f%%', stats.cpu_percent))
    new_warning = true
  end
  
  -- Trigger notification if new warning or warning state changed
  if new_warning and not warning_active then
    vim.notify(table.concat(messages, '\n'), vim.log.levels.WARN, { title = 'JDTLS Monitor' })
    warning_active = true
    
    if config.auto_open_on_warning then
      M.toggle_monitor()
    end
  elseif not new_warning and warning_active then
    warning_active = false
  end
  
  -- Log to file if enabled
  if config.log_to_file then
    M.log_stats(stats)
  end
end

--- Add stats to history
local function add_to_history(stats)
  table.insert(stats_history, stats)
  
  -- Trim history if too long
  if #stats_history > config.history_max_entries then
    table.remove(stats_history, 1)
  end
end

--- Log stats to file
function M.log_stats(stats)
  local log_file = io.open(config.log_file_path, 'a')
  if not log_file then return end
  
  local timestamp = os.date('%Y-%m-%d %H:%M:%S', stats.timestamp)
  local line = string.format('[%s] PID=%d MEM=%.1fMB (%.1f%%) CPU=%.1f%% STATE=%s\n',
    timestamp, stats.pid, stats.memory_mb, stats.memory_percent, 
    stats.cpu_percent, stats.state)
  
  log_file:write(line)
  log_file:close()
end

--- Update monitor display
local function update_monitor()
  local client, pid = get_jdtls_info()
  
  if not pid then
    jdtls_pid = nil
    current_stats = nil
    return
  end
  
  jdtls_pid = pid
  
  local stats = get_process_stats(pid)
  if not stats then return end
  
  calculate_cpu_percentage(stats)
  current_stats = stats
  
  add_to_history(stats)
  check_thresholds(stats)
  
  -- Update floating window if open
  if monitor_win and vim.api.nvim_win_is_valid(monitor_win) then
    M.render_monitor()
  end
end

--- Render monitor content
function M.render_monitor()
  if not monitor_buf or not vim.api.nvim_buf_is_valid(monitor_buf) then return end
  
  local lines = {}
  
  -- Header
  table.insert(lines, '╔══════════════════════════════════════════════════╗')
  table.insert(lines, '║         📊 JDTLS Resource Monitor                ║')
  table.insert(lines, '╠══════════════════════════════════════════════════╣')
  
  if not current_stats then
    table.insert(lines, '║  No JDTLS process detected                         ║')
    table.insert(lines, '╚══════════════════════════════════════════════════╝')
  else
    local stats = current_stats
    
    -- Status indicator
    local status_icon = '🟢'
    local status_text = 'Healthy'
    
    if stats.memory_mb >= config.memory_critical_mb then
      status_icon = '🔴'
      status_text = 'Critical'
    elseif stats.memory_mb >= config.memory_warning_mb then
      status_icon = '🟡'
      status_text = 'Warning'
    elseif stats.cpu_percent >= config.cpu_warning_percent then
      status_icon = '🟠'
      status_text = 'High CPU'
    end
    
    table.insert(lines, string.format('║  Status: %-45s ║', status_icon .. ' ' .. status_text))
    table.insert(lines, '╠══════════════════════════════════════════════════╣')
    
    -- Process info
    table.insert(lines, string.format('║  PID: %-50d ║', stats.pid))
    table.insert(lines, string.format('║  State: %-48s ║', stats.state))
    table.insert(lines, '╠══════════════════════════════════════════════════╣')
    
    -- Memory section
    table.insert(lines, '║  📦 MEMORY                                          ║')
    table.insert(lines, string.format('║     RSS: %-47.1f MB ║', stats.memory_mb))
    table.insert(lines, string.format('║     Virtual: %-44.1f MB ║', stats.virtual_memory_mb or 0))
    table.insert(lines, string.format('║     System: %-46.1f %% ║', stats.memory_percent))
    
    -- Memory bar visualization
    local bar_width = 40
    local fill_count = math.floor((stats.memory_mb / config.memory_critical_mb) * bar_width)
    fill_count = math.min(fill_count, bar_width)
    local empty_count = bar_width - fill_count
    local bar = '[' .. string.rep('█', fill_count) .. string.rep('░', empty_count) .. ']'
    table.insert(lines, string.format('║     %s %6.1f%% ║', bar, (stats.memory_mb / config.memory_critical_mb) * 100))
    
    table.insert(lines, '╠══════════════════════════════════════════════════╣')
    
    -- CPU section
    table.insert(lines, '║  ⚡ CPU                                             ║')
    table.insert(lines, string.format('║     Usage: %-46.1f %% ║', stats.cpu_percent))
    
    -- CPU bar visualization
    local cpu_fill = math.floor((stats.cpu_percent / 100) * bar_width)
    cpu_fill = math.min(cpu_fill, bar_width)
    local cpu_empty = bar_width - cpu_fill
    local cpu_bar = '[' .. string.rep('█', cpu_fill) .. string.rep('░', cpu_empty) .. ']'
    table.insert(lines, string.format('║     %s %6.1f%% ║', cpu_bar, stats.cpu_percent))
    
    table.insert(lines, '╠══════════════════════════════════════════════════╣')
    
    -- History sparkline (last 10 entries)
    table.insert(lines, '║  📈 Memory Trend (last 10 readings)               ║')
    local history_start = math.max(1, #stats_history - 9)
    local recent_history = {}
    for i = history_start, #stats_history do
      table.insert(recent_history, stats_history[i])
    end
    
    local sparkline = '║     '
    for _, h in ipairs(recent_history) do
      local level = math.floor((h.memory_mb / config.memory_critical_mb) * 8)
      level = math.max(0, math.min(8, level))
      local chars = {'_', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'}
      sparkline = sparkline .. chars[level + 1]
    end
    table.insert(lines, sparkline .. '                          ║')
    
    table.insert(lines, '╠══════════════════════════════════════════════════╣')
    
    -- Timestamp
    table.insert(lines, string.format('║  Last updated: %-41s ║', os.date('%H:%M:%S')))
    table.insert(lines, '╚══════════════════════════════════════════════════╝')
  end
  
  -- Add help section
  table.insert(lines, '')
  table.insert(lines, 'Commands:')
  table.insert(lines, '  <q> - Close monitor')
  table.insert(lines, '  <r> - Restart JDTLS')
  table.insert(lines, '  <l> - Toggle logging')
  table.insert(lines, '  <h> - Show history')
  
  -- Clear buffer and set new content
  vim.api.nvim_buf_set_lines(monitor_buf, 0, -1, false, lines)
  
  -- Set highlights
  M.set_highlights()
end

--- Set syntax highlights for monitor
function M.set_highlights()
  if not monitor_buf or not vim.api.nvim_buf_is_valid(monitor_buf) then return end
  
  -- Define highlight groups if not exist
  local highlights = {
    JdtlsMonitorHeader = { fg = '#8be9fd', bold = true },  -- Cyan
    JdtlsMonitorStatusGood = { fg = '#50fa7b' },            -- Green
    JdtlsMonitorStatusWarn = { fg = '#f1fa8c' },            -- Yellow
    JdtlsMonitorStatusCrit = { fg = '#ff5555' },            -- Red
    JdtlsMonitorLabel = { fg = '#bd93f9' },                 -- Purple
    JdtlsMonitorValue = { fg = '#ffb86c' },                 -- Orange
    JdtlsMonitorBar = { fg = '#8be9fd' },                   -- Cyan
  end
  
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
  
  -- Apply highlights to buffer
  local ns_id = vim.api.nvim_create_namespace('jdtls_monitor')
  vim.api.nvim_buf_clear_namespace(monitor_buf, ns_id, 0, -1)
  
  local lines = vim.api.nvim_buf_get_lines(monitor_buf, 0, -1, false)
  
  for line_num, line in ipairs(lines) do
    local ln = line_num - 1  -- 0-indexed
    
    -- Header
    if line:match('JDTLS Resource Monitor') then
      vim.api.nvim_buf_add_highlight(monitor_buf, ns_id, 'JdtlsMonitorHeader', ln, 0, -1)
    end
    
    -- Status indicators
    if line:match('🟢') then
      local start_idx = line:find('🟢')
      if start_idx then
        vim.api.nvim_buf_add_highlight(monitor_buf, ns_id, 'JdtlsMonitorStatusGood', ln, start_idx - 1, start_idx + 1)
      end
    elseif line:match('🟡') then
      local start_idx = line:find('🟡')
      if start_idx then
        vim.api.nvim_buf_add_highlight(monitor_buf, ns_id, 'JdtlsMonitorStatusWarn', ln, start_idx - 1, start_idx + 1)
      end
    elseif line:match('🔴') then
      local start_idx = line:find('🔴')
      if start_idx then
        vim.api.nvim_buf_add_highlight(monitor_buf, ns_id, 'JdtlsMonitorStatusCrit', ln, start_idx - 1, start_idx + 1)
      end
    end
    
    -- Labels
    if line:match('MEMORY') or line:match('CPU') or line:match('PID:') or line:match('State:') then
      vim.api.nvim_buf_add_highlight(monitor_buf, ns_id, 'JdtlsMonitorLabel', ln, 0, -1)
    end
    
    -- Values (numbers)
    for match in line:gmatch('%d+%.?%d*') do
      local start_idx, end_idx = line:find(match, 1, true)
      if start_idx and not line:match('PID:') then
        vim.api.nvim_buf_add_highlight(monitor_buf, ns_id, 'JdtlsMonitorValue', ln, start_idx - 1, end_idx)
      end
    end
  end
end

--- Open floating monitor window
function M.open_monitor()
  -- Close if already open
  if monitor_win and vim.api.nvim_win_is_valid(monitor_win) then
    return
  end
  
  -- Create buffer
  monitor_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(monitor_buf, 'jdtls_monitor')
  vim.api.nvim_buf_set_option(monitor_buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(monitor_buf, 'bufhidden', 'hide')
  vim.api.nvim_buf_set_option(monitor_buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(monitor_buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(monitor_buf, 'filetype', 'jdtls_monitor')
  
  -- Calculate window dimensions
  local width = 60
  local height = 28
  local total_width = vim.o.columns
  local total_height = vim.o.lines
  
  local row = math.floor((total_height - height) / 2)
  local col = math.floor((total_width - width) / 2)
  
  -- Create window
  monitor_win = vim.api.nvim_open_win(monitor_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'none',  -- We draw our own border
    title = 'JDTLS Monitor',
    title_pos = 'center',
  })
  
  -- Set up keymaps for the monitor
  local map = function(keys, callback, desc)
    vim.keymap.set('n', keys, callback, { buffer = monitor_buf, desc = desc })
  end
  
  map('q', M.close_monitor, 'Close monitor')
  map('<Esc>', M.close_monitor, 'Close monitor')
  map('r', M.restart_jdtls, 'Restart JDTLS')
  map('l', M.toggle_logging, 'Toggle logging')
  map('h', M.show_history, 'Show history')
  map('<C-r>', M.refresh_now, 'Refresh now')
  
  -- Initial render
  M.render_monitor()
  
  vim.notify('JDTLS Monitor opened. Press <q> to close.', vim.log.levels.INFO, { title = 'JDTLS Monitor' })
end

--- Close monitor window
function M.close_monitor()
  if monitor_win and vim.api.nvim_win_is_valid(monitor_win) then
    vim.api.nvim_win_close(monitor_win, true)
    monitor_win = nil
  end
  
  if monitor_buf and vim.api.nvim_buf_is_valid(monitor_buf) then
    vim.api.nvim_buf_delete(monitor_buf, { force = true })
    monitor_buf = nil
  end
end

--- Toggle monitor window
function M.toggle_monitor()
  if monitor_win and vim.api.nvim_win_is_valid(monitor_win) then
    M.close_monitor()
  else
    M.open_monitor()
  end
end

--- Restart JDTLS
function M.restart_jdtls()
  vim.confirm('Are you sure you want to restart JDTLS? This may interrupt LSP features.', 
    function(choice)
      if choice ~= 1 then return end
      
      local clients = vim.lsp.get_clients({ name = 'jdtls' })
      if #clients == 0 then
        vim.notify('No JDTLS client found', vim.log.levels.WARN, { title = 'JDTLS Monitor' })
        return
      end
      
      -- Stop all JDTLS clients
      for _, client in ipairs(clients) do
        client.stop(true)
      end
      
      vim.notify('JDTLS stopped. It will restart automatically when you open a Java file.', 
        vim.log.levels.INFO, { title = 'JDTLS Monitor' })
      
      -- Close monitor
      M.close_monitor()
    end,
    0  -- No default choice
  )
end

--- Toggle logging
function M.toggle_logging()
  config.log_to_file = not config.log_to_file
  local status = config.log_to_file and 'enabled' or 'disabled'
  vim.notify('JDTLS monitoring logging ' .. status .. ': ' .. config.log_file_path, 
    vim.log.levels.INFO, { title = 'JDTLS Monitor' })
end

--- Show history
function M.show_history()
  if #stats_history == 0 then
    vim.notify('No history available yet', vim.log.levels.INFO, { title = 'JDTLS Monitor' })
    return
  end
  
  local lines = { 'Memory History (last ' .. #stats_history .. ' readings):' }
  
  for i, stats in ipairs(stats_history) do
    local time_str = os.date('%H:%M:%S', stats.timestamp)
    local mem_str = string.format('%.1f MB', stats.memory_mb)
    local cpu_str = string.format('%.1f%%', stats.cpu_percent)
    table.insert(lines, string.format('  [%s] Mem: %s  CPU: %s', time_str, mem_str, cpu_str))
  end
  
  -- Show in a floating window or quickfix
  vim.api.nvim_echo({}, false, {})
  for _, line in ipairs(lines) do
    print(line)
  end
end

--- Refresh stats immediately
function M.refresh_now()
  update_monitor()
  if monitor_win and vim.api.nvim_win_is_valid(monitor_win) then
    M.render_monitor()
  end
  vim.notify('Stats refreshed', vim.log.levels.INFO, { title = 'JDTLS Monitor' })
end

--- Get compact statusline component
function M.get_statusline_component()
  if not config.show_in_statusline then return '' end
  if not current_stats then return '' end
  
  local stats = current_stats
  local icon = '☕'
  
  if stats.memory_mb >= config.memory_critical_mb then
    icon = '🔴'
  elseif stats.memory_mb >= config.memory_warning_mb then
    icon = '🟡'
  elseif stats.cpu_percent >= config.cpu_warning_percent then
    icon = '🟠'
  end
  
  return string.format('%s %.0fMB|%.0f%%', icon, stats.memory_mb, stats.cpu_percent)
end

--- Start monitoring timer
function M.start_monitoring()
  if monitor_timer then
    vim.fn.timer_stop(monitor_timer)
  end
  
  monitor_timer = vim.fn.timer_start(config.update_interval_ms, function()
    update_monitor()
  end, { ['repeat'] = -1 })
  
  vim.notify('JDTLS monitoring started', vim.log.levels.INFO, { title = 'JDTLS Monitor' })
end

--- Stop monitoring timer
function M.stop_monitoring()
  if monitor_timer then
    vim.fn.timer_stop(monitor_timer)
    monitor_timer = nil
    vim.notify('JDTLS monitoring stopped', vim.log.levels.INFO, { title = 'JDTLS Monitor' })
  end
end

--- Setup function
function M.setup(opts)
  -- Merge user config with defaults
  config = vim.tbl_deep_extend('force', config, opts or {})
  
  -- Start monitoring
  M.start_monitoring()
  
  -- Create user commands
  vim.api.nvim_create_user_command('JdtlsMonitor', function()
    M.toggle_monitor()
  end, { desc = 'Toggle JDTLS resource monitor', nargs = 0 })
  
  vim.api.nvim_create_user_command('JdtlsMonitorOpen', function()
    M.open_monitor()
  end, { desc = 'Open JDTLS resource monitor', nargs = 0 })
  
  vim.api.nvim_create_user_command('JdtlsMonitorClose', function()
    M.close_monitor()
  end, { desc = 'Close JDTLS resource monitor', nargs = 0 })
  
  vim.api.nvim_create_user_command('JdtlsMonitorRefresh', function()
    M.refresh_now()
  end, { desc = 'Refresh JDTLS stats', nargs = 0 })
  
  vim.api.nvim_create_user_command('JdtlsMonitorRestart', function()
    M.restart_jdtls()
  end, { desc = 'Restart JDTLS server', nargs = 0 })
  
  vim.api.nvim_create_user_command('JdtlsMonitorLog', function(args)
    if args.args == 'toggle' then
      M.toggle_logging()
    elseif args.args == 'on' then
      config.log_to_file = true
      vim.notify('Logging enabled', vim.log.levels.INFO, { title = 'JDTLS Monitor' })
    elseif args.args == 'off' then
      config.log_to_file = false
      vim.notify('Logging disabled', vim.log.levels.INFO, { title = 'JDTLS Monitor' })
    else
      vim.notify('Usage: :JdtlsMonitorLog [toggle|on|off]', vim.log.levels.ERROR, { title = 'JDTLS Monitor' })
    end
  end, { desc = 'Toggle JDTLS monitoring logging', nargs = '?', complete = function() return {'toggle', 'on', 'off'} end })
  
  vim.api.nvim_create_user_command('JdtlsMonitorHistory', function()
    M.show_history()
  end, { desc = 'Show JDTLS monitoring history', nargs = 0 })
  
  -- Integration with java.lua: auto-start when JDTLS attaches
  vim.api.nvim_create_autocmd('LspAttach', {
    pattern = '*.java',
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == 'jdtls' then
        -- Ensure monitoring is running
        if not monitor_timer then
          M.start_monitoring()
        end
      end
    end,
  })
  
  -- Cleanup on exit
  vim.api.nvim_create_autocmd('VimLeavePre', {
    callback = function()
      M.stop_monitoring()
    end,
  })
  
  vim.notify('JDTLS Monitor loaded. Use :JdtlsMonitor to toggle view.', vim.log.levels.INFO, { title = 'JDTLS Monitor' })
end

return M
