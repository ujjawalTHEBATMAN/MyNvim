-- lua/java-config.lua
-- Java Project Configuration, Building & Running

local M = {}

-- Find the main class in current project
M.find_main_class = function()
	local mains = {}
	
	-- Search for files with public static void main
	local files = vim.fn.systemlist('grep -r -l "public static void main" --include="*.java" . 2>/dev/null')
	
	if #files == 0 then
		-- Try Gradle/Maven structure
		files = vim.fn.systemlist('find . -path "*/src/main/java/*.java" -type f 2>/dev/null | head -20')
		for _, file in ipairs(files) do
			local content = vim.fn.readfile(file)
			for _, line in ipairs(content) do
				if line:match("public static void main") then
					table.insert(mains, file)
					break
				end
			end
		end
	else
		mains = files
	end
	
	if #mains == 0 then
		vim.notify("❌ No main class found!", vim.log.levels.ERROR)
		return nil
	end
	
	if #mains == 1 then
		return mains[1]
	end
	
	-- Multiple mains found, let user pick
	local items = {}
	for _, main in ipairs(mains) do
		-- Convert file path to class name
		local class = main:gsub("%.java$", ""):gsub(".*/src/main/java/", ""):gsub(".*/src/test/java/", ""):gsub("/", ".")
		table.insert(items, class .. " (" .. main .. ")")
	end
	
	vim.ui.select(items, { prompt = "Select main class:" }, function(choice)
		if choice then
			local file = choice:match("%((.+)%)")
			M.run_specific_main(file)
		end
	end)
	
	return nil
end

-- Get project type (maven, gradle, or simple)
M.get_project_type = function()
	if vim.fn.filereadable("pom.xml") == 1 then return "maven" end
	if vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then return "gradle" end
	return "simple"
end

-- Build project
M.build_project = function(callback)
	local type = M.get_project_type()
	local cmd
	
	if type == "maven" then
		cmd = "mvn clean compile"
	elseif type == "gradle" then
		cmd = "./gradlew build -x test"
	else
		vim.notify("Simple Java project - no build needed", vim.log.levels.INFO)
		if callback then callback() end
		return
	end
	
	vim.notify("🔨 Building project...", vim.log.levels.INFO)
	
	local output = {}
	local job_id = vim.fn.jobstart(cmd, {
		on_stdout = function(_, data) 
			for _, line in ipairs(data) do 
				if line ~= "" then table.insert(output, line) end 
			end 
		end,
		on_stderr = function(_, data) 
			for _, line in ipairs(data) do 
				if line ~= "" then table.insert(output, line) end 
			end 
		end,
		on_exit = function(_, code)
			if code == 0 then
				vim.notify("✅ Build successful!", vim.log.levels.INFO)
				if callback then callback() end
			else
				vim.notify("❌ Build failed! Check output.", vim.log.levels.ERROR)
				-- Show error output in quickfix or floating window
				M.show_output(output, "Build Output")
			end
		end,
	})
	
	if job_id <= 0 then
		vim.notify("Failed to start build job", vim.log.levels.ERROR)
	end
end

-- Run main class in floating terminal
M.run_main_floating = function()
	local type = M.get_project_type()
	
	if type == "maven" then
		M.run_maven()
	elseif type == "gradle" then
		M.run_gradle()
	else
		M.run_simple_java()
	end
end

-- Run with Maven
M.run_maven = function()
	local cmd = "mvn exec:java -q"
	
	if vim.fn.filereadable("pom.xml") == 1 then
		-- Check if exec plugin is configured, otherwise use spring boot or direct java
		local pom = table.concat(vim.fn.readfile("pom.xml"), "\n")
		if not pom:match("exec%-maven%-plugin") then
			-- Try to find main class and run manually
			local main_class = M.guess_main_class()
			if main_class then
				cmd = "mvn compile exec:java -Dexec.mainClass=" .. main_class
			else
				cmd = "mvn spring-boot:run"
			end
		end
	end
	
	M.open_floating_terminal(cmd, "Maven Run")
end

