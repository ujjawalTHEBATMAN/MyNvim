-- lua/java-runner.lua
-- IntelliJ-Style Java Runner for Neovim
-- Compiles to ./out directory, detects Maven/Gradle projects
-- Enhanced with TestNG/Spock framework detection

local M = {}

-- ============================================
-- CONFIGURATION
-- ============================================
M.config = {
	-- Output directory for compiled .class files (relative to project root)
	output_dir = "out",

	-- Alternative names (will use first that exists, or create output_dir)
	alt_output_dirs = { "bin", "build/classes" },

	-- Terminal settings
	terminal = {
		direction = "horizontal", -- horizontal, vertical, float
		size = 15, -- lines for horizontal, columns for vertical
		close_on_exit = false, -- keep terminal open after execution
	},

	-- Test framework detection
	test_frameworks = {
		auto_detect = true,        -- Auto-detect test framework from dependencies
		prefer_testng = false,     -- Prefer TestNG over JUnit if both present
		support_spock = true,      -- Enable Spock framework detection
	},
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

-- Find the project root by looking for common project markers
local function find_project_root()
	local markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".git", "src" }
	local current = vim.fn.expand("%:p:h")

	for _, marker in ipairs(markers) do
		local found = vim.fn.findfile(marker, current .. ";")
		if found ~= "" then
			return vim.fn.fnamemodify(found, ":p:h")
		end
		-- Also check for directories
		found = vim.fn.finddir(marker, current .. ";")
		if found ~= "" then
			return vim.fn.fnamemodify(found, ":p:h")
		end
	end

	return vim.fn.getcwd()
end

-- Check if a file exists (more reliable than vim.fn.filereadable for this)
local function file_exists(path)
	return vim.fn.filereadable(path) == 1
end

-- Check if a directory exists
local function dir_exists(path)
	return vim.fn.isdirectory(path) == 1
end

-- Detect project type
local function detect_project_type(root)
	-- Maven wrapper takes priority
	if file_exists(root .. "/mvnw") then
		return "maven_wrapper"
	elseif file_exists(root .. "/pom.xml") then
		return "maven"
	end

	-- Gradle wrapper takes priority
	if file_exists(root .. "/gradlew") then
		return "gradle_wrapper"
	elseif file_exists(root .. "/build.gradle") or file_exists(root .. "/build.gradle.kts") then
		return "gradle"
	end

	return "standalone"
end

-- Detect test framework from project dependencies
---@param root string Project root directory
---@return string framework: "junit5", "junit4", "testng", "spock", or "unknown"
local function detect_test_framework(root)
	local project_type = detect_project_type(root)
	
	-- Check Maven pom.xml
	if project_type == "maven" or project_type == "maven_wrapper" then
		local pom_path = root .. "/pom.xml"
		if file_exists(pom_path) then
			local pom_content = table.concat(vim.fn.readfile(pom_path), "\n"):lower()
			
			-- Check for Spock first (Groovy-based)
			if M.config.test_frameworks.support_spock then
				if pom_content:find("spock%-core") or pom_content:find("spock%-spring") then
					return "spock"
				end
			end
			
			-- Check for TestNG
			if pom_content:find("testng") then
				return "testng"
			end
			
			-- Check for JUnit 5 (Jupiter)
			if pom_content:find("junit%-jupiter") or pom_content:find("junit5") then
				return "junit5"
			end
			
			-- Check for JUnit 4
			if pom_content:find("junit") and not pom_content:find("jupiter") then
				return "junit4"
			end
		end
	end
	
	-- Check Gradle build files
	if project_type == "gradle" or project_type == "gradle_wrapper" then
		local gradle_path = file_exists(root .. "/build.gradle.kts") and root .. "/build.gradle.kts" 
			or root .. "/build.gradle"
		if file_exists(gradle_path) then
			local gradle_content = table.concat(vim.fn.readfile(gradle_path), "\n"):lower()
			
			-- Check for Spock first
			if M.config.test_frameworks.support_spock then
				if gradle_content:find("spock") then
					return "spock"
				end
			end
			
			-- Check for TestNG
			if gradle_content:find("testng") then
				return "testng"
			end
			
			-- Check for JUnit 5 (useJUnitPlatform or junit-jupiter)
			if gradle_content:find("usejunitplatform") or gradle_content:find("junit%-jupiter") or gradle_content:find("junit5") then
				return "junit5"
			end
			
			-- Check for JUnit 4
			if gradle_content:find("testimplementation.*junit") then
				return "junit4"
			end
		end
	end
	
	-- Default to JUnit 5 (modern standard)
	return "junit5"
