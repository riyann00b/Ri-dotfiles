# config.nu
#
# Installed by:
# version = "0.108.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

# --------------------------------------------------------------------
# STARSHIP PROMPT INTEGRATION
# --------------------------------------------------------------------
# Starship is a fast, customizable prompt for any shell
# Installation: https://starship.rs/guide/#step-1-install-starship

# Set the shell type for Starship
#$env.STARSHIP_SHELL = "nu"

# Initialize Starship and save to autoload directory
# This will automatically load Starship on every Nushell session
#starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# Note: Make sure Starship is installed on your system

# --------------------------------------------------------------------
# NUSHELL PLUGIN DIRECTORIES
# --------------------------------------------------------------------
# Configure where Nushell looks for plugins
# This adds the directory containing the nu executable to plugin search paths

const NU_PLUGIN_DIRS = [
    ($nu.current-exe | path dirname)  # Directory containing nushell executable
    ...$NU_PLUGIN_DIRS                # Preserve existing plugin directories
]

# --------------------------------------------------------------------
# CUSTOM PATH ADDITIONS
# --------------------------------------------------------------------
# Add custom directories to your PATH environment variable

$env.PATH ++= [
     "/home/riyan/.cargo/bin"
     "/usr/local/bin"
     ($env.HOME | path join ".local/bin")
]

# ====================================================================
# THEME CONFIGURATION
# ====================================================================

# Define a modern dark theme with syntax highlighting
let dark_theme = {
    # Color for nushell primitives
    separator: white
    leading_trailing_space_bg: { attr: n }  # no fg, no bg, attr none effectively turns this off
    header: green_bold
    empty: blue
    bool: light_cyan
    int: purple_bold
    filesize: cyan
    duration: yellow_bold
    date: cyan_bold
    range: yellow_bold
    float: purple_bold
    string: green
    nothing: white
    binary: cyan_bold
    cellpath: cyan
    row_index: green_bold
    record: white
    list: white
    block: cyan_bold
    hints: dark_gray
    search_result: { bg: red fg: white }

    # Shapes are used to change the CLI syntax highlighting
    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b }
    shape_binary: purple_bold
    shape_bool: light_cyan
    shape_int: purple_bold
    shape_float: purple_bold
    shape_range: yellow_bold
    shape_internalcall: cyan_bold
    shape_external: green
    shape_externalarg: green_bold
    shape_literal: blue
    shape_operator: yellow
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_datetime: cyan_bold
    shape_list: cyan_bold
    shape_table: blue_bold
    shape_record: cyan_bold
    shape_block: blue_bold
    shape_filepath: cyan
    shape_directory: cyan_bold
    shape_globpattern: cyan_bold
    shape_variable: purple
    shape_flag: blue_bold
    shape_custom: green
    shape_nothing: light_cyan
    shape_matching_brackets: { attr: u }
}

# Light theme alternative
let light_theme = {
    separator: dark_gray
    leading_trailing_space_bg: { attr: n }
    header: green_bold
    empty: blue
    bool: dark_gray
    int: dark_gray
    filesize: cyan_bold
    duration: dark_gray
    date: dark_gray
    range: dark_gray
    float: dark_gray
    string: dark_gray
    nothing: dark_gray
    binary: dark_gray
    cellpath: dark_gray
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray

    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b }
    shape_binary: purple_bold
    shape_bool: light_cyan
    shape_int: purple_bold
    shape_float: purple_bold
    shape_range: yellow_bold
    shape_internalcall: cyan_bold
    shape_external: green
    shape_externalarg: green_bold
    shape_literal: blue
    shape_operator: yellow
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_datetime: cyan_bold
    shape_list: cyan_bold
    shape_table: blue_bold
    shape_record: cyan_bold
    shape_block: blue_bold
    shape_filepath: cyan
    shape_directory: cyan_bold
    shape_globpattern: cyan_bold
    shape_variable: purple
    shape_flag: blue_bold
    shape_custom: green
    shape_nothing: light_cyan
}

# ====================================================================
# CUSTOM COMPLETIONS
# ====================================================================

