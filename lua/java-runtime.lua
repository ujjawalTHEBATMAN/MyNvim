-- lua/java-runtime.lua
-- Automatic Java Runtime Detection & Switching

local M = {}

-- Configuration: Installed Java versions (auto-detected from /usr/lib/jvm/)
M.java_runtimes = {
	["25"] = { name = "JavaSE-25", path = "/usr/lib/jvm/java-25-openjdk", default = true },
	["21"] = { name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk" },
	["17"] = { name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk" },
	["8"]  = { name = "JavaSE-1.8", path = "/usr/lib/jvm/java-8-openjdk" },
}

-- Detect Java version from Maven pom.xml
M.detect_maven_java_version = function()
	local pom_file = vim.fn.findfile("pom.xml", vim.fn.getcwd() .. ";")
	if pom_file == "" then return nil end

	local content = vim.fn.readfile(pom_file)
	local xml_content = table.concat(content, "\n")

	local version = xml_content:match("<maven%.compiler%.source>(%d+)</maven%.compiler%.source>")
	if not version then version = xml_content:match("<maven%.compiler%.target>(%d+)</maven%.compiler%.target>") end
	if not version then version = xml_content:match("<java%.version>(%d+)</java%.version>") end
	if not version then 
		-- Check parent or properties
		version = xml_content:match("<release>(%d+)</release>") 
	end
	
	return version
end

-- Detect Java version from Gradle build.gradle[.kts]
M.detect_gradle_java_version = function()
	local gradle_file = vim.fn.findfile("build.gradle", vim.fn.getcwd() .. ";")
	if gradle_file == "" then gradle_file = vim.fn.findfile("build.gradle.kts", vim.fn.getcwd() .. ";") end
	if gradle_file == "" then return nil end

	local content = vim.fn.readfile(gradle_file)
	local gradle_content = table.concat(content, "\n")

	local version = gradle_content:match("sourceCompatibility%s*=?%s*['\"]?(%d+)['\"]?")
	if not version then version = gradle_content:match("targetCompatibility%s*=?%s*['\"]?(%d+)['\"]?") end
	if not version then version = gradle_content:match("languageVersion%s*=%s*JavaLanguageVersion%s*%(%s*of%s*%(%s*(%d+)%s*%)*%)") end
	if not version then version = gradle_content:match("JavaLanguageVersion%.of%((%d+)%)") end
	if not version then version = gradle_content:match("jvmTarget%s*=%s*['\"]?(%d+)['\"]?") end
	
	return version
end

-- Main detection function
M.detect_project_java_version = function()
	local mvn_version = M.detect_maven_java_version()
	if mvn_version then
		vim.notify("🔍 Detected Maven Java version: " .. mvn_version, vim.log.levels.INFO)
		return mvn_version
	end

	local gradle_version = M.detect_gradle_java_version()
	if gradle_version then
		vim.notify("🔍 Detected Gradle Java version: " .. gradle_version, vim.log.levels.INFO)
		return gradle_version
	end

	vim.notify("⚠️  No Java version detected in build files, using default (25)", vim.log.levels.WARN)
	return "25"
end

-- Get runtime configuration for JDTLS
M.get_jdtls_runtimes = function()
	local detected_version = M.detect_project_java_version()
	local runtimes = {}
	local found_desired = false

	for ver, config in pairs(M.java_runtimes) do
		local runtime_config = {
			name = config.name,
			path = config.path,
			default = (ver == detected_version),
		}
		table.insert(runtimes, runtime_config)
		if ver == detected_version then found_desired = true end
	end

	if not found_desired and detected_version then
		vim.notify("⚠️  Java " .. detected_version .. " not configured in java-runtime.lua!", vim.log.levels.WARN)
	end

	return runtimes, detected_version
end

-- Manual runtime switcher using Telescope
M.show_runtime_picker = function()
	local has_telescope, pickers = pcall(require, "telescope.pickers")
	if not has_telescope then
		vim.notify("Telescope required!", vim.log.levels.ERROR)
		return
	end

	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local entries = {}
	for ver, config in pairs(M.java_runtimes) do
		table.insert(entries, {
			version = ver,
			name = config.name,
			path = config.path,
			display = string.format("Java %s (%s) - %s", ver, config.name, config.path),
		})
	end

	table.sort(entries, function(a, b) return tonumber(a.version) > tonumber(b.version) end)

	pickers.new({}, {
		prompt_title = "☕ Select Java Runtime",
		finder = finders.new_table({
			results = entries,
			entry_maker = function(entry)
				return { value = entry, display = entry.display, ordinal = entry.version }
			end,
		}),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection then M.switch_runtime(selection.value.version) end
			end)
			return true
		end,
	}):find()
end

-- Switch runtime manually and restart JDTLS
M.switch_runtime = function(version)
	local config = M.java_runtimes[version]
	if not config then
		vim.notify("Java " .. version .. " not configured!", vim.log.levels.ERROR)
		return
	end

	vim.env.JAVA_HOME = config.path
	vim.notify("☕ Switching to Java " .. version .. " (" .. config.path .. ")", vim.log.levels.INFO)

	-- Stop existing JDTLS
	vim.cmd("LspStop jdtls")
	
	-- Restart after delay
	vim.defer_fn(function()
		vim.cmd("LspStart jdtls")
		vim.notify("✅ Java " .. version .. " activated! LSP restarted.", vim.log.levels.INFO)
	end, 1500)
end

-- Auto-configure on Java file open
M.setup_autocmd = function()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "java",
		callback = function()
			local ver = M.detect_project_java_version()
			if ver then
				local config = M.java_runtimes[ver]
				if config then
					vim.env.JAVA_HOME = config.path
					vim.notify(string.format("☕ Auto-configured: Java %s (%s)", ver, config.name), vim.log.levels.INFO)
				end
			end
		end,
	})
end

-- Get current active Java version
M.get_current_java_version = function()
	local java_home = vim.env.JAVA_HOME
	if not java_home then return nil end
	
	local handle = io.popen(java_home .. "/bin/java -version 2>&1")
	if handle then
		local result = handle:read("*a")
		handle:close()
		-- Parse version string (handles both old 1.8 style and new style)
		local version = result:match('version%s+"(%d+)') or result:match('version%s+"1%.(%d+)')
		return version
	end
	return nil
end

-- Setup keymaps for Java runtime
M.setup_keymaps = function()
	local map = vim.keymap.set
	local opts = { noremap = true, silent = true }

	map("n", "<leader>jv", function()
		local ok, rt = pcall(require, "java-runtime")
		if ok then rt.show_runtime_picker() end
	end, vim.tbl_extend("force", opts, { desc = "☕ Switch Java Version" }))

	map("n", "<leader>jV", function()
		local ok, rt = pcall(require, "java-runtime")
		if ok then
			local ver = rt.detect_project_java_version()
			local current = rt.get_current_java_version()
			vim.notify(string.format("📋 Project: Java %s | Current: Java %s", ver or "?", current or "?"), vim.log.levels.INFO)
		end
	end, vim.tbl_extend("force", opts, { desc = "☕ Check Java Version" }))

	map("n", "<leader>jc", function()
		local ok, rt = pcall(require, "java-runtime")
		if ok then
			local ver = rt.detect_project_java_version()
			local cmd = vim.fn.filereadable("pom.xml") == 1 
				and ("!mvn clean compile -Djava.version=" .. ver)
				or ("!./gradlew compileJava")
			vim.cmd(cmd)
		end
	end, vim.tbl_extend("force", opts, { desc = "Compile with Project Java Version" }))
end

return M
