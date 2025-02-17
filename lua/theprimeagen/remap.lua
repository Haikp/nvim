
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", function() vim.cmd.Ex() end)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<tab>", ">gv")
vim.keymap.set("v", "<S-tab>", "<gv")
vim.keymap.set("i", "kj", "<esc>")
vim.keymap.set("v", "<C-/>", "<Plug>(comment_toggle_linewise_visual)", { remap = true })

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

-- cmake keymaps
-- dispatch compile and run cmake files
-- vim.keymap.set("n", "<leader>dc", ":Dispatch make<CR>")
  -- Check for Unix-based systems (Linux/macOS)
OS_TYPE = ""
if vim.fn.has("unix") == 1 then
  OS_TYPE = "Linux"
elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  OS_TYPE = "Windows"
elseif vim.fn.has("mac") == 1 then
  OS_TYPE = "Mac"
else
  OS_TYPE = "Unknown OS"
end

ARCH = ""
if vim.fn.has("unix") == 1 then
  local arch = vim.fn.system("uname -m"):match("^%s*(.-)%s*$")  -- Trim spaces and get architecture
  if arch == "x86_64" then
    ARCH = "64"
  elseif arch == "i386" or arch == "i686" then
    ARCH = "32"
  else
    ARCH = "Unknown"
  end
-- Check for Windows
elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  local arch = vim.fn.system("wmic os get osarchitecture"):match("%s*(.-)%s*")
  if arch == "64-bit" then
    ARCH = "64"
  elseif arch == "32-bit" then
    ARCH = "32"
  else
    ARCH = "Unknown"
  end
else
  ARCH = "Unknown"  -- In case the architecture can't be determined
end

local build_type = "Release"

-- vim.keymap.set("n", "<leader>dcr", function()
--   local cwd = vim.fn.getcwd()  -- Get current working directory
--   vim.cmd("Dispatch cmake " .. cwd .. " -DCMAKE_BUILD_TYPE=Release")
--     build_type = "Release"
-- end)
--
-- vim.keymap.set("n", "<leader>dcd", function()
--   local cwd = vim.fn.getcwd()  -- Get current working directory
--   vim.cmd("Dispatch cmake " .. cwd .. " -DCMAKE_BUILD_TYPE=Debug")
--     build_type = "Debug"
-- end)

local function find_cmake_root()
  local file_dir = vim.fn.expand("%:p:h")  -- Start from the directory of the currently opened file
  local cwd = vim.fn.getcwd()              -- Stop searching when we reach the working directory
  local cmake_dir = file_dir

  if vim.fn.filereadable(cmake_dir .. "/CMakeLists.txt") == 1 then
    return cmake_dir
  end

  -- Traverse upwards to find the nearest CMakeLists.txt
  while cmake_dir ~= "/" and cmake_dir ~= "" and cmake_dir ~= cwd do
    if vim.fn.filereadable(cmake_dir .. "/CMakeLists.txt") == 1 then
      return cmake_dir
    end
    cmake_dir = vim.fn.fnamemodify(cmake_dir, ":h")  -- Move up a directory
  end

  print("No CMakeLists.txt found! Aborting.")
  return nil
end

local function configure_cmake(build_type)
  local cmake_root = find_cmake_root()
  if not cmake_root then return end  -- Exit if no CMakeLists.txt is found

  local content = vim.fn.readfile(cmake_root .. "/CMakeLists.txt")
  local project_name

    -- Search for the project name using a regular expression
    for _, line in ipairs(content) do
      project_name = string.match(line, "project%s*%(s*([^%s%)]+)%s*%)")
      if project_name then
        break
      end
    end

  local build_dir = vim.fn.getcwd() .. "/build" .. "/" .. project_name

  vim.g.cmake_build_type = build_type  -- Store build type globally
  vim.cmd("Dispatch cmake -S " .. cmake_root .. " -B " .. build_dir .. " -DCMAKE_BUILD_TYPE=" .. build_type)
end

vim.keymap.set("n", "<leader>dcr", function()
  configure_cmake("Release")
end)

vim.keymap.set("n", "<leader>dcd", function()
  configure_cmake("Debug")
end)

-- dispatch "make" current file
local function dispatch_make()
  local cmake_root = find_cmake_root()
  if not cmake_root then return end  -- Exit if no CMakeLists.txt is found

  local content = vim.fn.readfile(cmake_root .. "/CMakeLists.txt")
  local project_name

    -- Search for the project name using a regular expression
    for _, line in ipairs(content) do
      project_name = string.match(line, "project%s*%(s*([^%s%)]+)%s*%)")
      if project_name then
        break
      end
    end
  local build_dir = vim.fn.getcwd() .. "/build" .. "/" .. project_name

  -- Ensure build directory exists
  if vim.fn.isdirectory(build_dir) == 0 then
    print("Build directory not found! Run CMake configure first.")
    return
  end

  -- Run Dispatch make in the detected build directory
  vim.cmd("Dispatch make -C " .. build_dir)
end

vim.keymap.set("n", "<leader>dm", dispatch_make)

local function dispatch_run_executable()
  local cmake_root = find_cmake_root()
  if not cmake_root then return end  -- Exit if no CMakeLists.txt is found

  local content = vim.fn.readfile(cmake_root .. "/CMakeLists.txt")
  local project_name

    -- Search for the project name using a regular expression
    for _, line in ipairs(content) do
      project_name = string.match(line, "project%s*%(s*([^%s%)]+)%s*%)")
      if project_name then
        break
      end
    end

  -- Determine the build folder (which is typically located in the build folder)
  local build_dir = vim.fn.getcwd() .. "/build" .. "/" .. project_name

  -- Construct the executable path using the build directory
  local exec_path = build_dir .. "/bin/" .. OS_TYPE .. ARCH .. "/" .. build_type .. "/app"

  -- Run the executable
  vim.cmd("Dispatch " .. exec_path)
end

-- dispatch run current file
vim.keymap.set("n", "<leader>dr", dispatch_run_executable)

vim.keymap.set("n", "<leader>vwm", function()
    require("vim-with-me").StartVimWithMe()
end)
vim.keymap.set("n", "<leader>svwm", function()
    require("vim-with-me").StopVimWithMe()
end)

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
-- specific to WSL very fun!
vim.keymap.set({"n", "v"}, "<leader>y", ':w !clip.exe<CR><CR>')
-- below is a setting that works NOT for WSL :)
-- vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { noremap = true })
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", "\"_d")

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format() end)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set( "n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>")

vim.keymap.set( "n", "<leader>ea", "oassert.NoError(err, \"\")<Esc>F\";a")

vim.keymap.set( "n", "<leader>el", "oif err != nil {<CR>}<Esc>O.logger.Error(\"error\", \"error\", err)<Esc>F.;i")


vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>");
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