end

-- Get the fully qualified class name from the file
local function get_class_name(filepath)
	local content = vim.fn.readfile(filepath)
	local package_name = nil
	local class_name = nil

	for _, line in ipairs(content) do
		-- Find package declaration
		if not package_name then
			local pkg = line:match("^%s*package%s+([%w%.]+)%s*;")
			if pkg then
				package_name = pkg
			end
		end

		-- Find public class/interface/enum declaration
		if not class_name then
			local cls = line:match("^%s*public%s+[%w%s]*class%s+(%w+)")
				or line:match("^%s*public%s+interface%s+(%w+)")
				or line:match("^%s*public%s+enum%s+(%w+)")
				or line:match("^%s*public%s+record%s+(%w+)")
			if cls then
				class_name = cls
			end
		end

		if package_name and class_name then
			break
		end
	end

	-- Fallback to filename if no public class found
	if not class_name then
		class_name = vim.fn.fnamemodify(filepath, ":t:r")
	end

	if package_name then
		return package_name .. "." .. class_name
	end
	return class_name
end

-- Get source root (src/main/java or src or current dir)
local function get_source_root(root, filepath)
	local file_dir = vim.fn.fnamemodify(filepath, ":p:h")

	-- Check for Maven/Gradle standard layout
	local src_main_java = root .. "/src/main/java"
	if dir_exists(src_main_java) and file_dir:find(src_main_java, 1, true) then
		return src_main_java
	end

	-- Check for simple src/ layout
	local src = root .. "/src"
	if dir_exists(src) and file_dir:find(src, 1, true) then
		return src
	end

	-- Fallback to project root
	return root
end

-- Ensure output directory exists
local function ensure_output_dir(root)
	local out_path = root .. "/" .. M.config.output_dir

	-- Check if any alternative exists first
	for _, alt in ipairs(M.config.alt_output_dirs) do
		local alt_path = root .. "/" .. alt
		if dir_exists(alt_path) then
			return alt_path
		end
	end

	-- Create the output directory if it doesn't exist
	if not dir_exists(out_path) then
		vim.fn.mkdir(out_path, "p")
		vim.notify("📁 Created output directory: " .. out_path, vim.log.levels.INFO)
	end

	return out_path
end

-- ============================================
-- TERMINAL EXECUTION (Floating Window)
-- ============================================

local function run_in_terminal(cmd, cwd, title)
	-- Use toggleterm if available with float mode
	local has_toggleterm, toggleterm = pcall(require, "toggleterm.terminal")

	if has_toggleterm then
		local Terminal = toggleterm.Terminal
		local term = Terminal:new({
			cmd = cmd,
			dir = cwd,
			direction = "float",
			close_on_exit = false,
			float_opts = {
				border = "rounded",
				width = math.floor(vim.o.columns * 0.8),
				height = math.floor(vim.o.lines * 0.7),
				winblend = 3,
				title_pos = "center",
			},
			on_open = function(t)
				vim.api.nvim_buf_set_name(t.bufnr, "[Java] " .. (title or "Run"))
				-- Press 'q' to close
				vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = t.bufnr, silent = true })
			end,
		})
		term:toggle()
	else
		-- Fallback: Create a centered floating window with native terminal
		local width = math.floor(vim.o.columns * 0.8)
		local height = math.floor(vim.o.lines * 0.7)
		local row = math.floor((vim.o.lines - height) / 2)
		local col = math.floor((vim.o.columns - width) / 2)

		-- Create buffer
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

		-- Create floating window
		local win = vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			width = width,
			height = height,
			row = row,
			col = col,
			style = "minimal",
			border = "rounded",
			title = " ☕ " .. (title or "Java Run") .. " ",
			title_pos = "center",
		})

		-- Set window options
		vim.api.nvim_win_set_option(win, "winblend", 0)

		-- Run terminal in the floating window
		vim.fn.termopen("cd " .. vim.fn.shellescape(cwd) .. " && " .. cmd, {
			on_exit = function()
				vim.api.nvim_buf_set_option(buf, "modifiable", false)
			end,
		})

		-- Start in terminal mode
		vim.cmd("startinsert")

		-- Press 'q' or 'Esc' to close the floating window
		vim.keymap.set("n", "q", function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end, { buffer = buf, silent = true })

		vim.keymap.set("n", "<Esc>", function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end, { buffer = buf, silent = true })
	end
