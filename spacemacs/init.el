;; -*- mode: emacs-lisp; lexical-binding: t -*-
;; Spacemacs dotfile for ALL machines (macOS laptop, Linux boxes, containers).
;; Spacemacs loads this file because ~/.spacemacs.d/init.el exists.
;;
;; Layout of this file (search for the ";;;; " headers):
;;   dotspacemacs/layers        which layers / packages are used
;;   dotspacemacs/init          Spacemacs settings (theme, font, keys ...)
;;   dotspacemacs/user-env      environment variables
;;   dotspacemacs/user-init     code that must run BEFORE packages load
;;   dotspacemacs/user-config   everything else (keys, python, rust, perf)

(defun dotspacemacs/layers ()
  "Layer configuration:
This function should only modify configuration layer settings."
  (setq-default
   ;; Base distribution to use. This is a layer contained in the directory
   ;; `+distribution'. For now available distributions are `spacemacs-base'
   ;; or `spacemacs'. (default 'spacemacs)
   dotspacemacs-distribution 'spacemacs

   ;; Lazy installation of layers (i.e. layers are installed only when a file
   ;; with a supported type is opened). Possible values are `all', `unused'
   ;; and `nil'. `unused' will lazy install only unused layers (i.e. layers
   ;; not listed in variable `dotspacemacs-configuration-layers'), `all' will
   ;; lazy install any layer that support lazy installation even the layers
   ;; listed in `dotspacemacs-configuration-layers'. `nil' disable the lazy
   ;; installation feature and you have to explicitly list a layer in the
   ;; variable `dotspacemacs-configuration-layers' to install it.
   ;; (default 'unused)
   dotspacemacs-enable-lazy-installation 'unused

   ;; If non-nil then Spacemacs will ask for confirmation before installing
   ;; a layer lazily. (default t)
   dotspacemacs-ask-for-lazy-installation t

   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (i.e. "~/.mycontribs/")
   dotspacemacs-configuration-layer-path '()

   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(
     ;; ---- core ------------------------------------------------------
     helm
     auto-completion
     better-defaults
     emacs-lisp
     git
     markdown
     json
     multiple-cursors
     org

     ;; ---- private layers (in ~/.spacemacs.d/layers) -----------------
     sdefaults
     sdired

     ;; ---- languages -------------------------------------------------
     c-c++
     cmake
     ;; Python IDE = basedpyright (types, completion, goto, hover, rename)
     ;; + ruff server (lint, format, imports), both through lsp-mode.
     ;; Details and the pylsp fallback: ";;;; Python" in user-config.
     (python :variables
             python-backend 'lsp
             python-lsp-server 'pyright   ; the pyright client runs basedpyright
             python-formatter 'lsp        ; SPC m = =  -> ruff format
             python-format-on-save nil
             python-sort-imports-on-save nil
             python-test-runner 'pytest
             python-fill-column 65)       ; same as line-length in ruff.toml
     rust
     html
     yaml
     javascript
     sql
     csv
     docker
     (latex :variables
            latex-backend 'company-auctex)

     ;; ---- tooling ---------------------------------------------------
     ;; `semantic' was removed on purpose: it parsed every Python/C buffer
     ;; in Emacs Lisp (one of the freeze sources). The `, p' header-line
     ;; toggle still enables semantic lazily when you ask for it.
     (lsp :variables
          ;; -- the settings that stop freezes on vllm/verl/Megatron --
          ;; Do not make Emacs watch every file of the workspace: on a
          ;; 50k-file repo that is a long synchronous directory walk and,
          ;; on macOS, one kqueue descriptor per directory.
          lsp-enable-file-watchers nil
          ;; Debounce edits before talking to the server (0.0 meant a
          ;; request on every keystroke).
          lsp-idle-delay 0.5
          ;; Code lenses re-query the server after every change.
          lsp-lens-enable nil
          ;; -- lighter, quieter --
          lsp-keep-workspace-alive nil   ; stop the server with its last buffer
          lsp-enable-suggest-server-download nil ; we install servers ourselves
          lsp-log-io nil
          lsp-headerline-breadcrumb-enable t)
     spell-checking
     syntax-checking)

   ;; List of additional packages that will be installed without being wrapped
   ;; in a layer (generally the packages are installed only and should still be
   ;; loaded using load/require/use-package in the user-config section below in
   ;; this file). If you need some configuration for these packages, then
   ;; consider creating a layer. You can also put the configuration in
   ;; `dotspacemacs/user-config'. To use a local version of a package, use the
   ;; `:location' property: '(your-package :location "~/path/to/your-package/")
   ;; Also include the dependencies as they will not be resolved automatically.
   dotspacemacs-additional-packages '(sqlite3)

   ;; A list of packages that cannot be updated.
   dotspacemacs-frozen-packages '()

   ;; A list of packages that will not be installed and loaded.
   ;; importmagic: the python layer turns it on in every python buffer; it
   ;;   starts a Python indexer per buffer and scans site-packages. lsp does
   ;;   auto-import now.
   ;; anaconda-mode / company-anaconda: the non-lsp python backend, unused.
   dotspacemacs-excluded-packages '(importmagic
                                    anaconda-mode
                                    company-anaconda)

   ;; Defines the behaviour of Spacemacs when installing packages.
   ;; Possible values are `used-only', `used-but-keep-unused' and `all'.
   ;; `used-only' installs only explicitly used packages and deletes any unused
   ;; packages as well as their unused dependencies. `used-but-keep-unused'
   ;; installs only the used packages but won't delete unused ones. `all'
   ;; installs *all* packages supported by Spacemacs and never uninstalls them.
   ;; (default is `used-only')
   ;;
   ;; `used-but-keep-unused' on purpose: switching between this dotfile and an
   ;; older one must never make Spacemacs delete packages the other one needs.
   dotspacemacs-install-packages 'used-but-keep-unused))

(defun dotspacemacs/init ()
  "Initialization:
This function is called at the very beginning of Spacemacs startup,
before layer configuration.
It should only modify the values of Spacemacs settings."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; If non-nil then enable support for the portable dumper. You'll need to
   ;; compile Emacs 27 from source following the instructions in file
   ;; EXPERIMENTAL.org at to root of the git repository.
   ;;
   ;; WARNING: pdumper does not work with Native Compilation, so it's disabled
   ;; regardless of the following setting when native compilation is in effect.
   ;;
   ;; (default nil)
   dotspacemacs-enable-emacs-pdumper nil

   ;; Name of executable file pointing to emacs 27+. This executable must be
   ;; in your PATH.
   ;; (default "emacs")
   dotspacemacs-emacs-pdumper-executable-file "emacs"

   ;; Name of the Spacemacs dump file. This is the file will be created by the
   ;; portable dumper in the cache directory under dumps sub-directory.
   ;; To load it when starting Emacs add the parameter `--dump-file'
   ;; when invoking Emacs 27.1 executable on the command line, for instance:
   ;;   ./emacs --dump-file=$HOME/.emacs.d/.cache/dumps/spacemacs-27.1.pdmp
   ;; (default (format "spacemacs-%s.pdmp" emacs-version))
   dotspacemacs-emacs-dumper-dump-file (format "spacemacs-%s.pdmp" emacs-version)

   ;; If non-nil ELPA repositories are contacted via HTTPS whenever it's
   ;; possible. Set it to nil if you have no way to use HTTPS in your
   ;; environment, otherwise it is strongly recommended to let it set to t.
   ;; This variable has no effect if Emacs is launched with the parameter
   ;; `--insecure' which forces the value of this variable to nil.
   ;; (default t)
   dotspacemacs-elpa-https t

   ;; Maximum allowed time in seconds to contact an ELPA repository.
   ;; (default 5)
   dotspacemacs-elpa-timeout 5

   ;; Set `gc-cons-threshold' and `gc-cons-percentage' when startup finishes.
   ;; This is an advanced option and should not be changed unless you suspect
   ;; performance issues due to garbage collection operations.
   ;; (default '(100000000 0.1))
   dotspacemacs-gc-cons '(100000000 0.1)

   ;; Set `read-process-output-max' when startup finishes.
   ;; This defines how much data is read from a foreign process.
   ;; Setting this >= 1 MB should increase performance for lsp servers
   ;; in emacs 27.
   ;; (default (* 1024 1024))
   dotspacemacs-read-process-output-max (* 1024 1024)

   ;; If non-nil then Spacelpa repository is the primary source to install
   ;; a locked version of packages. If nil then Spacemacs will install the
   ;; latest version of packages from MELPA. Spacelpa is currently in
   ;; experimental state please use only for testing purposes.
   ;; (default nil)
   dotspacemacs-use-spacelpa nil

   ;; If non-nil then verify the signature for downloaded Spacelpa archives.
   ;; (default t)
   dotspacemacs-verify-spacelpa-archives t

   ;; If non-nil then spacemacs will check for updates at startup
   ;; when the current branch is not `develop'. Note that checking for
   ;; new versions works via git commands, thus it calls GitHub services
   ;; whenever you start Emacs. (default nil)
   dotspacemacs-check-for-update nil

   ;; If non-nil, a form that evaluates to a package directory. For example, to
   ;; use different package directories for different Emacs versions, set this
   ;; to `emacs-version'. (default 'emacs-version)
   ;;
   ;; The macOS install keeps its packages in the flat layout
   ;; (~/.emacs.d/elpa/develop/), newer installs use the per-Emacs-version
   ;; layout (~/.emacs.d/elpa/<version>/develop/). Pick whichever already
   ;; exists so that switching dotfiles never triggers a full re-download.
   dotspacemacs-elpa-subdirectory
   (if (file-directory-p (expand-file-name (concat "elpa/" emacs-version)
                                           user-emacs-directory))
       'emacs-version
     nil)

   ;; One of `vim', `emacs' or `hybrid'.
   ;; `hybrid' is like `vim' except that `insert state' is replaced by the
   ;; `hybrid state' with `emacs' key bindings. The value can also be a list
   ;; with `:variables' keyword (similar to layers). Check the editing styles
   ;; section of the documentation for details on available variables.
   ;; (default 'vim)
   dotspacemacs-editing-style 'vim

   ;; If non-nil show the version string in the Spacemacs buffer. It will
   ;; appear as (spacemacs version)@(emacs version)
   ;; (default t)
   dotspacemacs-startup-buffer-show-version t

   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed. (default 'official)
   dotspacemacs-startup-banner 'official

   ;; Scale factor controls the scaling (size) of the startup banner. Default
   ;; value is `auto' for scaling the logo automatically to fit all buffer
   ;; contents, to a maximum of the full image height and a minimum of 3 line
   ;; heights. If set to a number (int or float) it is used as a constant
   ;; scaling factor for the default logo size.
   dotspacemacs-startup-banner-scale 'auto

   ;; List of items to show in startup buffer or an association list of
   ;; the form `(list-type . list-size)`. If nil then it is disabled.
   ;; Possible values for list-type are:
   ;; `recents' `recents-by-project' `bookmarks' `projects' `agenda' `todos'.
   ;; List sizes may be nil, in which case
   ;; `spacemacs-buffer-startup-lists-length' takes effect.
   ;; The exceptional case is `recents-by-project', where list-type must be a
   ;; pair of numbers, e.g. `(recents-by-project . (7 .  5))', where the first
   ;; number is the project limit and the second the limit on the recent files
   ;; within a project.
   dotspacemacs-startup-lists '((recents . 5)
                                (projects . 7))

   ;; True if the home buffer should respond to resize events. (default t)
   dotspacemacs-startup-buffer-responsive t

   ;; Show numbers before the startup list lines. (default t)
   dotspacemacs-show-startup-list-numbers t

   ;; The minimum delay in seconds between number key presses. (default 0.4)
   dotspacemacs-startup-buffer-multi-digit-delay 0.4

   ;; If non-nil, show file icons for entries and headings on Spacemacs home buffer.
   ;; This has no effect in terminal or if "all-the-icons" package or the font
   ;; is not installed. (default nil)
   dotspacemacs-startup-buffer-show-icons nil

   ;; Default major mode for a new empty buffer. Possible values are mode
   ;; names such as `text-mode'; and `nil' to use Fundamental mode.
   ;; (default `text-mode')
   dotspacemacs-new-empty-buffer-major-mode 'text-mode

   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'text-mode

   ;; If non-nil, *scratch* buffer will be persistent. Things you write down in
   ;; *scratch* buffer will be saved and restored automatically.
   dotspacemacs-scratch-buffer-persistent nil

   ;; If non-nil, `kill-buffer' on *scratch* buffer
   ;; will bury it instead of killing.
   dotspacemacs-scratch-buffer-unkillable nil

   ;; Initial message in the scratch buffer, such as "Welcome to Spacemacs!"
   ;; (default nil)
   dotspacemacs-initial-scratch-message nil

   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press `SPC T n' to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes '(tsdh-dark
                         spacemacs-dark
                         spacemacs-light)

   ;; Set the theme for the Spaceline. Supported themes are `spacemacs',
   ;; `all-the-icons', `custom', `doom', `vim-powerline' and `vanilla'. The
   ;; first three are spaceline themes. `doom' is the doom-emacs mode-line.
   ;; `vanilla' is default Emacs mode-line. `custom' is a user defined themes,
   ;; refer to the DOCUMENTATION.org for more info on how to create your own
   ;; spaceline theme. Value can be a symbol or list with additional properties.
   ;; (default '(spacemacs :separator wave :separator-scale 1.5))
   dotspacemacs-mode-line-theme '(spacemacs :separator wave :separator-scale 1.5)

   ;; If non-nil the cursor color matches the state color in GUI Emacs.
   ;; (default t)
   dotspacemacs-colorize-cursor-according-to-state t

   ;; Default font or prioritized list of fonts. This setting has no effect when
   ;; running Emacs in terminal. The font set here will be used for default and
   ;; fixed-pitch faces. The `:size' can be specified as
   ;; a non-negative integer (pixel size), or a floating-point (point size).
   ;; Point size is recommended, because it's device independent. (default 10.0)
   ;;
   ;; Size 22 is what the old config ended up with (it set 18 here and then
   ;; forced 22 from a layer). Fallback fonts are for Linux boxes.
   dotspacemacs-default-font '(("Source Code Pro"
                                :size 22
                                :weight normal
                                :width normal)
                               ("DejaVu Sans Mono"
                                :size 22
                                :weight normal
                                :width normal)
                               ("Menlo"
                                :size 22
                                :weight normal
                                :width normal))

   ;; The leader key (default "SPC")
   dotspacemacs-leader-key "SPC"

   ;; The key used for Emacs commands `M-x' (after pressing on the leader key).
   ;; (default "SPC")
   dotspacemacs-emacs-command-key "SPC"

   ;; The key used for Vim Ex commands (default ":")
   dotspacemacs-ex-command-key ":"

   ;; The leader key accessible in `emacs state' and `insert state'
   ;; (default "M-m")
   dotspacemacs-emacs-leader-key "M-m"

   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it. (default ",")
   dotspacemacs-major-mode-leader-key ","

   ;; Major mode leader key accessible in `emacs state' and `insert state'.
   ;; (default "C-M-m" for terminal mode, "<M-return>" for GUI mode).
   ;; Thus M-RET should work as leader key in both GUI and terminal modes.
   ;; C-M-m also should work in terminal mode, but not in GUI mode.
   dotspacemacs-major-mode-emacs-leader-key (if window-system "<M-return>" "C-M-m")

   ;; These variables control whether separate commands are bound in the GUI to
   ;; the key pairs `C-i', `TAB' and `C-m', `RET'.
   ;; Setting it to a non-nil value, allows for separate commands under `C-i'
   ;; and TAB or `C-m' and `RET'.
   ;; In the terminal, these pairs are generally indistinguishable, so this only
   ;; works in the GUI. (default nil)
   dotspacemacs-distinguish-gui-tab nil

   ;; Name of the default layout (default "Default")
   dotspacemacs-default-layout-name "Default"

   ;; If non-nil the default layout name is displayed in the mode-line.
   ;; (default nil)
   dotspacemacs-display-default-layout nil

   ;; If non-nil then the last auto saved layouts are resumed automatically upon
   ;; start. (default nil)
   dotspacemacs-auto-resume-layouts nil

   ;; If non-nil, auto-generate layout name when creating new layouts. Only has
   ;; effect when using the "jump to layout by number" commands. (default nil)
   dotspacemacs-auto-generate-layout-names nil

   ;; Size (in MB) above which spacemacs will prompt to open the large file
   ;; literally to avoid performance issues. Opening a file literally means that
   ;; no major mode or minor modes are active. (default is 1)
   dotspacemacs-large-file-size 1

   ;; Location where to auto-save files. Possible values are `original' to
   ;; auto-save the file in-place, `cache' to auto-save the file to another
   ;; file stored in the cache directory and `nil' to disable auto-saving.
   ;; (default 'cache)
   dotspacemacs-auto-save-file-location 'cache

   ;; Maximum number of rollback slots to keep in the cache. (default 5)
   dotspacemacs-max-rollback-slots 5

   ;; If non-nil, the paste transient-state is enabled. While enabled, after you
   ;; paste something, pressing `C-j' and `C-k' several times cycles through the
   ;; elements in the `kill-ring'. (default nil)
   dotspacemacs-enable-paste-transient-state nil

   ;; Which-key delay in seconds. The which-key buffer is the popup listing
   ;; the commands bound to the current keystroke sequence. (default 0.4)
   dotspacemacs-which-key-delay 0.4

   ;; Which-key frame position. Possible values are `right', `bottom' and
   ;; `right-then-bottom'. right-then-bottom tries to display the frame to the
   ;; right; if there is insufficient space it displays it at the bottom.
   ;; It is also possible to use a posframe with the following cons cell
   ;; `(posframe . position)' where position can be one of `center',
   ;; `top-center', `bottom-center', `top-left-corner', `top-right-corner',
   ;; `top-right-corner', `bottom-left-corner' or `bottom-right-corner'
   ;; (default 'bottom)
   dotspacemacs-which-key-position 'bottom

   ;; Control where `switch-to-buffer' displays the buffer. If nil,
   ;; `switch-to-buffer' displays the buffer in the current window even if
   ;; another same-purpose window is available. If non-nil, `switch-to-buffer'
   ;; displays the buffer in a same-purpose window even if the buffer can be
   ;; displayed in the current window. (default nil)
   dotspacemacs-switch-to-buffer-prefers-purpose nil

   ;; If non-nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil to boost the loading time. (default t)
   dotspacemacs-loading-progress-bar t

   ;; If non-nil the frame is fullscreen when Emacs starts up. (default nil)
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup nil

   ;; If non-nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil

   ;; If non-nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default t) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup t

   ;; If non-nil the frame is undecorated when Emacs starts up. Combine this
   ;; variable with `dotspacemacs-maximized-at-startup' to obtain fullscreen
   ;; without external boxes. Also disables the internal border. (default nil)
   dotspacemacs-undecorated-at-startup nil

   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-active-transparency 90

   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-inactive-transparency 90

   ;; A value from the range (0..100), in increasing opacity, which describes the
   ;; transparency level of a frame background when it's active or selected. Transparency
   ;; can be toggled through `toggle-background-transparency'. (default 90)
   dotspacemacs-background-transparency 90

   ;; If non-nil show the titles of transient states. (default t)
   dotspacemacs-show-transient-state-title t

   ;; If non-nil show the color guide hint for transient state keys. (default t)
   dotspacemacs-show-transient-state-color-guide t

   ;; If non-nil unicode symbols are displayed in the mode line.
   ;; If you use Emacs as a daemon and wants unicode characters only in GUI set
   ;; the value to quoted `display-graphic-p'. (default t)
   dotspacemacs-mode-line-unicode-symbols t

   ;; If non-nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters point
   ;; when it reaches the top or bottom of the screen. (default t)
   dotspacemacs-smooth-scrolling t

   ;; Show the scroll bar while scrolling. The auto hide time can be configured
   ;; by setting this variable to a number. (default t)
   dotspacemacs-scroll-bar-while-scrolling t

   ;; Control line numbers activation.
   ;; If set to `t', `relative' or `visual' then line numbers are enabled in all
   ;; `prog-mode' and `text-mode' derivatives. If set to `relative', line
   ;; numbers are relative. If set to `visual', line numbers are also relative,
   ;; but only visual lines are counted. For example, folded lines will not be
   ;; counted and wrapped lines are counted as multiple lines.
   ;; This variable can also be set to a property list for finer control:
   ;; '(:relative nil
   ;;   :visual nil
   ;;   :disabled-for-modes dired-mode
   ;;                       doc-view-mode
   ;;                       markdown-mode
   ;;                       org-mode
   ;;                       pdf-view-mode
   ;;                       text-mode
   ;;   :size-limit-kb 1000)
   ;; When used in a plist, `visual' takes precedence over `relative'.
   ;; (default nil)
   dotspacemacs-line-numbers t

   ;; Code folding method. Possible values are `evil', `origami' and `vimish'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'evil

   ;; Undo backend (`undo-redo', `undo-fu' or `undo-tree'). Only newer
   ;; Spacemacs reads this; the 2024 install always uses undo-tree. Kept at
   ;; undo-tree on every machine so `SPC a u' behaves the same everywhere.
   dotspacemacs-undo-system 'undo-tree

   ;; If non-nil and `dotspacemacs-activate-smartparens-mode' is also non-nil,
   ;; `smartparens-strict-mode' will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode nil

   ;; If non-nil smartparens-mode will be enabled in programming modes.
   ;; (default t)
   dotspacemacs-activate-smartparens-mode t

   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc...
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis nil

   ;; Select a scope to highlight delimiters. Possible values are `any',
   ;; `current', `all' or `nil'. Default is `all' (highlight any scope and
   ;; emphasis the current one). (default 'all)
   dotspacemacs-highlight-delimiters 'all

   ;; If non-nil, start an Emacs server if one is not already running.
   ;; (default nil)
   dotspacemacs-enable-server nil

   ;; Set the emacs server socket location.
   ;; If nil, uses whatever the Emacs default is, otherwise a directory path
   ;; like \"~/.emacs.d/server\". It has no effect if
   ;; `dotspacemacs-enable-server' is nil.
   ;; (default nil)
   dotspacemacs-server-socket-dir nil

   ;; If non-nil, advise quit functions to keep server open when quitting.
   ;; (default nil)
   dotspacemacs-persistent-server nil

   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `rg', `ag', `pt', `ack' and `grep'.
   ;; (default '("rg" "ag" "pt" "ack" "grep"))
   dotspacemacs-search-tools '("rg" "ag" "pt" "ack" "grep")

   ;; Format specification for setting the frame title.
   ;; %a - the `abbreviated-file-name', or `buffer-name'
   ;; %t - `projectile-project-name'
   ;; %I - `invocation-name'
   ;; %S - `system-name'
   ;; %U - contents of $USER
   ;; %b - buffer name
   ;; %f - visited file name
   ;; %F - frame name
   ;; %s - process status
   ;; %p - percent of buffer above top of window, or Top, Bot or All
   ;; %P - percent of buffer above bottom of window, perhaps plus Top, or Bot or All
   ;; %m - mode name
   ;; %n - Narrow if appropriate
   ;; %z - mnemonics of buffer, terminal, and keyboard coding systems
   ;; %Z - like %z, but including the end-of-line format
   ;; If nil then Spacemacs uses default `frame-title-format' to avoid
   ;; performance issues, instead of calculating the frame title by
   ;; `spacemacs/title-prepare' all the time.
   ;; (default "%I@%S")
   dotspacemacs-frame-title-format "%I@%S"

   ;; Format specification for setting the icon title format
   ;; (default nil - same as frame-title-format)
   dotspacemacs-icon-title-format nil

   ;; Color highlight trailing whitespace in all prog-mode and text-mode derived
   ;; modes such as c++-mode, python-mode, emacs-lisp, html-mode, rst-mode etc.
   ;; (default t)
   dotspacemacs-show-trailing-whitespace t

   ;; Delete whitespace while saving buffer. Possible values are `all'
   ;; to aggressively delete empty line and long sequences of whitespace,
   ;; `trailing' to delete only the whitespace at end of lines, `changed' to
   ;; delete only whitespace for changed lines or `nil' to disable cleanup.
   ;; (default nil)
   dotspacemacs-whitespace-cleanup nil

   ;; If non-nil activate `clean-aindent-mode' which tries to correct
   ;; virtual indentation of simple modes. This can interfere with mode specific
   ;; indent handling like has been reported for `go-mode'.
   ;; If it does deactivate it here.
   ;; (default t)
   dotspacemacs-use-clean-aindent-mode t

   ;; Accept SPC as y for prompts if non-nil. (default nil)
   dotspacemacs-use-SPC-as-y nil

   ;; If non-nil shift your number row to match the entered keyboard layout
   ;; (only in insert state). Currently supported keyboard layouts are:
   ;; `qwerty-us', `qwertz-de' and `querty-ca-fr'.
   ;; New layouts can be added in `spacemacs-editing' layer.
   ;; (default nil)
   dotspacemacs-swap-number-row nil

   ;; Either nil or a number of seconds. If non-nil zone out after the specified
   ;; number of seconds. (default nil)
   dotspacemacs-zone-out-when-idle nil

   ;; Run `spacemacs/prettify-org-buffer' when
   ;; visiting README.org files of Spacemacs.
   ;; (default nil)
   dotspacemacs-pretty-docs nil

   ;; If nil the home buffer shows the full path of agenda items
   ;; and todos. If non-nil only the file name is shown.
   dotspacemacs-home-shorten-agenda-source nil

   ;; If non-nil then byte-compile some of Spacemacs files.
   dotspacemacs-byte-compile nil))

(defun dotspacemacs/user-env ()
  "Environment variables setup.
This function defines the environment variables for your Emacs session. By
default it calls `spacemacs/load-spacemacs-env' which loads the environment
variables declared in `~/.spacemacs.env' or `~/.spacemacs.d/.spacemacs.env'.
See the header of this file for more information."
  (spacemacs/load-spacemacs-env))

(defun dotspacemacs/user-init ()
  "Initialization for user code:
This function is called immediately after `dotspacemacs/init', before layer
configuration.
It is mostly for variables that should be set before packages are loaded.
If you are unsure, try setting them in `dotspacemacs/user-config' first."

  ;;;; Home buffer branding
  (defconst spacemacs-buffer-name "*spacegoing*"
    "The name of the spacemacs buffer.")
  (defconst spacemacs-buffer-logo-title "[S P A C E G O I N G]"
    "The title displayed beneath the logo.")

  ;;;; Package mirrors (TUNA, China)
  (setq configuration-layer-elpa-archives
        '(("gnu-elpa-cn" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
          ("nongnu-elpa-cn" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
          ("gnu-elpa-devel-cn" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu-devel/")
          ("nongnu-elpa-devel-cn" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu-devel/")
          ("melpa-cn" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
          ("melpa-stable-cn" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/stable-melpa/")
          ("org-cn" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/org/"))))

(defun dotspacemacs/user-load ()
  "Library to load while dumping.
This function is called only while dumping Spacemacs configuration. You can
`require' or `load' the libraries of your choice that will be included in the
dump.")

(defun dotspacemacs/user-config ()
  "Configuration for user code:
This function is called at the very end of Spacemacs startup, after layer
configuration.
Put your configuration code here, except for variables that should be set
before packages are loaded."

  ;;;; General
  (add-hook 'doc-view-mode-hook 'auto-revert-mode)

  ;;;; Org
  (setq org-mobile-directory
        "~/Library/Mobile Documents/iCloud~com~mobileorg~mobileorg/Documents")
  (with-eval-after-load 'org
    (setq org-startup-indented t))
  ;; Company completion with snippets in org buffers.
  (with-eval-after-load 'company
    (add-hook 'org-mode-hook 'company-mode)
    (with-eval-after-load 'yasnippet
      (add-hook 'org-mode-hook
                (lambda ()
                  (setq-local company-backends
                              (cons 'company-yasnippet company-backends))))))

  ;;;; macOS: Homebrew PATH and GNU ls for dired
  (when (eq system-type 'darwin)
    (setenv "PATH" "/opt/homebrew/bin:$PATH" t)
    (setq exec-path (append exec-path '("/opt/homebrew/bin")))
    ;; `brew install coreutils' -- GNU ls understands --group-directories-first
    (setq insert-directory-program "/opt/homebrew/opt/coreutils/libexec/gnubin/ls"))
  (setq dired-listing-switches "-laGh1v --group-directories-first")

  ;;;; Keys: highlight (SPC h h), imenu (SPC j m / SPC j M)
  (setq hi-lock-face-defaults
        '("hi-blue" "hi-aquamarine" "hi-pink" "hi-green-b" "hi-red-b" "hi-salmon"))
  (spacemacs/declare-prefix "hh" "highlight")
  (spacemacs/set-leader-keys "hhh" 'highlight-symbol-at-point)
  (spacemacs/set-leader-keys "hhu" 'unhighlight-regexp)
  (spacemacs/set-leader-keys "jm" 'lsp-ui-imenu)
  ;; Symbol list: semantic when it is on, otherwise imenu (fed by lsp).
  (spacemacs/set-leader-keys "jM" 'helm-semantic-or-imenu)

  ;;;; Performance: undo history
  ;; undo-tree stays (u / C-r / SPC a u unchanged) but no longer writes a
  ;; history file per buffer to .cache/undo-tree-history: saving/loading
  ;; those for big buffers is slow and the files corrupt easily (1200+ had
  ;; piled up). Undo history now lives for the Emacs session only.
  (setq undo-tree-auto-save-history nil)

  ;;;; Tool directories: language servers and rust toolchain
  ;; ~/.local/bin is where scripts/install-lsp-servers.sh links basedpyright
  ;; and ruff; ~/.cargo/bin holds rust-analyzer (rustup). Put them first so
  ;; an old `ruff' inside a conda env does not shadow them.
  (dolist (dir '("~/.cargo/bin" "~/.local/bin"))
    (let ((d (expand-file-name dir)))
      (when (file-directory-p d)
        (add-to-list 'exec-path d)
        (unless (member d (split-string (getenv "PATH") path-separator))
          (setenv "PATH" (concat d path-separator (getenv "PATH")))))))

  ;;;; Python: language servers
  ;; basedpyright = pyright with a pip-installable, node-bundled build.
  ;; Install both servers with:  ~/.spacemacs.d/scripts/install-lsp-servers.sh
  ;;
  ;; What you get:        from
  ;;   completion, goto definition/references, hover, rename   basedpyright
  ;;   diagnostics: syntax errors, undefined names, bad imports basedpyright
  ;;   diagnostics: lint (F, E, I ...), SPC m = = format,
  ;;   organize imports (code action)                          ruff server
  ;;
  ;; Why not pylsp: pylsp+jedi indexes the whole workspace in-process and
  ;; hangs on vllm/verl/Megatron sized repos (your 2025 commits fought
  ;; exactly that). pylsp remains available: set python-lsp-server to 'pylsp
  ;; in dotspacemacs/layers and the tuning further down applies.

  (defvar my/python-typecheck-mode "off"
    "basedpyright typeCheckingMode: \"off\", \"basic\", \"standard\" or \"strict\".
\"off\" still reports syntax errors, undefined names and unresolved imports;
lint comes from ruff. Raise it when you want real type checking.")

  ;; These two are read when lsp-pyright registers its client, so set them
  ;; before the package loads.
  (setq lsp-pyright-multi-root nil                ; one server per project
        lsp-pyright-langserver-command "basedpyright") ; lsp-pyright >= 2024-09
  (setq lsp-pyright-diagnostic-mode "openFilesOnly" ; never analyse the whole repo
        lsp-pyright-disable-organize-imports t)     ; ruff owns imports
  (with-eval-after-load 'lsp-pyright
    ;; Which executable the pyright client starts, in order of preference.
    ;; Works for every lsp-pyright version (older ones only know
    ;; `pyright-langserver'); the npm fallback is never reached when the
    ;; install script has been run.
    (lsp-dependency 'pyright
                    '(:system "basedpyright-langserver")
                    '(:system "pyright-langserver")
                    '(:npm :package "basedpyright" :path "basedpyright-langserver"))
    (lsp-register-custom-settings
     '(("python.analysis.typeCheckingMode" my/python-typecheck-mode)
       ("basedpyright.disableOrganizeImports" t t))))

  ;; ruff's built-in language server (`ruff server', ruff >= 0.5). lsp-mode
  ;; renamed its ruff client in 2024-08; set both generations' variables.
  (setq lsp-ruff-lsp-server-command '("ruff" "server") ; client `ruff-lsp' (lsp-mode <= 2024-08)
        lsp-ruff-server-command '("ruff" "server")     ; client `ruff'     (lsp-mode >= 2024-08)
        lsp-ruff-lsp-show-notifications "off"
        lsp-ruff-show-notifications "off")

  ;; pylsp fallback tuning (only matters when python-lsp-server is 'pylsp or
  ;; basedpyright is not installed): ruff does all linting, jedi's workspace
  ;; symbol search is what hangs on large repos.
  (setq lsp-pylsp-plugins-ruff-enabled t
        lsp-pylsp-plugins-jedi-symbols-enabled nil
        lsp-pylsp-plugins-pycodestyle-enabled nil
        lsp-pylsp-plugins-pyflakes-enabled nil
        lsp-pylsp-plugins-mccabe-enabled nil
        lsp-pylsp-plugins-pydocstyle-enabled nil
        lsp-pylsp-plugins-flake8-enabled nil
        lsp-pylsp-plugins-autopep8-enabled nil
        lsp-pylsp-plugins-yapf-enabled nil
        lsp-pylsp-plugins-pylint-enabled nil
        lsp-pylsp-plugins-rope-autoimport-enabled nil)
  (when (eq python-lsp-server 'pylsp)
    ;; pylsp runs ruff as a plugin; do not start the ruff server as well.
    (with-eval-after-load 'lsp-mode
      (add-to-list 'lsp-disabled-clients 'ruff-lsp)
      (add-to-list 'lsp-disabled-clients 'ruff)))

  ;;;; Python: conda / virtualenv switching
  ;; `SPC m v w' (pyvenv-workon) lists the envs under WORKON_HOME; point it
  ;; at the conda envs directory when the shell did not set it.
  (unless (getenv "WORKON_HOME")
    (let ((envs (seq-find #'file-directory-p
                          (mapcar #'expand-file-name
                                  '("~/mambaforge/envs" "~/miniforge3/envs"
                                    "~/miniconda3/envs" "~/anaconda3/envs"
                                    "~/.conda/envs")))))
      (when envs (setenv "WORKON_HOME" envs))))
  ;; After `SPC m v w' / `SPC m v a' / `SPC m v d' restart the servers of the
  ;; current python buffer so basedpyright uses the newly selected interpreter.
  (defun my/python-lsp-restart-after-venv-change (&rest _)
    (when (and (memq this-command '(pyvenv-workon pyvenv-activate pyvenv-deactivate))
               (derived-mode-p 'python-mode)
               (bound-and-true-p lsp-mode))
      (mapc #'lsp-workspace-restart (lsp-workspaces))))
  (dolist (f '(pyvenv-workon pyvenv-activate pyvenv-deactivate))
    (advice-add f :after #'my/python-lsp-restart-after-venv-change))

  ;;;; Python: REPL
  (when (executable-find "ipython")
    (setq python-shell-interpreter "ipython"
          python-shell-interpreter-args "-i --simple-prompt"))
  (setq python-shell-completion-native-enable nil)

  ;;;; Python: keys
  ;; , h s  show the signature of the call at point
  ;; , p    toggle header line: lsp breadcrumb <-> semantic sticky function
  (spacemacs/set-leader-keys-for-major-mode 'python-mode "hs" 'lsp-signature-activate)
  (spacemacs/set-leader-keys-for-major-mode 'python-mode "p" 'my-toggle-headerline-modes)

  ;;;; Python: code cells (# %% blocks), allow indented cell markers
  (with-eval-after-load 'code-cells
    (setq code-cells-boundary-regexp
          (rx (* (syntax whitespace))
              (+ (syntax comment-start))
              (or (seq (* (syntax whitespace)) "%" (group-n 1 (+ "%")))
                  (group-n 1 (+ "*"))
                  (seq " In[" (* (any space digit)) "]:")))))
  (add-hook 'python-mode-hook 'code-cells-mode)

  ;;;; Rust: rust-analyzer through lsp-mode
  ;; rust-analyzer is the rustup component (`rustup component add
  ;; rust-analyzer'), found in ~/.cargo/bin. Diagnostics come from
  ;; `cargo check' on save; set `lsp-rust-analyzer-cargo-watch-command' to
  ;; "clippy" in local.el for clippy instead.
  (setq lsp-rust-analyzer-server-command '("rust-analyzer")
        ;; Emacs file watchers are off (see Performance); rust-analyzer
        ;; watches the workspace itself.
        lsp-rust-analyzer-use-client-watching nil
        lsp-rust-analyzer-cargo-watch-command "check"
        lsp-rust-analyzer-proc-macro-enable t
        lsp-rust-analyzer-cargo-run-build-scripts t
        ;; Format with `SPC m = =' when wanted, not on every save.
        rustic-format-on-save nil)

  ;;;; Header line toggle (, p in python buffers)
  ;; lsp's breadcrumb is shown by default. `, p' swaps it for semantic's
  ;; sticky-function header and back. semantic-mode is switched on lazily
  ;; the first time, since it is no longer enabled globally.
  (defvar my-headerline-toggle-state 'breadcrumb
    "Which header line is showing: `breadcrumb' or `stickyfunc'.")
  (defun my-toggle-headerline-modes ()
    "Toggle between lsp-headerline-breadcrumb-mode and semantic-stickyfunc-mode."
    (interactive)
    (if (eq my-headerline-toggle-state 'breadcrumb)
        (progn
          (lsp-headerline-breadcrumb-mode -1)
          (require 'semantic)
          (unless (bound-and-true-p semantic-mode) (semantic-mode 1))
          (semantic-stickyfunc-mode 1)
          (setq my-headerline-toggle-state 'stickyfunc))
      (semantic-stickyfunc-mode -1)
      (lsp-headerline-breadcrumb-mode 1)
      (setq my-headerline-toggle-state 'breadcrumb))))

;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(defun dotspacemacs/emacs-custom-settings ()
  "Emacs custom settings.
This is an auto-generated function, do not modify its content directly, use
Emacs customize menu instead.
This function is called at the very end of Spacemacs initialization."
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files nil)
 '(warning-suppress-types
   '((use-package)
     ((flycheck syntax-checker))
     ((python python-shell-completion-native-turn-on-maybe)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(highlight-parentheses-highlight ((nil (:weight ultra-bold))) t))
)