-- Run with Gradle
M.run_gradle = function()
	local cmd = "./gradlew run"
	
	-- Check if application plugin is applied
	if vim.fn.filereadable("build.gradle") == 1 then
		local build = table.concat(vim.fn.readfile("build.gradle"), "\n")
		if not build:match("application") then
			local main_class = M.guess_main_class()
			if main_class then
				cmd = "./gradlew compileJava && java -cp build/classes/java/main " .. main_class
			end
		end
	end
	
	M.open_floating_terminal(cmd, "Gradle Run")
end

-- Run simple Java file
M.run_simple_java = function()
	local file = vim.fn.expand("%:p")
	local dir = vim.fn.expand("%:p:h")
	local classname = vim.fn.expand("%:t:r")
	
	local cmd = string.format("cd %s && javac %s.java && java %s", dir, classname, classname)
	M.open_floating_terminal(cmd, "Java Run")
end

-- Guess main class from current file or project
M.guess_main_class = function()
	local current = vim.fn.expand("%:.")
	current = current:gsub("src/main/java/", ""):gsub("src/test/java/", ""):gsub("/", "."):gsub("%.java$", "")
	
	-- Verify it has main method
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	for _, line in ipairs(lines) do
		if line:match("public static void main") then
			return current
		end
	end
	
	-- Try to find any main class
	local mains = vim.fn.systemlist('grep -r "public static void main" --include="*.java" . -l 2>/dev/null')
	if #mains > 0 then
		local main = mains[1]:gsub("%.java$", ""):gsub(".*/src/main/java/", ""):gsub(".*/src/test/java/", ""):gsub("/", ".")
		return main
	end
	
	return nil
end

-- Open floating terminal with command
M.open_floating_terminal = function(cmd, title)
	title = title or "Terminal"
	
	-- Calculate window size
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.7)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	
	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
	
	-- Set buffer name
	vim.api.nvim_buf_set_name(buf, title .. " Output")
	
	-- Create window
	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " " .. title .. " ",
		title_pos = "center",
	}
	
	local win = vim.api.nvim_open_win(buf, true, win_opts)
	vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal,FloatBorder:FloatBorder")
	
	-- Start terminal
	vim.fn.termopen(cmd, {
		on_exit = function(_, exit_code)
			-- Only write to buffer if it still exists and is modifiable (terminal may have made it non-modifiable)
			if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modifiable then
				local msg = exit_code == 0 and "[Process exited with code 0]" or ("[Process exited with code " .. exit_code .. "]")
				pcall(vim.api.nvim_buf_set_lines, buf, -1, -1, false, { "", msg })
			end
		end,
	})
	
	vim.cmd("startinsert")
	
	-- Keymaps for the terminal
	local opts = { buffer = buf, silent = true }
	vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
	vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, opts)
	vim.keymap.set("n", "<leader>rr", function() vim.api.nvim_win_close(win, true) end, opts)
end

-- Show output in floating window
M.show_output = function(lines, title)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.7)
	
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " " .. title .. " ",
		title_pos = "center",
	}
	
	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

-- Attach function for LSP
M.on_attach = function(client, bufnr)
	-- Java specific keymaps
	local map = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end
	
	map("<leader>jr", M.run_main_floating, "☕ Run Main")
	map("<leader>jb", function() M.build_project() end, "🔨 Build Project")
	map("<leader>jB", function() M.build_project(M.run_main_floating) end, "🔨 Build & Run")
	
	-- LSP based run (if DAP is available)
	map("<leader>jd", function() 
		vim.notify("Start debugger with <leader>dc", vim.log.levels.INFO) 
	end, "Debug Info")
	
	-- Test running
	map("<leader>jt", "<cmd>!mvn test<cr>", "Run Tests (Maven)")
	map("<leader>jT", "<cmd>!./gradlew test<cr>", "Run Tests (Gradle)")
end

-- Run specific main file
M.run_specific_main = function(file)
	if not file then return end
	
	local type = M.get_project_type()
	if type == "maven" then
		-- Convert file path to class name
		local class = file:gsub("%.java$", ""):gsub(".*/src/main/java/", ""):gsub("/", ".")
		local cmd = "mvn compile exec:java -Dexec.mainClass=" .. class
		M.open_floating_terminal(cmd, "Maven Run")
	elseif type == "gradle" then
		M.open_floating_terminal("./gradlew run", "Gradle Run")
	else
		M.run_simple_java()
	end
end

return M