end

-- ============================================
-- MAIN RUNNER FUNCTIONS
-- ============================================

-- Run Maven project
local function run_maven(root, use_wrapper)
	local mvn_cmd = use_wrapper and "./mvnw" or "mvn"

	-- Check if it's a Spring Boot project
	local pom_content = table.concat(vim.fn.readfile(root .. "/pom.xml"), "\n")
	local is_spring_boot = pom_content:find("spring%-boot") ~= nil

	local cmd
	if is_spring_boot then
		cmd = mvn_cmd .. " spring-boot:run -q"
		vim.notify("🍃 Spring Boot detected - running with spring-boot:run", vim.log.levels.INFO)
	else
		cmd = mvn_cmd .. " compile exec:java -q"
		vim.notify("📦 Maven project - running with exec:java", vim.log.levels.INFO)
	end

	run_in_terminal(cmd, root, "Maven Run")
end

-- Run Gradle project
local function run_gradle(root, use_wrapper)
	local gradle_cmd = use_wrapper and "./gradlew" or "gradle"

	-- Check if it's a Spring Boot project
	local gradle_file = file_exists(root .. "/build.gradle.kts") and root .. "/build.gradle.kts"
		or root .. "/build.gradle"
	local gradle_content = table.concat(vim.fn.readfile(gradle_file), "\n")
	local is_spring_boot = gradle_content:find("spring%-boot") ~= nil or gradle_content:find("org.springframework.boot")

	local cmd
	if is_spring_boot then
		cmd = gradle_cmd .. " bootRun -q"
		vim.notify("🍃 Spring Boot detected - running with bootRun", vim.log.levels.INFO)
	else
		cmd = gradle_cmd .. " run -q"
		vim.notify("📦 Gradle project - running with 'run' task", vim.log.levels.INFO)
	end

	run_in_terminal(cmd, root, "Gradle Run")
end

-- Run tests with detected framework (JUnit/TestNG/Spock)
local function run_tests(root, use_wrapper, project_type)
	local test_framework = detect_test_framework(root)
	local cmd
	
	if project_type == "maven" or project_type == "maven_wrapper" then
		local mvn_cmd = use_wrapper and "./mvnw" or "mvn"
		
		if test_framework == "testng" then
			cmd = mvn_cmd .. " test -Dsurefire.provider=surefire -Dsurefire.useFile=false -Dtestng.thread.count=4"
			vim.notify("🧪 TestNG detected - running Maven tests with TestNG", vim.log.levels.INFO)
		elseif test_framework == "spock" then
			cmd = mvn_cmd .. " test -Dsurefire.includes='**/*Spec.java'"
			vim.notify("🐘 Spock detected - running Maven tests with Spock", vim.log.levels.INFO)
		else
			-- JUnit 4 or 5
			cmd = mvn_cmd .. " test -q"
			vim.notify(string.format("🧪 %s detected - running Maven tests", test_framework == "junit5" and "JUnit 5" or "JUnit 4"), vim.log.levels.INFO)
		end
		
	elseif project_type == "gradle" or project_type == "gradle_wrapper" then
		local gradle_cmd = use_wrapper and "./gradlew" or "gradle"
		
		if test_framework == "testng" then
			cmd = gradle_cmd .. " test -Dtestng.thread.count=4 --info"
			vim.notify("🧪 TestNG detected - running Gradle tests with TestNG", vim.log.levels.INFO)
		elseif test_framework == "spock" then
			cmd = gradle_cmd .. " test --tests '*Spec' --info"
			vim.notify("🐘 Spock detected - running Gradle tests with Spock", vim.log.levels.INFO)
		else
			-- JUnit 4 or 5
			cmd = gradle_cmd .. " test --info"
			vim.notify(string.format("🧪 %s detected - running Gradle tests", test_framework == "junit5" and "JUnit 5" or "JUnit 4"), vim.log.levels.INFO)
		end
	end
	
	if cmd then
		run_in_terminal(cmd, root, "Test Run (" .. test_framework .. ")")
	end
end

