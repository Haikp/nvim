function ColorMyPencils(color)
	color = color-- or "dayfox"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 }
}
