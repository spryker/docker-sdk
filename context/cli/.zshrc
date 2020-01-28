
function printc () {
 print "ECHO: $1"
}

autoload -Uz  add-zsh-hook

add-zsh-hook preexec printc
