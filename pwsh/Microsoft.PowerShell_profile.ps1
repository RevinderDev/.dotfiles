# Prompt
Invoke-Expression (&starship init powershell)
Import-Module posh-git
# Import-Module oh-my-posh
# Set-PoshPrompt powerlevel10k_lean

# Icons
Import-Module -Name Terminal-Icons

# PSReadLine
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History
# Set-PSReadLineOption -PredictionViewStyle ListView

# Fzf
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Aliases
Set-Alias -Name python2 -Value "C:\Users\Symbios\.pyenv\pyenv-win\versions\2.7\python.exe"
Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr
Set-Alias gs "git status"
Set-Alias ga "git add"

# Utils
function which($command) {
 Get-Command -Name $command -ErrorAction SilentlyContinue | 
	Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
