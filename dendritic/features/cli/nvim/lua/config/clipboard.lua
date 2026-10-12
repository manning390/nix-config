-- Choose the Windows clipboard before plugins initialize a provider. WSLg's
-- X11/Wayland clipboard and terminal OSC 52 detection vary between sessions.
if vim.fn.has('wsl') == 0 then return end

if vim.fn.executable('win32yank.exe') == 1 then
    vim.g.clipboard = 'win32yank'
elseif vim.fn.executable('powershell.exe') == 1 then
    -- Use argv lists so the shell does not reinterpret PowerShell expressions.
    -- Explicit UTF-8 keeps Unicode intact in both directions.
    local function powershell(script)
        return {
            'powershell.exe', '-NoLogo', '-NoProfile', '-NonInteractive',
            '-Command', '$ErrorActionPreference = "Stop"; ' .. script,
        }
    end

    local copy = powershell(
        '[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false); '
        .. 'Set-Clipboard -Value ([Console]::In.ReadToEnd())'
    )
    local paste = powershell(
        '[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false); '
        .. '$text = Get-Clipboard -Raw; '
        .. 'if ($null -ne $text) { [Console]::Out.Write($text.Replace("`r`n", "`n")) }'
    )

    vim.g.clipboard = {
        name = 'WSL Windows clipboard',
        copy = { ['+'] = copy, ['*'] = copy },
        paste = { ['+'] = paste, ['*'] = paste },
        cache_enabled = 0,
    }
end