module completions {
    # Custom completions for external commands (those outside of Nushell)
    # Each completion has two parts: the form of the external command, including its flags and parameters
    # and a helper command that knows how to complete values for those flags and parameters

    # Git branch completions
    def "nu-complete git branches" [] {
        ^git branch | lines | each { |line| $line | str replace '[\*\+] ' '' | str trim }
    }

    # Git remote completions
    def "nu-complete git remotes" [] {
        ^git remote | lines | each { |line| $line | str trim }
    }

    # Git checkout with completions
    export extern "git checkout" [
        branch?: string@"nu-complete git branches"  # name of the branch to checkout
        -b: string                                   # create and checkout a new branch
        -B: string                                   # create/reset and checkout a branch
        -l                                           # create reflog for new branch
        --guess                                      # second guess 'git checkout <no-such-branch>' (default)
        --overlay                                    # use overlay mode (default)
        --quiet(-q)                                  # suppress progress reporting
        --recurse-submodules: string                 # control recursive updating of submodules
        --progress                                   # force progress reporting
        --merge(-m)                                  # perform a 3-way merge with the new branch
        --conflict: string                           # conflict style (merge or diff3)
        --detach(-d)                                 # detach HEAD at named commit
        --track(-t)                                  # set upstream info for new branch
        --force(-f)                                  # force checkout (throw away local modifications)
        --orphan: string                             # new unparented branch
        --overwrite-ignore                           # update ignored files (default)
        --ignore-other-worktrees                     # do not check if another worktree is holding the given ref
        --ours(-2)                                   # checkout our version for unmerged files
        --theirs(-3)                                 # checkout their version for unmerged files
        --patch(-p)                                  # select hunks interactively
        --ignore-skip-worktree-bits                  # do not limit pathspecs to sparse entries only
        --pathspec-from-file: string                 # read pathspec from file
    ]

    # Git push with completions
    export extern "git push" [
        remote?: string@"nu-complete git remotes"   # the name of the remote
        refspec?: string@"nu-complete git branches" # the branch / refspec
        --all                                        # push all refs
        --atomic                                     # request atomic transaction on remote side
        --delete(-d)                                 # delete refs
        --dry-run(-n)                                # dry run
        --exec: string                               # receive pack program
        --force-with-lease: string                   # require old value of ref to be at this value
        --force(-f)                                  # force updates
        --ipv4(-4)                                   # use IPv4 addresses only
        --ipv6(-6)                                   # use IPv6 addresses only
        --mirror                                     # mirror all refs
        --no-verify                                  # bypass pre-push hook
        --porcelain                                  # machine-readable output
        --progress                                   # force progress reporting
        --prune                                      # prune locally removed refs
        --push-option(-o): string                    # option to transmit
        --quiet(-q)                                  # be more quiet
        --receive-pack: string                       # receive pack program
        --recurse-submodules: string                 # control recursive pushing of submodules
        --repo: string                               # repository
        --set-upstream(-u)                           # set upstream for git pull/status
        --signed: string                             # GPG sign the push
        --tags                                       # push tags (can't be used with --all or --mirror)
        --thin                                       # use thin pack
        --verbose(-v)                                # be more verbose
    ]

    # Docker container completions
    def "nu-complete docker containers" [] {
        ^docker ps -a --format "{{.Names}}" | lines
    }

    # Docker image completions
    def "nu-complete docker images" [] {
        ^docker images --format "{{.Repository}}:{{.Tag}}" | lines
    }

    export extern "docker start" [
        container: string@"nu-complete docker containers"  # Container name or ID
        --attach(-a)                                        # Attach STDOUT/STDERR and forward signals
        --checkpoint: string                                # Restore from this checkpoint
        --checkpoint-dir: string                            # Use a custom checkpoint storage directory
        --detach-keys: string                               # Override the key sequence for detaching
        --interactive(-i)                                   # Attach container's STDIN
    ]

    export extern "docker stop" [
        container: string@"nu-complete docker containers"  # Container name or ID
        --time(-t): int                                     # Seconds to wait before killing
    ]
}

let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}

