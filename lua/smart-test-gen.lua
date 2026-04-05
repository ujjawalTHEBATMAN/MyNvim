-- smart-test-gen.lua
-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                    🧪 SMART TEST GENERATION                               ║
-- ║        Automatically creates test files in the correct location           ║
-- ╠══════════════════════════════════════════════════════════════════════════╣
-- ║  USAGE:                                                                   ║
-- ║    :GenTest          → Generate tests for current file                    ║
-- ║    <Space>AT         → Generate tests to proper test directory            ║
-- ║                                                                           ║
-- ║  BEHAVIOR:                                                                ║
-- ║    1. Detects package from source file                                    ║
-- ║    2. Detects test framework (JUnit 5/TestNG/Spock) from project deps     ║
-- ║    3. Creates test directory: src/main → src/test                         ║
-- ║    4. Creates test class: MyClass.java → MyClassTest.java                 ║
-- ║    5. Generates framework-specific tests and writes to file               ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local M = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════

M.config = {
	-- Auto-detect test framework from project dependencies
	auto_detect_framework = true,
	-- Default framework if detection fails
	default_framework = "junit5",
	-- Supported frameworks
	supported_frameworks = { "junit5", "junit4", "testng", "spock" },
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PATH UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════

--- Get file info from current buffer
---@return table {filepath, filename, extension, dir, package_name, class_name}
function M.get_file_info()
  local filepath = vim.fn.expand('%:p')        -- Full path
  local filename = vim.fn.expand('%:t')        -- File name with extension
  local extension = vim.fn.expand('%:e')       -- Extension only
  local dir = vim.fn.expand('%:p:h')           -- Directory

  -- Extract class name (remove extension)
  local class_name = filename:gsub('%.' .. extension .. '$', '')

  -- Try to detect package from file content (Java)
  local package_name = nil
  if extension == 'java' then
    local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
    for _, line in ipairs(lines) do
      local pkg = line:match('^%s*package%s+([%w%.]+)%s*;')
      if pkg then
        package_name = pkg
        break
      end
    end
  end

  return {
    filepath = filepath,
    filename = filename,
    extension = extension,
    dir = dir,
    package_name = package_name,
    class_name = class_name,
  }
end

--- Find project root directory
local function find_project_root()
	local markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".git" }
	local current = vim.fn.expand("%:p:h")

	for _, marker in ipairs(markers) do
		local found = vim.fn.findfile(marker, current .. ";")
		if found ~= "" then
			return vim.fn.fnamemodify(found, ":p:h")
		end
	end

	return vim.fn.getcwd()
end

--- Check if a file exists
local function file_exists(path)
	return vim.fn.filereadable(path) == 1
end

--- Detect test framework from project dependencies
---@param root string Project root directory
---@return string framework: "junit5", "junit4", "testng", "spock"
local function detect_test_framework(root)
	local pom_path = root .. "/pom.xml"
	local gradle_path = file_exists(root .. "/build.gradle.kts") and root .. "/build.gradle.kts" 
		or root .. "/build.gradle"
	
	-- Check Maven pom.xml
	if file_exists(pom_path) then
		local pom_content = table.concat(vim.fn.readfile(pom_path), "\n"):lower()
		
		-- Check for Spock first (Groovy-based)
		if pom_content:find("spock%-core") or pom_content:find("spock%-spring") then
			return "spock"
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
	
	-- Check Gradle build files
	if file_exists(gradle_path) then
		local gradle_content = table.concat(vim.fn.readfile(gradle_path), "\n"):lower()
		
		-- Check for Spock first
		if gradle_content:find("spock") then
			return "spock"
		end
		
		-- Check for TestNG
		if gradle_content:find("testng") then
			return "testng"
		end
		
		-- Check for JUnit 5
		if gradle_content:find("usejunitplatform") or gradle_content:find("junit%-jupiter") or gradle_content:find("junit5") then
			return "junit5"
		end
		
		-- Check for JUnit 4
		if gradle_content:find("testimplementation.*junit") then
			return "junit4"
		end
	end
	
	-- Default to JUnit 5
	return M.config.default_framework
end

