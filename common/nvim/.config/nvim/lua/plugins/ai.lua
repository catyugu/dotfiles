return {
  "milanglacier/minuet-ai.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("minuet").setup({
      -- 开启虚拟文本（幽灵文本）补全
      virtualtext = {
        auto_trigger_ft = { "*" }, -- 在所有文件类型中自动触发
        keymap = {
          accept = "<A-y>",        -- Alt+y 接受全部补全
          accept_line = "<A-a>",   -- Alt+a 接受一行
          prev = "<A-[>",          -- Alt+[ 上一个补全项
          next = "<A-]>",          -- Alt+] 下一个补全项
          dismiss = "<A-e>",       -- Alt+e 取消补全
        },
      },
      provider = "openai_compatible",
      provider_options = {
        openai_compatible = {
          model = "qwen",
          -- 注意：这里填全路径 endpoint
          end_point = "https://models.sjtu.edu.cn/api/v1/chat/completions",
          -- 插件会自动去读取名为 SJTU_API_KEY 的环境变量
          api_key = "SJTU_API_KEY",
          name = "SJTU_MODEL",
          stream = true,
          optional = {
            max_tokens = 256,
            temperature = 0.1, -- 补全建议将温度调低，保证代码确定性
          },
        },
      },
    })
  end,
}