let fish_completer = {|spans|
    fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {|row|
      let value = $row.value
      let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
      if ($need_quote and ($value | path exists)) {
        let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
        $'"($expanded_path | str replace --all "\"" "\\\"")"'
      } else {$value}
    }
}

let multiple_completers = {|spans|
    match $spans.0 {
        fish => $fish_completer
        completer => $carapace_completer
        #git => $git_completer
        #_ => $default_completer
    } | do $in $spans
}

# ====================================================================
# MAIN CONFIGURATION
# ====================================================================

$env.config = {
    # Theme selection (use $dark_theme or $light_theme)
    color_config: $dark_theme

    # Whether to use ANSI coloring
    use_ansi_coloring: true

    # Whether to show welcome banner at startup
    show_banner: false

    # Edit mode: emacs or vi
    edit_mode: emacs

    # Float precision for displaying floats in tables
    float_precision: 2

    # Footer mode for table display: "always", "never", "number_of_rows", "auto"
    footer_mode: 25

    # Render right prompt on last line
    render_right_prompt_on_last_line: false

    # Use kitty protocol for keyboard enhancement
    use_kitty_protocol: false

    # Highlight hints with the specified style
    highlight_resolved_externals: false

    # Cursor shape configuration
    cursor_shape: {
        emacs: line      # line, block, underscore, blink_line, blink_block, blink_underscore
        vi_insert: line
        vi_normal: block
    }

    # ================================================================
    # TABLE CONFIGURATION
    # ================================================================
    table: {
        mode: rounded  # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
        index_mode: always  # always, never, auto
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping  # wrapping, truncating
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
        header_on_separator: false
    }

    # ================================================================
    # SHELL INTEGRATION (Terminal features)
    # ================================================================
    shell_integration: {
        # OSC2: abbreviates path in home_dir, sets tab/window title
        osc2: true

        # OSC7: communicates path to terminal (spawning new tabs in same directory)
        osc7: true

        # OSC8: shows clickable links in ls output
        osc8: true

        # OSC9_9: from ConEmu, communicates path to terminal
        osc9_9: false

        # OSC133: terminal markers for prompt, command, and output
        osc133: true

        # OSC633: VSCode-specific terminal integration
        osc633: true

        # Reset terminal application mode after execution
        reset_application_mode: true
    }

    # ================================================================
    # HISTORY CONFIGURATION
    # ================================================================
    history: {
        max_size: 100_000  # Session has to be reloaded for this to take effect
        sync_on_enter: true  # Share history between multiple sessions
        file_format: "sqlite"  # "sqlite" or "plaintext"
        isolation: false  # Only available with sqlite. true = isolated per session, false = shared
    }

    # ================================================================
    # COMPLETIONS CONFIGURATION
    # ================================================================
    completions: {
        case_sensitive: false  # Case-sensitive completions
        quick: true  # Auto-select when only one completion remains
        partial: true  # Partial filling of the prompt
        algorithm: "fuzzy"  # "prefix" or "fuzzy"
        external: {
            enable: true  # External completions from commands
            max_results: 100  # Max number of results
            completer: null  # Custom completer command
        }
    }

    # ================================================================
    # KEYBINDINGS
    # ================================================================
    keybindings: [
        # Tab completion
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                ]
            }
        }
        # Shift+Tab for previous completion
        {
            name: completion_previous_menu
            modifier: shift
            keycode: backtab
            mode: [emacs vi_normal vi_insert]
            event: { send: menuprevious }
        }
        # Ctrl+R for history search
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs vi_insert vi_normal]
            event: { send: menu name: history_menu }
        }
        # F1 for help menu
        {
            name: help_menu
            modifier: none
            keycode: f1
            mode: [emacs vi_insert vi_normal]
            event: { send: menu name: help_menu }
        }
        # Ctrl+X for next page in menu
        {
            name: next_page_menu
            modifier: control
            keycode: char_x
            mode: emacs
            event: { send: menupagenext }
        }
        # Ctrl+U for undo or previous page
        {
            name: undo_or_previous_page
            modifier: control
            keycode: char_u
            mode: emacs
            event: {
                until: [
                    { send: menupageprevious }
                    { edit: undo }
                ]
            }
        }
        # Ctrl+Y for yank (paste)
        {
            name: yank
            modifier: control
            keycode: char_y
            mode: emacs
            event: {
                until: [
                    { edit: pastecutbufferafter }
                ]
            }
        }
        # Ctrl+Z for unix-line-discard
        {
            name: unix_line_discard
            modifier: control
            keycode: char_z
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { edit: cutfromlinestart }
                ]
            }
        }
        # Ctrl+K for kill-line
        {
            name: kill_line
            modifier: control
            keycode: char_k
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { edit: cuttolineend }
                ]
            }
        }
        # Ctrl+W to delete word backwards
        {
            name: delete_word_backward
            modifier: control
            keycode: char_w
            mode: [emacs vi_insert]
            event: { edit: backspaceword }
        }
        # Alt+D to delete word forward
        {
            name: delete_word_forward
            modifier: alt
            keycode: char_d
            mode: [emacs vi_insert]
            event: { edit: deleteword }
        }
        # Ctrl+A to move to start of line
        {
            name: move_to_line_start
            modifier: control
            keycode: char_a
            mode: [emacs]
            event: { edit: movetolinestart }
        }
        # Ctrl+E to move to end of line
        {
            name: move_to_line_end
            modifier: control
            keycode: char_e
            mode: [emacs]
            event: { edit: movetolineend }
        }
    ]

    # ================================================================
    # MENUS CONFIGURATION
    # ================================================================
    menus: [
        # Completion menu
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        # History menu
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        # Help menu
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        # Commands menu (custom menu with source)
        {
            name: commands_menu
            only_buffer_difference: false
            marker: "# "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
            source: { |buffer, position|
                $nu.scope.commands
                | where name =~ $buffer
                | each { |it| {value: $it.name description: $it.usage} }
            }
        }
        # Variables menu
        {
            name: vars_menu
            only_buffer_difference: true
            marker: "# "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
            source: { |buffer, position|
                $nu.scope.vars
                | where name =~ $buffer
                | sort-by name
                | each { |it| {value: $it.name description: $it.type} }
            }
        }
    ]

    # ================================================================
    # HOOKS CONFIGURATION
    # ================================================================
    hooks: {
        pre_prompt: [
            {||
                # Run before the prompt is shown
                null
            }
        ]
        pre_execution: [
            {||
                # Run before the REPL input is run
                null
            }
        ]
        env_change: {
            PWD: [
                {|before, after|
                    # Run when PWD environment changes
                    null
                }
            ]
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }"
        command_not_found: {||
            null  # Can be used to implement custom command-not-found handlers
        }
    }

    # ================================================================
    # DATETIME FORMAT
    # ================================================================
    datetime_format: {
        normal: '%a, %d %b %Y %H:%M:%S %z'
        table: '%m/%d/%y %I:%M:%S%p'
    }

    # ================================================================
    # EXPLORE COMMAND CONFIGURATION
    # ================================================================
    explore: {
        status_bar_background: { fg: "#1D1F21", bg: "#C4C9C6" }
        command_bar_text: { fg: "#C4C9C6" }
        highlight: { fg: "black", bg: "yellow" }
        status: {
            error: { fg: "white", bg: "red" }
            warn: {}
            info: {}
        }
        table: {
            split_line: { fg: "#404040" }
            selected_cell: { bg: light_blue }
            selected_row: {}
            selected_column: {}
        }
    }

    # ================================================================
    # ERROR HANDLING
    # ================================================================
    error_style: "fancy"  # "plain" or "fancy"
}