--- Calculate test file path based on source file
---@param file_info table
---@return string test_filepath, string test_dir
function M.get_test_path(file_info)
  local source_path = file_info.filepath
  local class_name = file_info.class_name
  local extension = file_info.extension

  -- Standard Maven/Gradle structure: src/main/java → src/test/java
  local test_path = source_path

  -- Replace src/main/java with src/test/java
  if test_path:match('src/main/java') then
    test_path = test_path:gsub('src/main/java', 'src/test/java')
  -- Replace src/main with src/test (Gradle style)
  elseif test_path:match('src/main') then
    test_path = test_path:gsub('src/main', 'src/test')
  -- If no standard structure, create test next to source
  else
    local dir = file_info.dir
    local test_dir = dir .. '/test'
    test_path = test_dir .. '/' .. class_name .. 'Test.' .. extension
  end

  -- Replace ClassName.java with ClassNameTest.java
  test_path = test_path:gsub(class_name .. '%.' .. extension .. '$', class_name .. 'Test.' .. extension)

  -- Get test directory
  local test_dir = vim.fn.fnamemodify(test_path, ':h')

  return test_path, test_dir
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TEST GENERATION
-- ═══════════════════════════════════════════════════════════════════════════

--- Generate test content using Ollama with framework-specific templates
---@param code string The source code to generate tests for
---@param file_info table File information
---@param framework string Test framework: "junit5", "junit4", "testng", "spock"
---@param callback function Callback with generated content
function M.generate_tests(code, file_info, framework, callback)
  local package_statement = ''
  if file_info.package_name then
    package_statement = 'package ' .. file_info.package_name .. ';'
  end
  
  -- Framework-specific configurations
  local frameworks = {
    junit5 = {
      name = "JUnit 5 (Jupiter)",
      imports = [[
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;]],
      class_suffix = "Test",
    },
    junit4 = {
      name = "JUnit 4",
      imports = [[
import org.junit.Test;
import org.junit.Before;
import static org.junit.Assert.*;]],
      class_suffix = "Test",
    },
    testng = {
      name = "TestNG",
      imports = [[
import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import static org.testng.Assert.*;]],
      class_suffix = "Test",
    },
    spock = {
      name = "Spock",
      imports = [[
import spock.lang.Specification;]],
      class_suffix = "Spec",
      is_spock = true,
    },
  }
  
  local fw = frameworks[framework] or frameworks.junit5
  local class_suffix = fw.class_suffix or "Test"

  local prompt = string.format([[
=== SMART TEST GENERATION ===

Generate a complete %s test class for this code:

```%s
%s
```

=== REQUIREMENTS ===

1. Package: %s (same as source)
2. Class name: %s%s
3. Framework: %s

=== OUTPUT FORMAT ===

Generate ONLY the complete test file content:

```%s
%s

%s

/**
 * Tests for %s
 */
class %s%s {
    
    // Your test methods here
    
}
```

=== TEST COVERAGE ===

Include tests for:
✅ Happy path (normal cases)
✅ Edge cases (null, empty, boundary values)
✅ Error cases (exceptions)

=== OUTPUT RULES ===

⚠️ Output ONLY the complete test file
⚠️ Include ALL necessary imports
⚠️ Use proper %s annotations/syntax
⚠️ Ready to save directly to file
]], 
    fw.name, file_info.extension, code, 
    file_info.package_name or 'default', 
    file_info.class_name, class_suffix,
    fw.name,
    fw.is_spock and 'groovy' or file_info.extension,
    package_statement, 
    fw.imports, 
    file_info.class_name, 
    file_info.class_name, class_suffix,
    fw.name)

  -- Use Ollama directly via curl for more control
  local cmd = string.format(
    [[curl -s http://localhost:11434/api/generate -d '{"model": "gemma3:270m", "prompt": %s, "stream": false}']],
    vim.fn.json_encode(prompt)
  )

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      if data and data[1] then
        local ok, result = pcall(vim.fn.json_decode, data[1])
        if ok and result and result.response then
          callback(result.response, framework)
        else
          callback(nil, 'Failed to parse response')
        end
      end
    end,
    on_stderr = function(_, data, _)
      if data and data[1] and data[1] ~= '' then
        vim.notify('Error: ' .. table.concat(data, '
'), vim.log.levels.ERROR)
      end
    end,
  })
end

--- Extract Java code from markdown code blocks
---@param content string
---@return string
function M.extract_code(content)
  -- Try to extract from ```java ... ``` block
  local java_code = content:match('```java%s*\n(.-)```')
  if java_code then
    return java_code
  end
  -- Try generic code block
  java_code = content:match('```%s*\n(.-)```')
  if java_code then
    return java_code
  end
  -- Return as-is if no code block found
  return content
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MAIN FUNCTION
-- ═══════════════════════════════════════════════════════════════════════════

--- Generate tests and write to test file
function M.generate_and_write()
  local file_info = M.get_file_info()
  
  -- Detect test framework from project
  local root = find_project_root()
  local framework = detect_test_framework(root)

  -- Validate file type
  if file_info.extension ~= 'java' then
    vim.notify('⚠️ Smart test generation currently supports Java only', vim.log.levels.WARN)
    return
  end

  -- Get selected code or entire buffer
  local code
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then
    -- Visual mode - get selection
    vim.cmd('normal! "vy')
    code = vim.fn.getreg('v')
  else
    -- Normal mode - get entire buffer
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    code = table.concat(lines, '\n')
  end

  if not code or code == '' then
    vim.notify('⚠️ No code to generate tests for', vim.log.levels.WARN)
    return
  end

  -- Calculate test file path
  local test_path, test_dir = M.get_test_path(file_info)

  -- Notify user
  vim.notify(string.format([[
🧪 Generating Tests...

Source:   %s
Test:     %s
Framework: %s

Please wait...]], file_info.filename, vim.fn.fnamemodify(test_path, ':t'), framework), vim.log.levels.INFO, { title = 'Smart Test Gen' })

  -- Generate tests
  M.generate_tests(code, file_info, framework, function(response, err)
    if err then
      vim.notify('❌ ' .. err, vim.log.levels.ERROR)
      return
    end

    if not response then
      vim.notify('❌ No response from AI', vim.log.levels.ERROR)
      return
    end

    -- Extract code from response
    local test_code = M.extract_code(response)

    -- Create test directory if needed
    vim.fn.mkdir(test_dir, 'p')

    -- Check if test file exists
    local file_exists = vim.fn.filereadable(test_path) == 1
    local action = file_exists and 'Updated' or 'Created'

    -- Write test file
    local file = io.open(test_path, 'w')
    if file then
      file:write(test_code)
      file:close()

      vim.notify(string.format([[
✅ %s test file!

📁 %s

Opening file...]], action, test_path), vim.log.levels.INFO, { title = '🧪 Test Generated' })

      -- Open the test file
      vim.schedule(function()
        vim.cmd('edit ' .. test_path)
      end)
    else
      vim.notify('❌ Failed to write test file: ' .. test_path, vim.log.levels.ERROR)
    end
  end)
end

--- Preview test generation (shows in floating window, doesn't write)
function M.preview()
  local file_info = M.get_file_info()
  local test_path, _ = M.get_test_path(file_info)

  vim.notify(string.format([[
📋 Test Generation Preview

Source File: %s
Package:     %s
Class:       %s

Test Path:   %s
Test Class:  %sTest

Press <Space>AT to generate!]], 
    file_info.filename,
    file_info.package_name or '(none)',
    file_info.class_name,
    test_path,
    file_info.class_name
  ), vim.log.levels.INFO, { title = '🧪 Smart Test Gen' })
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SETUP
-- ═══════════════════════════════════════════════════════════════════════════

function M.setup()
  -- Create commands
  vim.api.nvim_create_user_command('GenTest', function()
    M.generate_and_write()
  end, { desc = '🧪 Generate tests to test directory' })

  vim.api.nvim_create_user_command('GenTestPreview', function()
    M.preview()
  end, { desc = '📋 Preview test generation path' })

  -- Create keymaps
  vim.keymap.set({ 'n', 'v' }, '<leader>AT', function()
    M.generate_and_write()
  end, { desc = '🧪 Generate Tests to File', silent = true })

  vim.keymap.set('n', '<leader>ATp', function()
    M.preview()
  end, { desc = '📋 Preview Test Path', silent = true })
end

return M
