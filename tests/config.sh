source common.sh

# Test that files are loaded from XDG by default
export XDG_CONFIG_HOME=/tmp/home
export XDG_CONFIG_DIRS=/tmp/dir1:/tmp/dir2
files=$(nix-build --verbose --version | grep "User config" | cut -d ':' -f2- | xargs)
[[ $files == "/tmp/home/nix/nix.conf:/tmp/dir1/nix/nix.conf:/tmp/dir2/nix/nix.conf" ]]

# Test that setting NIX_USER_CONF_FILES overrides all the default user config files
export NIX_USER_CONF_FILES=/tmp/file1.conf:/tmp/file2.conf
files=$(nix-build --verbose --version | grep "User config" | cut -d ':' -f2- | xargs)
[[ $files == "/tmp/file1.conf:/tmp/file2.conf" ]]

# Test that it's possible to load the config from a custom location
here=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
export NIX_USER_CONF_FILES=$here/config/nix-with-substituters.conf
var=$(nix show-config | grep '^substituters =' | cut -d '=' -f 2 | xargs)
[[ $var == https://example.com ]]

# Test that it's possible to load config from the environment
prev=$(nix show-config | grep '^cores' | cut -d '=' -f 2 | xargs)
export NIX_CONFIG="cores = 4242"$'\n'"experimental-features = nix-command flakes"
exp_cores=$(nix show-config | grep '^cores' | cut -d '=' -f 2 | xargs)
exp_features=$(nix show-config | grep '^experimental-features' | cut -d '=' -f 2 | xargs)
[[ $prev != $exp_cores ]]
[[ $exp_cores == "4242" ]]
[[ $exp_features == "nix-command flakes" ]]