# ====================================================================
# CUSTOM ALIASES
# ====================================================================

# Common shortcuts
alias ls = ls --du
alias ll = ls -l
alias la = ls -a
alias lla = ls -la
alias cls = clear
alias q = exit
alias zed = zeditor

# Git shortcuts
alias gin = git init
alias gs = git status
alias ga = git add
alias gc = git commit
alias gp = git push
alias gl = git pull -rebase
alias gd = git diff
alias gco = git checkout
alias gb = git branch
alias glog = git log --oneline --graph --decorate

# Docker shortcuts
alias d = docker
alias dc = docker compose up -d
alias dd = docker compose down
alias dps = docker ps
alias dpsa = docker ps -a
alias di = docker images
alias dex = docker exec -it
alias dlogs = docker logs -f

# ====================================================================
# UV (ASTRAL) ALIASES FOR NUSHELL
# Modern Python package management with uv
# ====================================================================

# --------------------------------------------------------------------
# VIRTUAL ENVIRONMENT MANAGEMENT
# --------------------------------------------------------------------

alias deactivate = overlay hide activate

# Create a new virtual environment
alias uv-init = uv venv
alias uv-create = uv venv .venv

# --------------------------------------------------------------------
# PACKAGE INSTALLATION
# --------------------------------------------------------------------
# Basic installation
alias uvi = uv pip install
alias uvie = uv pip install -e .  # Install current project in editable mode
alias uvr = uv pip install -r requirements.txt

