function gut --description 'delete all old NixOS generations and garbage-collect the store'
    sudo nix-collect-garbage -d $argv
end