-- Run standalone Java file (IntelliJ-style with out/ directory)
local function run_standalone(root, filepath)
	local out_dir = ensure_output_dir(root)
	local src_root = get_source_root(root, filepath)
	local class_name = get_class_name(filepath)

	-- Build the compile command
	-- Use -d to specify output directory, -sourcepath for source lookup
	local compile_cmd = string.format(
		"javac -d %s -sourcepath %s %s",
		vim.fn.shellescape(out_dir),
		vim.fn.shellescape(src_root),
		vim.fn.shellescape(filepath)
	)

	-- Build the run command with proper classpath
	local run_cmd = string.format("java -cp %s %s", vim.fn.shellescape(out_dir), class_name)

	-- Combined command with error handling (single line to avoid escape issues)
	local full_cmd = string.format(
		'echo "☕ Compiling: %s" && %s && echo "▶️  Running: %s" && echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" && %s; echo ""; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo "✅ Execution finished"',
		vim.fn.fnamemodify(filepath, ":t"),
		compile_cmd,
		class_name,
		run_cmd
	)

	vim.notify(
		string.format("☕ Compiling to: %s\n▶️  Class: %s", M.config.output_dir, class_name),
		vim.log.levels.INFO
	)

	run_in_terminal(full_cmd, root, class_name)
end

-- ============================================
-- PUBLIC API
-- ============================================

-- Main run function
function M.run()
	local filepath = vim.fn.expand("%:p")

	-- Ensure we're in a Java file
	if vim.bo.filetype ~= "java" then
		vim.notify("❌ Not a Java file!", vim.log.levels.ERROR)
		return
	end

	-- Save the file first
	if vim.bo.modified then
		vim.cmd("write")
	end

	local root = find_project_root()
	local project_type = detect_project_type(root)

	vim.notify(string.format("📍 Project root: %s\n📦 Type: %s", root, project_type), vim.log.levels.DEBUG)

	if project_type == "maven_wrapper" then
		run_maven(root, true)
	elseif project_type == "maven" then
		run_maven(root, false)
	elseif project_type == "gradle_wrapper" then
		run_gradle(root, true)
	elseif project_type == "gradle" then
		run_gradle(root, false)
	else
		run_standalone(root, filepath)
	end
end

-- Compile only (without running)
function M.compile()
	local filepath = vim.fn.expand("%:p")

	if vim.bo.filetype ~= "java" then
		vim.notify("❌ Not a Java file!", vim.log.levels.ERROR)
		return
	end

	if vim.bo.modified then
		vim.cmd("write")
	end

	local root = find_project_root()
	local project_type = detect_project_type(root)

	if project_type == "maven_wrapper" or project_type == "maven" then
		local mvn = project_type == "maven_wrapper" and "./mvnw" or "mvn"
		run_in_terminal(mvn .. " compile -q", root, "Maven Compile")
	elseif project_type == "gradle_wrapper" or project_type == "gradle" then
		local gradle = project_type == "gradle_wrapper" and "./gradlew" or "gradle"
		run_in_terminal(gradle .. " compileJava -q", root, "Gradle Compile")
	else
		local out_dir = ensure_output_dir(root)
		local src_root = get_source_root(root, filepath)
		local compile_cmd = string.format(
			"javac -d %s -sourcepath %s %s && echo '✅ Compilation successful!'",
			vim.fn.shellescape(out_dir),
			vim.fn.shellescape(src_root),
			vim.fn.shellescape(filepath)
		)
		run_in_terminal(compile_cmd, root, "Compile")
	end
end

-- Clean output directory
function M.clean()
	local root = find_project_root()
	local project_type = detect_project_type(root)

	if project_type == "maven_wrapper" or project_type == "maven" then
		local mvn = project_type == "maven_wrapper" and "./mvnw" or "mvn"
		run_in_terminal(mvn .. " clean", root, "Maven Clean")
	elseif project_type == "gradle_wrapper" or project_type == "gradle" then
		local gradle = project_type == "gradle_wrapper" and "./gradlew" or "gradle"
		run_in_terminal(gradle .. " clean", root, "Gradle Clean")
	else
		local out_dir = root .. "/" .. M.config.output_dir
		if dir_exists(out_dir) then
			vim.fn.delete(out_dir, "rf")
			vim.notify("🗑️  Cleaned: " .. out_dir, vim.log.levels.INFO)
		else
			vim.notify("📁 No output directory to clean", vim.log.levels.INFO)
		end
	end
end

