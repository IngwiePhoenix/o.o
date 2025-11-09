use platform
use runtime
use os
use re
use str

fn -on-windows {|cb|
  if $platform:is-windows {
    $cb
  }
}

fn -get-path-sep {
  if $platform:is-windows {
    put '\'
  } else {
    put '/'
  }
}

fn -rip-list-elems {|arr start|
  if (>= (count $arr) $start) {
    put $arr[$start..]
  } else {
    put [""]
  }
}

fn -pwd-to-short {
  var p = (tilde-abbr $pwd)
  var s = (-get-path-sep)
  var pa = [(str:split $s $p)]
  var segs = []
  var res = ""
  if $platform:is-windows {
    if (str:has-prefix $pwd '\\') {
      set segs = (-rip-list-elems $pa 3)
      set res = '\\'$pa[2]
    } elif (re:match "^[A-Z]:.+" $pwd) {
      set segs = (-rip-list-elems $pa 1)
      set res = $pa[0]
    }
  } else {
    set segs = $pa
    set res = ""
  }
  for i [(range (count $segs))] {
    var v = $segs[$i]
    var vstr = ""
    if (== (+ $i 1) (count $segs)) {
      set vstr = $v
    } elif (== (count $v) 0) {
      set vstr = "" #nop
    } else {
      set vstr = $v[0]
    }
    set res = $res$s$vstr
  }
  if $platform:is-unix {
    set res = $res[1..]
  }
  put $res
}

fn prompt-builder {
  put (styled '['$platform:os'/'$platform:arch'] ' cyan)

  var username = ""
  if $platform:is-windows {
    set username = $E:USERNAME
  } else {
    set username = (whoami)
  }
  put (styled $username 'fg-#00ff00')
  put (styled "@" fg-white)
  put (styled (hostname) fg-yellow)
  put " "
  put (styled (-pwd-to-short) fg-magenta)
  put (styled '# ' fg-bright-red)
}

# TODO: Does not work.
fn alias {|name cmd|
  edit:add-var $name"~" {|@argv| eval $cmd" "$@argv }
}

fn -shell-init {
  # prompt
  set edit:prompt = $prompt-builder~
  set edit:rprompt = {|| }

  # Windows
  if $platform:is-windows {
    # Map coreutils
    if (has-external coreutils) {
      var cmds = [(re:find "([[a-z0-9]*)," (echo (coreutils --help)) | each {|v| str:trim-right $v[text] "," })]
      for cmd $cmds {
        if (or (eq $cmd "echo") (eq $cmd "[")) { continue }
        eval "edit:add-var "$cmd"~ {|@argv| coreutils "$cmd" $@argv }"
      }
    } else {
      echo (styled "No coreutils! Install uutils.coreutils." red bold)
    }
    if (has-external duf) {
      edit:add-var df~ (external duf)
    } else {
      echo (styled "No df replacement! Install duf." red bold)
    }
  }

  # General goodies
  if (has-external eza) {
    edit:add-var ls~ {|@a| e:eza $@a }
    edit:add-var ll~ {|@a| e:eza -l $@a }
  } else {
    -on-windows { echo (styled "No ls replacement! Install eza." red bold) }
  }

  if (has-external bat) {
    edit:add-var cat~ {|@a| e:bat -pp --color=never $@a }
  } else {
    -on-windows { echo (styled "No cat replacement! Install bat." red bold) }
  }

  if (has-external zoxide) {
    try {
      eval (zoxide init elvish --cmd cd 2>/dev/null | slurp)
    } catch e {
      echo (styled "Zoxide maybe too old ("(echo $e)")." red bold)
    }
  } else {
    -on-windows { echo (styled "No cd replacement! Install zoxide." red bold) }
  }

  # *fetch
  for f [fastfetch neofetch] {
    if (has-external $f) {
      eval $f
      break
    }
  }
}

if (not-eq $runtime:effective-rc-path $nil) {
	-shell-init
}