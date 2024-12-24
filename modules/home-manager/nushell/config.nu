# Nushell Config File
#
# Defaults: https://github.com/nushell/nushell/blob/main/docs/sample_config/default_config.nu

$env.config = {
  show_banner: false,
}

def g [...args] {
  if ($args | is-empty) {
    git status --short --branch
  } else {
    git ...$args
  }
}

def gbs [] {
  let branch = (
    git branch |
    split row "\n" |
    str trim |
    where ($it !~ '\*') |
    where ($it != '') |
    str join (char nl) |
    fzf --no-multi
    )

  if $branch != '' {
    git switch $branch
  }
}

def gbd [] {
  let branches = (
    git branch |
    split row "\n" |
    str trim |
    where ($it !~ '\*') |
    where ($it != '') |
    str join (char nl) |
    fzf --multi |
    split row "\n" |
    where ($it != '')
  )
  if ($branches | length) > 0 {
    $branches | each { |branch| git branch -d $branch }
    ""
  }
}