# UV sync (better for pyproject.toml projects)
alias uvs = uv sync  # Sync dependencies from pyproject.toml
alias uvsa = uv sync --all-extras  # Sync with all optional dependencies
alias uvse = uv sync --extra  # Sync with specific extra (needs argument)
alias uvsd = uv sync --dev  # Sync with dev dependencies

# Add dependencies (modifies pyproject.toml)
alias uva = uv add  # Add a package to pyproject.toml
alias uvad = uv add --dev  # Add dev dependency
alias uvae = uv add --optional  # Add optional dependency

# --------------------------------------------------------------------
# PACKAGE REMOVAL
# --------------------------------------------------------------------
alias uvui = uv pip uninstall
alias uvrm = uv remove  # Remove from pyproject.toml

# --------------------------------------------------------------------
# PACKAGE INFORMATION
# --------------------------------------------------------------------
alias uvls = uv pip list
alias uvlsj = uv pip list --format json
alias uvf = uv pip freeze
alias uvshow = uv pip show
alias uvcheck = uv pip check

# Tree view (if available)
alias uvtree = uv pip tree

# --------------------------------------------------------------------
# UV RUN COMMANDS
# --------------------------------------------------------------------
alias uvrun = uv run  # Run command in UV environment
alias uvpy = uv run python  # Run Python with UV
alias uvpip = uv pip  # Direct pip commands

# --------------------------------------------------------------------
# RUFF (LINTING & FORMATTING)
# --------------------------------------------------------------------
# Setup
alias uvruff = uv add --dev ruff

# Check (lint)
alias uvrc = uv run ruff check
alias uvrcc = uv run ruff check --fix  # Check and auto-fix
alias uvrcw = uv run ruff check --watch  # Watch mode

# Format
alias uvrf = uv run ruff format
alias uvrfc = uv run ruff format --check  # Check formatting without modifying

# Combined
alias uvr-all = uv run ruff check --fix and uv run ruff format

# --------------------------------------------------------------------
# PROJECT MANAGEMENT
# --------------------------------------------------------------------
alias uvl = uv lock  # Update uv.lock file
alias uvclean = rm -rf .venv  # Remove virtual environment

# --------------------------------------------------------------------
# TESTING & QUALITY
# --------------------------------------------------------------------
# Add common dev tools
alias uv-pytest = uv add --dev pytest pytest-cov
alias uv-mypy = uv add --dev mypy
alias uv-black = uv add --dev black

# Run tests (if pytest is installed)
alias uvtest = uv run pytest
alias uvtestv = uv run pytest -v
alias uvtestc = uv run pytest --cov

# Type checking
alias uvmypy = uv run mypy .

# --------------------------------------------------------------------
# CUSTOM COMMANDS
# --------------------------------------------------------------------

# Full quality check
def uv-qa [] {
    print "🔍 Running quality checks..."
    print "\n📋 Linting..."
    uv run ruff check --fix
    print "\n🎨 Formatting..."
    uv run ruff format
    print "\n🧪 Testing..."
    uv run pytest
    print "\n✅ Quality checks complete!"
}

# Update all dependencies
def uv-update [] {
    print "📦 Updating dependencies..."
    uv lock --upgrade
    uv sync
    print "✅ Dependencies updated!"
}

