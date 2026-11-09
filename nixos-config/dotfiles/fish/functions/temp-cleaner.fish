function temp-cleaner --wraps='sudo rm -rf /tmp/*' --description 'alias temp-cleaner=sudo rm -rf /tmp/*'
    sudo rm -rf /tmp/* $argv
end
