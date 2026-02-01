return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "stevearc/dressing.nvim", -- For better vim.ui.input/select
    "rcarriga/nvim-notify",   -- For notifications
  },
  keys = {
    { "<leader>jn", "<cmd>SpringBootInit<cr>", desc = "Java New Project" },
  },
  cmd = { "SpringBootInit" },
  config = function()
    local telescope = require("telescope.builtin")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local notify = require("notify")

    -- Setup notify
    vim.notify = notify

    -- Predefined Popular Dependencies
    -- Adding a curated list of common Spring Boot dependencies
    local AVAILABLE_DEPENDENCIES = {
      { id = "web", name = "Spring Web", description = "Build web, including RESTful, applications using Spring MVC." },
      { id = "lombok", name = "Lombok", description = "Java annotation library which helps to reduce boilerplate code." },
      { id = "devtools", name = "Spring Boot DevTools", description = "Provides fast application restarts, LiveReload, and configurations for enhanced development experience." },
      { id = "data-jpa", name = "Spring Data JPA", description = "Persist data in SQL stores with Java Persistence API using Spring Data and Hibernate." },
      { id = "postgresql", name = "PostgreSQL Driver", description = "A JDBC and R2DBC driver that allows Java programs to connect to a PostgreSQL database." },
      { id = "mysql", name = "MySQL Driver", description = "A JDBC driver that allows Java programs to connect to a MySQL database." },
      { id = "docker-compose", name = "Docker Compose Support", description = "Provides support for Docker Compose." },
      { id = "security", name = "Spring Security", description = "Highly customizable authentication and access-control framework for Spring applications." },
      { id = "actuator", name = "Spring Boot Actuator", description = "Supports built in (or custom) endpoints that let you monitor and manage your application." },
      { id = "validation", name = "Validation", description = "Bean Validation with Hibernate Validator." },
      { id = "thymeleaf", name = "Thymeleaf", description = "A modern server-side Java template engine." },
      { id = "kafka", name = "Spring for Apache Kafka", description = "Pub/Sub messaging and streaming with Apache Kafka." },
      { id = "test", name = "Spring Boot Starter Test", description = "Unit and integration testing support." },
    }

    -- Utility: Check for system tools
    local function check_requirements()
      if vim.fn.executable("curl") == 0 then
        vim.notify("Error: 'curl' is required but not installed.", "error")
        return false
      end
      if vim.fn.executable("unzip") == 0 then
        vim.notify("Error: 'unzip' is required but not installed.", "error")
        return false
      end
      return true
    end

    -- Step 1: Input Prompts
    local function prompt_user_details(callback)
      vim.ui.input({ prompt = "Group ID: ", default = "com.ujjawal" }, function(group_id)
        if not group_id then return end
        
        vim.ui.input({ prompt = "Artifact ID: " }, function(artifact_id)
          if not artifact_id then return end
          
          vim.ui.select({ "17", "21", "25" }, { prompt = "Java Version: " }, function(java_version)
            if not java_version then return end
            callback(group_id, artifact_id, java_version)
          end)
        end)
      end)
    end

    -- Step 2: Dependency Selection (Telescope Multiselect)
    local function select_dependencies(callback)
      pickers.new({}, {
        prompt_title = "Select Dependencies (<Tab> to toggle, <CR> to confirm)",
        finder = finders.new_table({
          results = AVAILABLE_DEPENDENCIES,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.name .. " - " .. entry.description,
              ordinal = entry.name .. " " .. entry.description,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local current_picker = action_state.get_current_picker(prompt_bufnr)
            local selections = current_picker:get_multi_selection()
            
            -- If no multi-selection, try to take the currently highlighted item
            if vim.tbl_isempty(selections) then
                local selection = action_state.get_selected_entry()
                if selection then
                    table.insert(selections, selection)
                end
            end

            actions.close(prompt_bufnr)
            
            local dep_ids = {}
            for _, selection in ipairs(selections) do
              table.insert(dep_ids, selection.value.id)
            end
            callback(dep_ids)
          end)
          return true
        end,
      }):find()
    end

    -- Step 3: Download and Unzip Logic (Async)
    local function generate_project(config)
      local base_url = "https://start.spring.io/starter.zip"
      local dependencies = table.concat(config.dependencies, ",")
      
      -- Construct Query Params
      -- Note: Omitted bootVersion to let Spring Initializr pick the latest stable version.
      local params = {
        type = "maven-project",
        language = "java",
        baseDir = config.artifact_id,
        groupId = config.group_id,
        artifactId = config.artifact_id,
        name = config.artifact_id,
        packageName = config.group_id .. "." .. config.artifact_id:gsub("-", ""),
        packaging = "jar",
        javaVersion = config.java_version,
        dependencies = dependencies,
      }

      local query_string = ""
      for k, v in pairs(params) do
        query_string = query_string .. k .. "=" .. vim.fn.escape(v, " &") .. "&"
      end

      local full_url = base_url .. "?" .. query_string
      local zip_file = config.artifact_id .. ".zip"
      
      vim.notify("Downloading project from Spring Initializr...", "info")

      -- Async Job: Curl -> Check Zip -> Unzip -> Clean
      vim.fn.jobstart({ "curl", "-s", "-o", zip_file, full_url }, {
        on_exit = function(_, curl_code, _)
          if curl_code ~= 0 then
            vim.notify("Failed to download project. Check your internet connection.", "error")
            return
          end

          -- Check if the downloaded file is a valid zip archive
          vim.fn.jobstart({ "unzip", "-t", zip_file }, {
            on_exit = function(_, test_code, _)
              if test_code ~= 0 then
                -- Not a zip file, likely a JSON error response from the API
                local f = io.open(zip_file, "r")
                local content = f:read("*a")
                f:close()
                os.remove(zip_file)
                
                -- Try to parse JSON error message if possible, or just show raw
                local error_msg = content
                if content:find("message") then
                   -- Simple string match to extract message to avoid adding json dep
                   local msg_match = content:match('"message":"(.-)"')
                   if msg_match then
                      error_msg = msg_match
                   end
                end
                
                vim.notify("Spring Initializr API Error: " .. error_msg, "error")
                return
              end

              -- It is a valid zip, proceed to unzip
              vim.notify("Download complete. Unzipping...", "info")
              
              vim.fn.jobstart({ "unzip", "-o", zip_file }, {
                on_exit = function(_, unzip_code, _)
                  if unzip_code ~= 0 then
                    vim.notify("Failed to unzip project.", "error")
                    return
                  end

                  os.remove(zip_file)
                  vim.notify("Project created successfully: " .. config.artifact_id, "info")
                  
                  -- Trigger post-creation actions
                  config.on_success(config.artifact_id)
                end
              })
            end
          })
        end
      })
    end

    -- Step 4: Post-Creation Handler (Smart Open)
    local function handle_post_success(artifact_id)
      local project_path = vim.fn.getcwd() .. "/" .. artifact_id
      
      local choices = {
        "Open Here (Change Directory)",
        "Open in New Zellij Pane (Keep Context)"
      }
      
      vim.ui.select(choices, { prompt = "Project Ready. What next?" }, function(choice)
        if not choice then return end

        if choice == choices[1] then
          -- Open Here
          vim.cmd("cd " .. project_path)
          vim.cmd("e pom.xml")
          vim.notify("Switched workspace to " .. project_path, "info")
          
        elseif choice == choices[2] then
          -- Open in New Zellij Pane
          -- Why: Running Neovim inside a terminal multiplexer (Zellij) allows us to spawn
          -- a parallel workspace without losing our current context. 
          -- We use 'zellij action new-pane' to instruct the parent process to split the 
          -- view and launch a fresh Neovim instance in the new project directory.
          local zellij_cmd = string.format(
            "zellij action new-pane --name '%s' --cwd '%s' -- nvim pom.xml",
            artifact_id,
            project_path
          )
          
          vim.fn.jobstart(zellij_cmd, {
              on_detach = function() end, -- Fire and forget
          })
          vim.notify("Launched new Zellij pane for " .. artifact_id, "info")
        end
      end)
    end

    -- Main Command Entry
    vim.api.nvim_create_user_command("SpringBootInit", function()
      if not check_requirements() then return end

      prompt_user_details(function(group_id, artifact_id, java_version)
        select_dependencies(function(selected_deps)
          
          generate_project({
            group_id = group_id,
            artifact_id = artifact_id,
            java_version = java_version,
            dependencies = selected_deps,
            on_success = handle_post_success
          })

        end)
      end)
    end, {})
  end,
}