# Show project info
def uv-info [] {
    print "📊 UV Project Information\n"
    print "Virtual Environment:"
    if ('.venv' | path exists) {
        print "  ✅ .venv exists"
    } else {
        print "  ❌ .venv not found"
    }
    print "\nInstalled packages:"
    uv pip list
}

# --------------------------------------------------------------------
# QUICK PACKAGE INSTALLATIONS
# --------------------------------------------------------------------

# Common data science stack
def uv-ds [] {
    uv add numpy pandas matplotlib seaborn scikit-learn jupyter notebook
    print "✅ Data science stack installed"
}

# Web development stack
def uv-web [] {
    uv add fastapi uvicorn pydantic
    uv add --dev pytest httpx
    print "✅ Web development stack installed"
}

# Nushell specific
alias config = config nu
alias cenv = config env

alias reload = nu

# ====================================================================
# CUSTOM COMMANDS
# ====================================================================

# Create a new directory and cd into it
def mkcd [name: string] {
    mkdir $name
    cd $name
}

# Show file with syntax highlighting (requires bat)
def show [file: string] {
    if (which bat | is-empty) {
        open $file
    } else {
        ^bat $file
    }
}

# Quick search in current directory
def qfind [pattern: string] {
    ls **/* | where name =~ $pattern
}

# Git commit with message
def gcom [message: string] {
    git add .
    git commit -m $message
}

# Extract various archive formats
def extract [file: string] {
    match ($file | path parse | get extension) {
        "zip" => { ^unzip $file }
        "tar" => { ^tar -xf $file }
        "gz" => { ^tar -xzf $file }
        "bz2" => { ^tar -xjf $file }
        "xz" => { ^tar -xJf $file }
        "7z" => { ^7z x $file }
        "rar" => { ^unrar x $file }
        _ => { print $"Unsupported archive format: ($file)" }
    }
}

# Get weather (requires curl and wttr.in)
def weather [location?: string] {
    if ($location == null) {
        ^curl "wttr.in?format=v2"
    } else {
        ^curl $"wttr.in/($location)?format=v2"
    }
}

# Quick note-taking
def note [text: string] {
    let note_file = ($env.HOME | path join "notes.txt")
    let timestamp = (date now | format date "%Y-%m-%d %H:%M:%S")
    $"[($timestamp)] ($text)\n" | save --append $note_file
    print $"Note saved to ($note_file)"
}

# ====================================================================
# PROMPT CONFIGURATION
# ====================================================================

# Custom prompt (uncomment and customize as needed)
# $env.PROMPT_COMMAND = {||
#     let dir = (
#         if ($env.PWD == $env.HOME) {
#             "~"
#         } else {
#             $env.PWD | path basename
#         }
#     )
#
#     let git_branch = (
#         do -i {
#             ^git branch --show-current
#         } | complete | get stdout | str trim
#     )
#
#     if ($git_branch | is-empty) {
#         $"(ansi green)($dir)(ansi reset) "
#     } else {
#         $"(ansi green)($dir) (ansi cyan)on (ansi yellow)($git_branch)(ansi reset) "
#     }
# }

# $env.PROMPT_INDICATOR = {|| "> " }
# $env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
# $env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
# $env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# ====================================================================
# ENVIRONMENT VARIABLES
# ====================================================================

# Add custom paths (example)
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/usr/local/bin')

# Set default editor
$env.EDITOR = "zeditor"

# Set locale
$env.LANG = "en_US.UTF-8"

# ====================================================================
# STARTUP COMMANDS
# ====================================================================

# Print a welcome message (if show_banner is false)
# print "Welcome to Nushell! 🚀"

# Load custom modules from autoload directory
# use std *

# Source additional configuration files
# source ~/.config/nushell/custom.nu

# ====================================================================
# ADDITIONAL NOTES
# ====================================================================

# To reload this configuration: source $nu.config-path
# To edit this file: config nu
# To edit environment file: config env
# To see all config options: $env.config
# To get config documentation: config nu --doc

# For themes, visit: https://github.com/nushell/nu_scripts/tree/main/themes
# For more completions: https://github.com/nushell/nu_scripts/tree/main/custom-completions