-- Show project info
function M.info()
	local filepath = vim.fn.expand("%:p")
	local root = find_project_root()
	local project_type = detect_project_type(root)
	local test_framework = detect_test_framework(root)
	local class_name = get_class_name(filepath)
	local src_root = get_source_root(root, filepath)

	local info = string.format(
		[[
☕ Java Project Info
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Project Root: %s
📦 Project Type: %s
🧪 Test Framework: %s
📂 Source Root:  %s
📄 Current File: %s
🏷️  Class Name:   %s
📁 Output Dir:   %s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━]],
		root,
		project_type,
		test_framework,
		src_root,
		vim.fn.fnamemodify(filepath, ":t"),
		class_name,
		M.config.output_dir
	)

	vim.notify(info, vim.log.levels.INFO)
end

-- Run tests with auto-detected framework
function M.test()
	local root = find_project_root()
	local project_type = detect_project_type(root)

	if project_type == "maven_wrapper" then
		run_tests(root, true, "maven")
	elseif project_type == "maven" then
		run_tests(root, false, "maven")
	elseif project_type == "gradle_wrapper" then
		run_tests(root, true, "gradle")
	elseif project_type == "gradle" then
		run_tests(root, false, "gradle")
	else
		vim.notify("❌ No test framework detected for standalone files", vim.log.levels.ERROR)
	end
end

-- Show detected test framework
function M.test_info()
	local root = find_project_root()
	local test_framework = detect_test_framework(root)
	
	local framework_names = {
		junit5 = "JUnit 5 (Jupiter)",
		junit4 = "JUnit 4",
		testng = "TestNG",
		spock = "Spock (Groovy)",
		unknown = "Unknown (defaulting to JUnit 5)"
	}
	
	local info = string.format(
		[[
🧪 Test Framework Detection
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Project Root: %s
🔍 Detected Framework: %s
📖 Full Name: %s

Framework-specific commands:
  :JavaTest        → Run all tests
  :JavaTestSingle  → Run single test class
  :JavaTestPackage → Run tests in package
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━]],
		root,
		test_framework,
		framework_names[test_framework] or framework_names.unknown
	)
	
	vim.notify(info, vim.log.levels.INFO)
end

-- ============================================
-- SETUP & KEYMAPS
-- ============================================

function M.setup(opts)
	if opts then
		M.config = vim.tbl_deep_extend("force", M.config, opts)
	end

	-- Create commands
	vim.api.nvim_create_user_command("JavaRun", function()
		M.run()
	end, { desc = "Run Java file (IntelliJ-style)" })

	vim.api.nvim_create_user_command("JavaCompile", function()
		M.compile()
	end, { desc = "Compile Java file" })

	vim.api.nvim_create_user_command("JavaClean", function()
		M.clean()
	end, { desc = "Clean output directory" })

	vim.api.nvim_create_user_command("JavaInfo", function()
		M.info()
	end, { desc = "Show Java project info" })

	vim.api.nvim_create_user_command("JavaTest", function()
		M.test()
	end, { desc = "🧪 Run tests (auto-detect JUnit/TestNG/Spock)" })

	vim.api.nvim_create_user_command("JavaTestInfo", function()
		M.test_info()
	end, { desc = "🧪 Show detected test framework" })

	-- Setup keymaps for Java files
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "java",
		callback = function(ev)
			local opts = { buffer = ev.buf, silent = true }
			vim.keymap.set("n", "<leader>jr", M.run, vim.tbl_extend("force", opts, { desc = "☕ Run Java" }))
			vim.keymap.set("n", "<leader>jb", M.compile, vim.tbl_extend("force", opts, { desc = "☕ Compile Java" }))
			vim.keymap.set("n", "<leader>jx", M.clean, vim.tbl_extend("force", opts, { desc = "☕ Clean Output" }))
			vim.keymap.set("n", "<leader>ji", M.info, vim.tbl_extend("force", opts, { desc = "☕ Project Info" }))
			vim.keymap.set("n", "<leader>jt", M.test, vim.tbl_extend("force", opts, { desc = "🧪 Run Tests" }))
			vim.keymap.set("n", "<leader>jti", M.test_info, vim.tbl_extend("force", opts, { desc = "🧪 Test Framework Info" }))

			-- Quick run with F5 (like most IDEs)
			vim.keymap.set("n", "<F5>", M.run, vim.tbl_extend("force", opts, { desc = "☕ Run Java" }))
			vim.keymap.set("n", "<F9>", M.compile, vim.tbl_extend("force", opts, { desc = "☕ Compile Java" }))
			vim.keymap.set("n", "<F10>", M.test, vim.tbl_extend("force", opts, { desc = "🧪 Run Tests" }))
		end,
	})
end

return M
