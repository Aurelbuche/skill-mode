;; ============================================================================================================
;; skill-mode.el 
;; 
;; Major mode for editing Cadence SKILL and SKILL++
;; 
;; Author: Aurelien Buchet - aurelien.buchet@tutanota.com
;; 
;; 2017 - 2019
;; ============================================================================================================


;; ============================================================================================================
;; This file is split into different parts:
;; 
;; I. Settings
;; I. 1. Fetching Documentation from SKILL code root and Virtuoso installation path
;; I. 2. Defining Bindkeys
;; I. 3. Selecting Fonts and Faces
;; I. 4. Defining functions, macros, classes and methods to highlight
;; 
;; II. Fetch
;; II. 1. Fetching functions and forms in documentation if root is defined
;; II. 2. Fetching functions defined in user's code if root is correct
;; 
;; III. Bindkeys and Shortcuts
;; III 1. Quotations marks
;; III 2. Parentheses
;; III 3. Indent
;; III 4. Delete extra spaces
;; III 5. Communication with Virtuoso
;; 
;; IV. Mode Creation
;; IV. 1. Opening SKILL/SKILL++ files in SKILL mode
;; IV. 2. Defining Syntax Table
;; IV. 3. Highlighting keywords
;; IV. 4. Allowing hooks
;; IV. 5. Providing SKILL Major mode
;; 
;; ============================================================================================================


;; ============================================================================================================
;; I. Settings
;; ============================================================================================================
;; ------------------------------------------------------------------------------------------------------------
;; I. 1. Fetching Documentation from SKILL code root and Virtuoso installation path 
;; ------------------------------------------------------------------------------------------------------------

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-code-root
;; 
;; @doc Root of SKILL code used to fetch names to be highlighted in emacs
;; 
;; This variable should contain a path or a list of path (string or list of strings).
;; 
;; If this variable describes correct paths: all the skill files contained at the given locations will be parsed
;; (and subdirectories will be parsed recursively too if the variable skill-recursive-search is set to t) in
;; order to fetch all the defined functions, macros, classes and methods.
;; 
;; The fetched elements are then colored accordingly to their type
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-code-root '(
    ;; Strings describing directories containing SKILL code to parse
    ;"/home/bucheta1/skill/VCT/modules/Finder/skill"
    "/home/bucheta1/skill/VCT/modules/MAAL/skill"
    "/home/bucheta1/skill/VCT/modules/skillx/skill"
  ) 
  "Root of SKILL code used to fetch names to be highlighted in emacs")

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-recursive-search
;;
;; @doc If non-nil functions, forms, methods and classes will be searched recursively from skill-code-root
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-recursive-search t
  "If non-nil functions, forms, methods and classes will be searched recursively from skill-code-root")

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-virtuoso-root
;;
;; @doc Root of Cadence Virtuoso installation
;; 
;; This path is used to fetch documentation if possible
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-virtuoso-root "/sw/cadence/ic/06.17.715/lnx86"
  "Root of Cadence Virtuoso installation")

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-doc-root
;;
;; @doc Root of .fnd files containing documentation
;; 
;; This variable should contain a path or a list of path (string or list of strings).
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-doc-root '(
    ;; Strings describing directories containing .fnd files to parse
    "/sw/cadence/ic/06.17.715/lnx86/doc/finder/SKILL"
    )
  "Root of SKILL documentation (modules folders containing .fnd files)")

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-modules-highlights
;;
;; @doc List of module to highlights in SKILL mode
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-modules-highlights
  ;; The functions defined in those modules will be fetched in documentation
  ;; The modules can be defined using only a string but also with a couple:
  ;; The couple should contain the module name and the list of prefixes of the functions to fetch
  '(
    ;"ADE_Assembler"
    ;"Custom_Constraints"
    ;"Netlisting_and_Simulation"
    ;"Schematics"
    ;"ADE-L/"
    ;"Custom_Layout"
    ;"OCEAN"
    ;"Tech_File"
    ;"ADE_Verifier"
    ("DFII_SKILL" . ("db" "geGet" "db")) ;"dd"
    ;too many functions in this module for emacs
    ;"OCEAN_XL"
    ;"Text_Editor"
    ;"ADE_XL"
    ;"DIVA_SKILL"
    ;"Parasitic_Aware_Design"
    ;"Translators"
    ;"AMS_Environment"
    ;"DRACULA_GUI_SKILL"
    ;"Pcells"
    ("User_Interface" . ("hi"))
    ;"Analog_Expression"
    ;"EDIF200"
    ;"Power_IR_EM"
    ;"ViVA_SKILL"
    "Core_SKILL"
    ;"HDL_Import_and_Netlist_Conversion"
    ;"Relative_Object_Design"
    ;"Voltus-Fi-XL"
  )
  "List of modules in which functions will be fetched and highlighted when editing SKILL code"
)

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-log-path
;;
;; @doc Path of Virtuoso SKILL log to be displayed by Emacs (should be the same as defined in emacsConnects.ils)
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-log-path (concat "~/.emacs.d/.skill.log")
  "Path of Virtuoso SKILL log to be displayed by Emacs (should be the same as defined in emacsConnects.ils)")

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-emacs-prefix
;;
;; @doc String printed in Virtuoso SKILL log at the beginning of every message comming from Emacs
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-emacs-prefix "*** Emacs *** "
  "String printed in Virtuoso SKILL log at the beginning of every message comming from Emacs")

;; ------------------------------------------------------------------------------------------------------------
;; I. 2. Defining Bindkeys
;; ------------------------------------------------------------------------------------------------------------

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-map
;;
;; @doc Keymap for SKILL major mode
;; 
;; This keymap contains all the bindkeys making SKILL code edition easy
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-map
  (let ((keymap (make-keymap)) pair key callback)
    (dolist (pair '(
          ;; ------------------------------------------------------ 
          ;; Register command with 'C-x M-r'
          ;; ------------------------------------------------------
          ("C-x C-z" skill-register-command)
          ;; ------------------------------------------------------
          ;; Send register command with 'C-x r'
          ;; ------------------------------------------------------
          ;("C-x C-r" skill-send-registered-command)
          ("C-z" skill-send-registered-command)
          ;; ------------------------------------------------------ 
          ;; Inserts a pair of parentheses and places the point in
          ;; the midlle with '\('                                  
          ;; ------------------------------------------------------
          ("\(" skill-insert-parentheses)
          ;; ------------------------------------------------------
          ;; Inserts a closed parentheses or fetched the function
          ;; associated to the paired parenthese with '\)'
          ;; ------------------------------------------------------
          ("C-M-\)" skill-close-parentheses)
          ;; ------------------------------------------------------
          ;; Inserts a quotation mark or quote multiple words by
          ;; repeating '\"'
          ;; ------------------------------------------------------
          ("\"" skill-insert-quotation-marks)
          ;; ------------------------------------------------------
          ;; Newline and indent with 'return'
          ;; ------------------------------------------------------
          ("<return>" skill-newline-and-indent)
          ;; ------------------------------------------------------
          ;; Loads the current file in Virtuoso with 'C-x p'
          ;; ------------------------------------------------------
          ("C-x p" skill-load-file)
          ;; ------------------------------------------------------
          ;; Runs lint on the current file with 'C-x l'
          ;; ------------------------------------------------------
          ("C-x l" skill-lint-file)
          ;; ------------------------------------------------------
          ;; Display Virtuoso SKILL log with 'C-x C-l'
          ;; ------------------------------------------------------
          ("C-x C-l" skill-clean-log)
          ;; ------------------------------------------------------
          ;; Evaluates selected region with 'C-x C-e'
          ;; ------------------------------------------------------
          ("C-x C-e" skill-eval-region)
          ;; ------------------------------------------------------
          ;; Evaluates current buffer with 'C-x return' or
          ;; 'C-x C-return'
          ;; ------------------------------------------------------
          ("C-x RET" skill-eval-buffer)
          ("C-x <C-return>" skill-eval-buffer)
          ;; ------------------------------------------------------
          ;; Traces and untraces variables or functions with
          ;; 'C-x /' and 'C-x C-/'
          ;; ------------------------------------------------------
          ("C-x /" skill-trace)
          ("C-x C-/" skill-untrace)
          ;; ------------------------------------------------------
          ;; Dimm comments with 'C-x d'
          ;; ------------------------------------------------------
          ("C-x d" skill-dimm-comments)
          ;; ------------------------------------------------------
          ;; Launches SKILL IDE on current file with 'C-x i'
          ;; ------------------------------------------------------
          ("C-x i" skill-launch-ide)
          )) (setq key (pop pair)) (setq callback (pop pair)) (define-key keymap (eval `(kbd ,key)) callback))
    ;; Returns the keymap
    keymap) "Keymap for SKILL major mode");defvar


;; ------------------------------------------------------------------------------------------------------------
;; I. 3. Selecting Fonts and Faces
;; ------------------------------------------------------------------------------------------------------------

;; ------------------------------------------------------------------------------------------------------------
;; The fonts and faces are generated using the following list of associations, each type of highlighted word
;; has a created face using defface called skill-<type>-face
;; ------------------------------------------------------------------------------------------------------------
(let (type color slant
   ;; the following list describes each element that can be recognized in SKILL code
   ;; and the associated color in which emacs will highlight it
   (fonts '(
       ;; ------------------------------------------------------
       ;; Fonts defined by a list of strings
       ;; name, color and slant
       ;; ------------------------------------------------------
       ("class"        "firebrick")
       ("info"         "dark orange"      "italic")
       ("comment"      "DarkGoldenrod")
       ("form"         "light steel blue")
       ("function"     "Deep sky blue")
       ("keyword"      "plum")
       ("method"       "indian red")
       ("shortcut"     "chartreuse")
       ("string"       "dark salmon")
       ("symbol"       "rosy brown")
       ("syntax-form"  "light goldenrod")
       ("variable"     "medium sea green")
 )))
 ;; Create each font defined above
 (dolist (font fonts) (setq type (pop font)) (setq color (pop font)) (setq slant (pop font))
   (unless slant (setq slant "normal")) (setq slant (intern slant))
   (eval `(defface ,(intern (concat "skill-" type "-face")) '((default :foreground ,color :slant ,slant))
       ,(concat "Face of " type "s") :group 'skill-faces))
 );dolist
 );let

;; Face for tabs
(defface skill-tab-face '((default :background "red")) "Face of tabs" :group 'skill-faces)

;; ------------------------------------------------------------------------------------------------------------
;; I. 4. Defining functions, macros, classes and methods to highlight
;; ------------------------------------------------------------------------------------------------------------

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-valid-name
;;
;; @doc Regular Expression describing a valid SKILL name
;; ------------------------------------------------------------------------------------------------------------
(defconst skill-valid-name "[a-zA-Z0-9_?]+"
  "Regular Expression describing a valid SKILL Name")

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-syntax-forms
;;
;; @doc List of SKILL syntax forms and macros
;; 
;; The syntax forms are detailled here
;; Those functions have particular definitions and are part of SKILL core
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-syntax-forms '(
    ;; Strings describing forms or macros that are not fetched automatically
    "declare" "defprop" "defvar" "define" "defdynamic" 
    "getq" "getqq"
    "setf" "setq" "sett"
    "exists" "existss"
    "for" "fors" "forall" "foralls" "foreach" "foreachs"
    "while"
    "if" "ifx" "nif" 
    "setof" "setofs"
    "unless" "when"
    "measureTime"
    "sstatus" 
    "defun" "dynamic" "errset" "lambda" "let" "mprocedure" "nlambda" "nprocedure"
    "prog" "go" "return"
    "prog1" "prog2" "progn" "begin" "wrap"
    "pop" "push"
    "test" "free"
    "put" "putn" "putnq"
    ) "List of SKILL syntax forms")

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-forms
;; 
;; @doc List of SKILL forms
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-forms '(
    "car" "cdr" "caar" "cadr" "cdar" "cddr" "caaar" "caadr" "cadar" "caddr" "cdaar" "cdadr" "cddar" "cddr"
    "member" "memq" "memv"
    "sh" "shell" 
  ) "List of SKILL forms")

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-functions
;; 
;; @doc List of SKILL functions
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-functions nil
  "List of SKILL functions")

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-modules-functions
;; 
;; @doc List of SKILL functions
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-modules-functions nil
  "List of SKILL functions defined in .fnd modules")

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-classes
;; 
;; @doc List of SKILL classes
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-classes nil
  "List of SKILL classes")

;; ------------------------------------------------------------------------------------------------------------
;; @var skill-methods
;; 
;; @doc List of SKILL methods
;; ------------------------------------------------------------------------------------------------------------
(defvar skill-methods nil
  "List of SKILL methods")


;; ============================================================================================================
;; II. Fetch
;; ============================================================================================================
;; ------------------------------------------------------------------------------------------------------------
;; II. 1. Fetching functions and forms in documentation if root is defined
;; ------------------------------------------------------------------------------------------------------------

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-setof
;;
;; @doc Classic seq-filter
;; ------------------------------------------------------------------------------------------------------------
(defun skill-seq-filter (fun elts)
  (let (result) (dolist (elt elts) (when (apply fun (cons elt nil)) (push elt result))) result))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-filter-list
;;
;; @doc Returns the list of names matching the given prefixes
;;
;; @arg names
;; @type list
;; @doc Names to filter
;;
;; @arg prefixes
;; @type list
;; @doc List of prefixes
;;
;; @out names
;; @type list
;; @doc List of names matching the given prefixes
;; ------------------------------------------------------------------------------------------------------------
(defun skill-filter-list (names prefixes)
  "Returns the list of names matching prefixes"
  ;; Filters the list
  (skill-seq-filter (lambda (name)
      ;; Returns t if name matches one of the prefixes
      (eval `(or ,@(mapcar (lambda (prefix) 
              (when (> (length name) (length prefix))
                (equal prefix (substring name 0 (length prefix))))) prefixes))))
    names))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-fetch-functions
;;
;; @doc Returns the list of functions name in file which describes the path of a .fnd file
;;
;; @arg file
;; @type string
;; @doc Path of a .fnd file containing skill documentation
;;
;; @arg prefixes
;; @type list
;; @kind optional
;; @doc List of strings describing prefixes, functions of the.fnd file have to start with one of the prefixes 
;; to be fetched
;; ------------------------------------------------------------------------------------------------------------
(defun skill-fetch-functions (file &optional prefixes)
  "Returns the list of functions name in file which describes the path of a .fnd file"
  ;; Opens a new buffer to copy the .fnd file content
  (get-buffer-create "*skill-file-content*") 
  (switch-to-buffer "*skill-file-content*")
  (insert-file-contents file)
  (beginning-of-buffer)
  ;; Adds a quote at the beginning of the created buffer
  (insert "(quote (\n")
  (end-of-buffer)
  (insert "\n))")
  ;; Interprets the content of the .fnd buffer and returns the car of each expressions it contains
  (prog1 (if prefixes (skill-filter-list (mapcar 'car (eval-last-sexp "*skill-file-content*")) prefixes)
      (mapcar 'car (eval-last-sexp "*skill-file-content*")))
    ;; kills the created buffer
    (kill-buffer "*skill-file-content*"))
);defun 

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-get-documentation-directories
;;
;; @doc Returns the list of directories containing .fnd files
;;
;; @out directories
;; @type list
;; @doc List of string describing directories containing .fnd files
;; ------------------------------------------------------------------------------------------------------------
(defun skill-get-documentation-directories nil
  (let (directories)
    ;; Expands and checks all the paths in skill-doc-root, then adds the valid ones to directories
    (dolist (path skill-doc-root)
      (and (setq path (substitute-in-file-name (expand-file-name path)))
           (file-directory-p path)
           (not (member path directories))
           (push path directories)))
    ;; Fetches SKILL documentation directory from virtuoso installation root
    (when (and (boundp 'skill-virtuoso-root)
               (stringp skill-virtuoso-root)
               (file-directory-p skill-virtuoso-root))
      ;; Checks if /doc/finder/SKILL is in Virtuoso root or one of its parents
      (let ((skill-virtuoso-root skill-virtuoso-root)
            (skill-doc-root "/doc/finder/SKILL")
            split-root)
        (while (and (not (file-directory-p (concat skill-virtuoso-root skill-doc-root)))
                    (not (eq skill-virtuoso-root "")))
          ;; Goes one directory up in virtuoso root
          (setq split-root (remove "" (split-string skill-virtuoso-root "/")))
          (setq skill-virtuoso-root "") 
          (while (cdr split-root) (setq skill-virtuoso-root (concat skill-virtuoso-root "/" (pop split-root))))
        );while
        (setq skill-doc-root (substitute-in-file-name (expand-file-name 
              (concat skill-virtuoso-root skill-doc-root))))
          ;; Checks that fetched directory is valid and not already defined
        (when (and (file-directory-p skill-doc-root)
              (not (member skill-doc-root directories)))
          (push skill-doc-root directories))
      );let
    );when skill-virtuoso-root is defined
    ;; Returns the valid documentation directories
    directories
  );let
);defun

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-fetch-documentation
;;
;; @doc Browses all the documentation directories defined in skill-doc-root to add all the fetched forms and
;; functions to skill-forms and skill-functions
;; ------------------------------------------------------------------------------------------------------------
(defun skill-fetch-documentation nil
  "Fetch SKILL/SKILL++ functions in skill documentation (.fnd files)"
  (let (modules module-root functions)
    ;; Browses SKILL documentation directories
    (dolist (directory (skill-get-documentation-directories))
      ;; Fetches modules in documentation root
      (when (and (file-directory-p directory) (set 'modules (directory-files directory nil "^[a-zA-Z_]*$")))
        (dolist (module modules)
          (setq module-root (concat directory "/" module))
          ;; Fetches only modules that are defined in skill-modules-highlights
          (cond
            ;; Core functions are considered as forms
            ((equal module "Core_SKILL")
              ;; fetching all .fnd files in module then all .fnd functions in .fnd files
              (dolist (file (directory-files module-root t "^.*\.fnd$"))
                (dolist (function (skill-fetch-functions file))
                  (push function skill-forms))))
            ;; Module is defined and contains classic functions
            ((member module skill-modules-highlights)
              ;; fetching all .fnd files in module then all .fnd functions in .fnd files
              (dolist (file (directory-files module-root t "^.*\.fnd$"))
                (dolist (function (skill-fetch-functions file))
                  (push function skill-functions))))
            ;;Module is defined with a prefixes list
            (t
              (dolist (couple skill-modules-highlights)
                (and (listp couple) (equal module (car couple))
                  (dolist (file (directory-files module-root t "^.*\.fnd$"))
                    (dolist (function (skill-fetch-functions file (cdr couple)))
                      (push function skill-functions))))))
          );cond
        );dolist
      );when root is a directory and modules were fetched
    );dolist documentation root
    ;; Removes duplicates
    (delete-dups skill-functions)
    (delete-dups skill-forms)
  );let
);defun

;(defun skill-fetch-documentation nil
;  "Fetch SKILL/SKILL++ functions in skill documentation (.fnd files)"
;  (let (modules module-root all-functions module-functions)
;    ;; Browses SKILL documentation directories
;    (dolist (directory (skill-get-documentation-directories))
;      ;; Fetches modules in documentation root
;      (when (and (file-directory-p directory) (set 'modules (directory-files directory nil "^[a-zA-Z_]*$")))
;        ;; Fetches every functions from each module defined in documentation root
;        (dolist (module modules)
;          (setq module-root (concat directory "/" module))
;          (setq module-functions nil)
;          (cond
;            ;; Core functions are considered as forms
;            ((equal module "Core_SKILL")
;              ;; fetching all .fnd files in module then all .fnd functions in .fnd files
;              (dolist (file (directory-files module-root t "^.*\.fnd$"))
;                (dolist (function (skill-fetch-functions file))
;                  (push function skill-forms))))
;            ;; Module is defined and contains classic functions
;            ((member module skill-modules-highlights)
;              ;; fetching all .fnd files in module then all .fnd functions in .fnd files
;              (dolist (file (directory-files module-root t "^.*\.fnd$"))
;                (dolist (function (skill-fetch-functions file)) (push function module-functions))))
;            ;;Module is defined with a prefixes list
;            (t
;              (dolist (couple skill-modules-highlights)
;                (and (listp couple) (equal module (car couple))
;                  (dolist (file (directory-files module-root t "^.*\.fnd$"))
;                    (dolist (function (skill-fetch-functions file (cdr couple)))
;                      (push function module-functions))))))
;          );cond
;          ;; Adds module functions to all-functions dpl
;          (push module-functions all-functions)
;        );dolist module
;      );when root is a directory and modules were fetched
;    );dolist documentation root
;    (setq skill-modules-functions (remq nil all-functions))));let ;defun

;; ------------------------------------------------------------------------------------------------------------
;; II. 2. Fetching functions defined in user's code if root is correct
;; ------------------------------------------------------------------------------------------------------------

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-fetch-in-code
;;
;; @doc Fetches all the functions, macros, classes and methods in the given skill file.
;; The fetched names are added accordingly to their type to skill-functions, skill-forms, skill-classes
;; or skill methods.
;;
;; @arg file
;; @type string
;; @doc Path of the file to parse
;; ------------------------------------------------------------------------------------------------------------
(defun skill-fetch-in-code (file)
  ;; Fetch all the functions, classes and methods defined in file
  ;; file is the path to a .il or .ils file
  (let (type regexp point mark)
    ;; copying file content in a new buffer
    (get-buffer-create "*skill-file-content*")
    (switch-to-buffer "*skill-file-content*")
    (insert-file-contents file)
    ;; fetching associated elements for each type
    (dolist (couple '(
          (skill-functions "^\(? *\\(defun\\|defglobalfun\\|define\\|procedure\\)\(? *")
          (skill-forms     "^\(? *defmacro\(? *")
          (skill-classes   "^\(? *\\(defclassx\\|defclass\\)\(? *")
          (skill-methods   "^\(? *defmethod\(? *")))
      (setq type (pop couple))
      (setq regexp (pop couple))
      ;; Going to the beginning of the created buffer at each iteration
      (beginning-of-buffer)
      ;; fetching functions/classes/methods and adding them to the corresponding lists
      (while (search-forward-regexp regexp nil t)
        (set 'point (point))
        (when (search-forward-regexp skill-valid-name nil t)
          (set 'mark (point))
          (eval `(push ,(buffer-substring point mark) ,type)))
      );while
    );foreach
    ;; killing the created buffer
    (kill-buffer "*skill-file-content*")
  );let
);defun

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-fetch-code
;;
;; @doc Parses all the SKILL files in skill-code-root (and its subdirectories if skill-recursive-search is
;; non-nil) and adds the fetched names to skill-functions, skill-forms, skill-classes or skill-methods
;; according to their type
;; ------------------------------------------------------------------------------------------------------------
(defun skill-fetch-code nil
  ;; Fetching functions in user's code
  (when (and (boundp 'skill-code-root) skill-code-root)
    ;; checking if the root describes a path
    (when (and (stringp skill-code-root) 
               (file-directory-p skill-code-root))
               (setq skill-code-root (list skill-code-root)))
    (let ((directories skill-code-root) directory files)
      ;; Fetches all skill files in all directories from the root
      (while directories (set 'directory (pop directories))
        ;; Checks if the current directory is valid
        (when (file-directory-p directory)
          ;; Adds subdirectories to the list of directories (if recursive mode is enabled)
          (when skill-recursive-search
            (set 'directories (append (directory-files directory t "^[a-zA-Z_]*$") directories)))
          ;; Adds SKILL and SKILL++ files to the list of files to parse
          (set 'files (append (directory-files directory t "^.*\\.ils?$") files))))
      ;; Parses every file to fetch its functions/macros/classes/methods
      (dolist (file files) (when (file-readable-p file)
          (skill-fetch-in-code file)))
      ;; Removes duplicates
      (mapcar 'delete-dups (list skill-functions skill-forms skill-classes skill-methods))
    );let
  );when
);progn


;; ============================================================================================================
;; III. Bindkeys and Shortcuts
;; ============================================================================================================
;; ------------------------------------------------------------------------------------------------------------
;; III 1. Quotations marks
;; ------------------------------------------------------------------------------------------------------------

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-insert-quotations-marks
;;
;; @doc If there is no word after the point, inserts quotation marks and place the point in between
;; If there is a word after the point, places a quotation mark except if there is already a quotation mark
;; before it, in this case quotes the word. 
;; ------------------------------------------------------------------------------------------------------------
(defun skill-insert-quotation-marks nil
  "Inserts quote mark with a different behavior depending on the case"
  (interactive)
  ;; Checks if char before the point is already \"
  (if (= (char-before) ?\")
    ;; If a word and \" preceeds the point, deleting the \" and placing after the next word
    (if (string-match (substring skill-valid-name 0 -1) (buffer-substring (- (point) 2) (- (point) 1)))
      (progn (delete-region (- (point) 1) (point))
             (forward-char)
             (search-forward-regexp skill-valid-name)
             (insert "\""))
      ;; If only \" preceeds the point, places a second quotation mark and moves the point in between
      (if (member (char-after) '(? ?\ ?\n ?\)))
        (progn (insert "\"") (backward-char))
        (search-forward-regexp skill-valid-name)
        (insert "\""))
    );if
    ;; No \" already placed
    (insert "\"")
  );if
);defun


;; ------------------------------------------------------------------------------------------------------------
;; III 2. Parentheses
;; ------------------------------------------------------------------------------------------------------------

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-insert-parentheses
;;
;; @doc Before a space, newline or closed parenthese: inserts a pair of parentheses and places the point in
;; between, otherwise inserts an opened parenthese.
;; ------------------------------------------------------------------------------------------------------------
(defun skill-insert-parentheses nil
  "Inserts pair of parentheses or just open parenthese depending on the point"
  (interactive)
  ;; If char after is space, newline or \) we're writing \(\) and placing the point between
  (if (member (char-after) '(? ?\ ?\n ?\) nil))
    (progn (insert "\(\)") (backward-char))
    (insert "\(")))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-close-parentheses
;;
;; @doc If point is between a closed parenthes and the end of line, it adds a comment describing the function
;; opening the paired parenthese, otherwise inserts \)
;; ------------------------------------------------------------------------------------------------------------
(defun skill-close-parentheses nil
  "If point is between a closed parenthes and the end of line, it adds a comment describing the function opening the paired parenthese, otherwise inserts \)"
  (interactive)
  ;; Checks if current point is preceeded by \)
  (if (not (= (char-before) ?\))) (insert ")")
    ;; Fetches current line
    (let (bol eol function)
      (save-excursion (beginning-of-line) (setq bol (point)) (end-of-line) (setq eol (point)))
      ;; Checks if current point is on a line containing only one parenthese
      (if (not (string-match-p "^ *) *$" (buffer-substring bol eol))) (insert ")")
        ;; Fetches the function openning the closed parenthese
        (save-excursion (backward-sexp) (setq bol (+ (point) 1))
          (search-forward-regexp skill-valid-name) (setq eol (point))
          (setq function (buffer-substring bol eol)))
        (insert ";" function))
      ;; Checks if previous line has also only one parenthese
      (save-excursion (previous-line) (end-of-line) (setq eol (point)) (beginning-of-line) (setq bol (point))
        (when (string-match-p "^ *) *$" (buffer-substring bol eol))
          (search-forward ")") (skill-close-parentheses)))
    );let   
  );if
);defun


;; ------------------------------------------------------------------------------------------------------------
;; III 3. Indent
;; ------------------------------------------------------------------------------------------------------------

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-get-line-number
;;
;; @doc Returns the number of the line where point is located
;; ------------------------------------------------------------------------------------------------------------
(defun skill-get-line-number nil (string-to-number (format-mode-line "%l")))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-get-column-number
;;
;; @doc Returns the number of the column where point is located
;; ------------------------------------------------------------------------------------------------------------
(defun skill-get-column-number nil 
  (let ((current-point (point))) (save-excursion (beginning-of-line) (- current-point (point)))))
  
;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-get-line-indent
;;
;; @doc Returns the indentation (in number of spaces) at the current point
;;
;; @out indentation
;; @type integer
;; @doc Indentation level at the current point
;; ------------------------------------------------------------------------------------------------------------
(defun skill-get-line-indent nil
  "Returns the indentation (in number of spaces) at the curent point"
  (let (start end (spaces 0) (parentheses 0))
    (save-excursion (setq end (point)) (beginning-of-line) (setq start (point)))
    ;; Counts the number of spaces at beginning of line
    (while (equal (char-after start) ?\s) (setq start (+ 1 start)) (setq spaces (+ 1 spaces)))
    ;; Counts the number of opened parentheses before end
    (while (<= start end) (setq start (+ 1 start))
      (when (equal (char-after start) ?\() (setq parentheses (+ 1 parentheses))))
    (+ spaces (* 2 parentheses))
  );let
);defun

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-backward-sexp
;;
;; @doc Fetches and returns the backward sexp
;; ------------------------------------------------------------------------------------------------------------
(defun skill-backward-sexp nil
  "Fetches and returns the backward sexp"
  (let ((current-point (point)) next-point)
    ;; Goes to end of next sexp
    (when (ignore-errors (backward-sexp) t)
      (if (> current-point (setq next-point (point)))
        ;; A sexp was found, returning it
        (buffer-substring-no-properties current-point next-point)
        ;; No sexp were found
        (goto-char current-point) nil))))
  
;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-forward-sexp
;;
;; @doc Fetches and returns the forward sexp
;;
;; @out sexp / nil
;; @type string
;; @doc The fetched sexp or nil if an error occured
;; ------------------------------------------------------------------------------------------------------------
(defun skill-forward-sexp nil
  "Fetches and returns the forward sexp"
  (let ((current-point (point)) next-point)
    ;; Goes to end of next sexp
    (when (ignore-errors (forward-sexp) t)
      (if (< current-point (setq next-point (point)))
        ;; A sexp was found, returning it
        (buffer-substring-no-properties current-point next-point)
        ;; No sexp were found
        (goto-char current-point) nil))))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-get-parent-sexp
;;
;; @doc Retrieves data about the parent sexp of the current point
;;
;; @out parent-sexp
;; @type string
;; @doc Name of the main function in parent-sexp
;;
;; @out parent-indent
;; @type integer
;; @doc Indentation level of parent-sexp
;;
;; @out parent-arg
;; @type integer
;; @doc Index of the current point in the given sexp
;; ------------------------------------------------------------------------------------------------------------
(defun skill-get-parent-sexp nil
  ;; Inserts two \) to fetch parent sexp "(("
  (let (parent-start  ; point just before the parent sexp
        current-point ; point where the function is called
        parent-sexp   ; name of the function containing the call
        parent-indent ; indentation level of the parent
        parent-line   ; line number of the current sexp   
        (parent-arg 0))
    ;; Finds parent-start
    (insert "))") (save-excursion (when (skill-backward-sexp) (setq parent-start (point)))) (delete-char -2)
    (when parent-start
      (setq current-point (point))
      (save-excursion (goto-char parent-start)
        ;; Fetches parent-indent
        (setq parent-indent (skill-get-line-indent))
        (setq parent-column (skill-get-column-number))
        (setq parent-line (skill-get-line-number))
        ;; Fetches function name
        (forward-char) 
        (when (setq parent-sexp (skill-forward-sexp))
          (while (and (< (point) current-point) (skill-forward-sexp)) (setq parent-arg (+ 1 parent-arg)))))
      ;; Returns the list of parent attributes
      (when parent-sexp (list parent-sexp parent-indent parent-arg parent-line parent-column))
    );when
  );let
);defun

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-get-current-sexp
;;
;; @doc Retrieves data about the current sexp of the current point
;;
;; @out sexp
;; @type string
;; @doc Name of the main function in current-sexp
;;
;; @out sexp-indent
;; @type integer
;; @doc Indentation level of current-sexp
;;
;; @out sexp-arg
;; @type integer
;; @doc Index of the current point in the given sexp
;;
;; @out sexp-line
;; @type integer
;; @doc Line number of the current sexp
;; ------------------------------------------------------------------------------------------------------------
(defun skill-get-current-sexp nil
  ;; Inserts two \) to fetch current sexp "("
  (let (sexp-start    ; point just before the current sexp
        current-point ; point where the function is called
        sexp          ; name of the function containing the call
        sexp-indent   ; indentation level of the current
        sexp-line     ; line number of the current sexp        
        (sexp-arg 0))
    ;; Finds current-start
    (insert ")") (save-excursion (when (skill-backward-sexp) (setq sexp-start (point)))) (delete-char -1)
    (when sexp-start
      (setq current-point (point))
      (save-excursion (goto-char sexp-start)
        ;; Fetches current-indent
        (setq sexp-indent (skill-get-line-indent))
        (setq sexp-column (skill-get-column-number))
        (setq sexp-line (skill-get-line-number))
        ;; Fetches function name
        (forward-char)
        (when (setq sexp (skill-forward-sexp))
          (while (and (< (point) current-point) (skill-forward-sexp)) (setq sexp-arg (+ 1 sexp-arg)))))
      ;; Returns the list of current attributes
      (when sexp (list sexp sexp-indent sexp-arg sexp-line sexp-column))
    );when
  );let
);defun

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-indent-line-to
;;
;; @doc Smartly indent the current line to the given level
;;
;; @arg indent
;; @type int
;; @doc Indentation level to set
;; ------------------------------------------------------------------------------------------------------------
(defun skill-indent-line-to (indent) 
  (let ((current-point (point))
      (bol (progn (beginning-of-line) (point)))
      (current-indent (skill-get-line-indent)))
    ;; Indents the line and adjust point position according to number of inserted/deleted spaces
    (indent-line-to indent) (goto-char current-point) (forward-char (- indent current-indent))
    (if (< (point) bol) (goto-char bol))))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-reduce-indent
;;
;; @doc Checks if line contains only closed parentheses and adjust indentation accordingly
;; ------------------------------------------------------------------------------------------------------------
(defun skill-reduce-indent nil
  (let (start end new-indent string)
    ;; Fetches current-line
    (save-excursion (beginning-of-line) (setq start (point)) (end-of-line) (setq end (point))
      ;; Checks that current line contains only closed parentheses
      (when (or (string-match-p "^ *)+ *$" (setq string (buffer-substring-no-properties start end)))
        (string-match-p "^ *);.*$" string))
        ;; Point is at end of line, goes to last \) and to previous sexp
        (search-backward ")") (forward-char)
        (save-excursion (ignore-errors (backward-sexp)) (setq new-indent (skill-get-column-number)))
        (skill-indent-line-to new-indent)))))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-indent-line
;;
;; @doc Smartly indent current SKILL code line
;; ------------------------------------------------------------------------------------------------------------
(defun skill-indent-line nil
  "Smartly indent current SKILL code line"
  (interactive)
  (let ((current-point (point)) res)
    ;; Goes to the beginning of the line
    (beginning-of-line)
    ;; Retrieves current-sexp data
    (setq res (skill-get-current-sexp))
    (let ((current-sexp (pop res)) (current-indent (pop res))
          (current-arg (pop res)) (current-line (pop res)) (current-column (pop res)))
      ;; Retrieves parent-sexp data
      (setq res (skill-get-parent-sexp))
      (let ((parent-sexp (pop res)) (parent-indent (pop res))
            (parent-arg (pop res))  (parent-line (pop res)) (parent-column (pop res)))
        ;; Returns to start point
        (goto-char current-point)
        ;(print (list "parent" 
        ;    "name" parent-sexp
        ;    "indent" parent-indent
        ;    "arg" parent-arg
        ;    "line" parent-line))
        ;(print (list "current" 
        ;    "name" current-sexp
        ;    "indent" current-indent
        ;    "arg" current-arg
        ;    "line" current-line))
        ;; Cond according to fetched data
        (cond
          ;; --------------------------------------------------
          ;; and
          ;; Current sexp is and
          ;; Aligns the elements to check
          ;; --------------------------------------------------
          ((equal current-sexp "and")
            (skill-indent-line-to (+ 5 current-column)))
          ;; --------------------------------------------------
          ;; lessp
          ;; Current sexp is lessp
          ;; Aligns the elements to check
          ;; --------------------------------------------------
          ((equal current-sexp "lessp")
            (skill-indent-line-to (+ 7 current-column)))
          ;; --------------------------------------------------
          ;; greaterp
          ;; Current sexp is greaterp
          ;; Aligns the elements to check
          ;; --------------------------------------------------
          ((equal current-sexp "greaterp")
            (skill-indent-line-to (+ 10 current-column)))
          ;; --------------------------------------------------
          ;; or
          ;; Current sexp is or
          ;; Aligns the elements to check
          ;; --------------------------------------------------
          ((equal current-sexp "or")
            (skill-indent-line-to (+ 4 current-column)))
          ;; --------------------------------------------------
          ;; let
          ;; Current line is in a let definition
          ;; Aligns the variables defined in the let
          ;; --------------------------------------------------
          ((and (equal parent-sexp "let") (equal parent-arg 1))
            (skill-indent-line-to (+ 6 parent-column)))
          ;; --------------------------------------------------
          ;; letseq
          ;; Current line is in a letseq definition
          ;; Aligns the variables defined in the letseq
          ;; --------------------------------------------------
          ((and (equal parent-sexp "letseq") (equal parent-arg 1))
            (skill-indent-line-to (+ 9 parent-column)))
          ;; ------------------------------------------------------
          ;; progn
          ;; Current sexp is progn
          ;; Aligns all elements
          ;; ------------------------------------------------------
          ((equal current-sexp "progn")
            (skill-indent-line-to (+ 7 current-column)))
          ;; --------------------------------------------------
          ;; defun
          ;; Current line is a defun variables
          ;; Aligns the variables of the function
          ;; --------------------------------------------------
          ((and (equal parent-sexp "defun") (equal parent-arg 2))
            (if (equal current-sexp "@key")
              (skill-indent-line-to (+ 6 current-column))
              (skill-indent-line-to (+ 1 current-column))))
          ;; If defun has a docstring, remove indentation
          ((and (equal current-sexp "defun") (equal current-arg 3)
              (string-match-p "^\\ *\"" (save-excursion 
                  (let ((start (progn (beginning-of-line) (point)))
                        (end   (progn (end-of-line) (point))))
                      (buffer-substring-no-properties start end)))))
              (skill-indent-line-to 0))
          ;; --------------------------------------------------
          ;; defclass
          ;; Current line is a defun variables
          ;; Aligns the variables of the function
          ;; --------------------------------------------------
          ((and (equal parent-sexp "defclass") (equal parent-arg 3))
              (skill-indent-line-to (+ 1 current-column)))
          ;; --------------------------------------------------
          ;; wrap
          ;; Current sexp is wrap
          ;; Aligns wrapped elements
          ;; --------------------------------------------------
          ((and (equal current-sexp "wrap") (> 3 current-arg))
            (skill-indent-line-to (+ 6 current-column)))
          ;; --------------------------------------------------
          ;; current-sexp is on current-line
          ;; This means current sexp has no parent
          ;; --------------------------------------------------
          ((equal current-line (skill-get-line-number))
            (skill-indent-line-to 0))
          ;; --------------------------------------------------
          ;; Current line has nothing special
          ;; Gets current sexp indentation + 2
          ;; --------------------------------------------------
          (t 
            (skill-indent-line-to (if current-indent (+ 2 current-indent) 0)))
        )
        ;; When current line contains only closed parentheses, reduces indentation by two per parenthese
        (skill-reduce-indent)
      );let parent-sexp
    );let current-sexp
  );let current-point res
);defun

(defun skill-newline-and-indent (n)
  "Indents the current line, inserts a new line and indents it"
  ;; Executes the function with a number prefix
  (interactive "^p") (unless n (setq n 1))
  (when (> n 0) (newline) (skill-indent-line)
    (skill-newline-and-indent (- n 1))))

(defun skill-dimm-comments nil "Toggle comments dimming" (interactive)
  (if (equal (face-foreground 'skill-comment-face) "DarkGoldenrod")
    (setf (face-foreground 'skill-comment-face) "gold")
    (setf (face-foreground 'skill-comment-face) "DarkGoldenrod")))

;; ------------------------------------------------------------------------------------------------------------
;; III 5. Communication with Virtuoso
;; ------------------------------------------------------------------------------------------------------------

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-print-info
;;
;; @doc Prints in virtuoso all the strings passed in argument
;; ------------------------------------------------------------------------------------------------------------
(defun skill-print-info (&rest arg)
  "Print in Virtuoso all the strings passed in argument"
  ;; print the string
  (append-to-file (apply 'concat `("(printf \"" ,skill-emacs-prefix ,@arg "\\n\")\n")) nil "/dev/stdout"))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-print-string
;;
;; @doc Print Skill code in virtuoso
;; ------------------------------------------------------------------------------------------------------------
  (defun skill-print-string (&rest arg)
  "Print Skill code in virtuoso"
  (append-to-file (apply 'concat `("(mapcar 'println '(\n" ,@arg "\n))\n")) nil "/dev/stdout"))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-eval-string
;;
;; @doc Send strings passed in argument to be interpreted by Virtuoso
;; ------------------------------------------------------------------------------------------------------------
(defun skill-eval-string (&rest arg)
  "Send strings passed in argument to be interpreted by Virtuoso"
  ;; interpret the string
  (append-to-file (apply 'concat `("(progn\n" ,@arg "\n(printf \"\\n\"))\n")) nil "/dev/stdout"))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-interprete-string 
;;
;; @doc Send strings passed in argument to be interpreted by Virtuoso
;; ------------------------------------------------------------------------------------------------------------
(defun skill-interprete-string (&rest arg)
  "Send strings passed in argument to be interpreted by Virtuoso"
  ;; interpret the string
  (append-to-file (apply 'concat `("(println (progn \n" ,@arg "\n))\n")) nil "/dev/stdout"))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-send-string
;;
;; @doc Send all the strings passed in argument to Virtuoso so that they are printed and then interpreted in
;; SKILL
;; ------------------------------------------------------------------------------------------------------------
(defun skill-send-string (&rest arg)
  "Send all the strings passed in argument to Virtuoso so that they are printed and then interpreted in SKILL"
  ;; print the string
  (apply 'skill-print-string arg)
  ;; evaluate the string
  (apply 'skill-interprete-string arg))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-load-file
;;
;; @doc Load the current SKILL file in virtuoso
;; ------------------------------------------------------------------------------------------------------------
(defun skill-load-file (&rest args)
  "Load the current SKILL file in virtuoso"
  (interactive)
  (let ((fileName (or (car args) (buffer-file-name))))
    ;; saving current buffer
    (unless (car args) (save-buffer))
    ;; Printing "Loading ..." in Virtuoso
    (skill-print-info "Loading " fileName)
    ;; Loading the file
    (skill-eval-string "(load \"" fileName "\")")
  );let
);defun

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-lint-file
;;
;; @doc Use Lint on the current SKILL file
;; ------------------------------------------------------------------------------------------------------------
(defun skill-lint-file (&rest args)
  "Use Lint on the current SKILL file"
  (interactive)
  (let ((fileName (or (car args) (buffer-file-name))))
    ;; saving current buffer
    (unless (car args) (save-buffer))
    ;; Printing "Using Lint on ..." in Virtuoso 
    (skill-print-info "Using Lint on " fileName)
    ;; Using Lint on the file
    (skill-eval-string "(sklint ?ignores '(VAR12 CASE6) ?file \"" fileName "\")")
  );let
);defun

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-eval-buffer
;;
;; @doc Evaluates the current buffer in virtuoso and returns the result in the skill log
;; ------------------------------------------------------------------------------------------------------------
(defun skill-eval-buffer nil
  "Evaluates the current buffer in virtuoso and returns the result in the skill log"
  (interactive)
  ;; Printing "Evaluating Buffer ..."
  (skill-print-info "Evaluating Buffer " (or (buffer-file-name) (buffer-name)))
  (skill-eval-string (buffer-substring-no-properties (point-min) (point-max)))
);defun

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-eval-region
;;
;; @doc Evaluates the selected region in virtuoso and returns the result in the skill log
;; ------------------------------------------------------------------------------------------------------------
(defun skill-eval-region nil
  "Evaluates the selected region in virtuoso and returns the result in the skill log"
  (interactive)
  ;; Evaluate region if active, otherwise evaluate previous sexp
  (skill-print-info "Evaluating region")
  (if (region-active-p) (skill-send-string (buffer-substring-no-properties (mark) (point)))
    (let (beg) (backward-sexp) (setq beg (point)) (forward-sexp)
      (skill-send-string (buffer-substring-no-properties beg (point)))))
);defun

(defvar skill-registered-command ""
  "Registered command to be send to Virtuoso")

;; ---------------------------------------------------------------------------------------------------------------
;; @fun skill-register-command
;;
;; @doc Register the given command
;; ---------------------------------------------------------------------------------------------------------------
(defun skill-register-command nil
  "Register the given command"
  (interactive) (setq skill-registered-command (read-from-minibuffer "Skill command to register: ")))

;; ---------------------------------------------------------------------------------------------------------------
;; @fun skill-send-registered-command
;;
;; @doc Register the given command
;; ---------------------------------------------------------------------------------------------------------------
(defun skill-send-registered-command nil
  "Register the given command"
  (interactive) (skill-send-string skill-registered-command))

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-trace
;;
;; @doc Prompt user for a mode and trace a symbol using the selected mode
;; (by default uses the symbol in region)
;; ------------------------------------------------------------------------------------------------------------
(defun skill-trace (start end mode)
  "Prompt user for a mode and trace a symbol using the selected mode (by default uses the symbol in region)"
  (interactive "r\nkTrace mode: ")
  (let ((symbol (buffer-substring-no-properties start end)))
    ;; prompt user to know which symbol trace
    (setq symbol
      (read-string "Symbol to Trace: "
        (when (< (abs (- end start)) 30) symbol)))
    ;; checking if mode is variable, function or prop, doing nothing otherwise
    (when (member mode '("v" "f" "p"))
      (skill-print-info "Tracing " symbol)
      (skill-eval-string "(trace" mode " " symbol")")
    );when
  );let
);defun

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-untrace
;;
;; @doc Prompt user for a mode and untrace a symbol using the selected mode
;; (by default uses the symbol in region)
;; ------------------------------------------------------------------------------------------------------------
(defun skill-untrace (start end mode)
  "Prompt user for a mode and untrace a symbol using the selected mode (by default uses the symbol in region)"
  (interactive "r\nkTrace mode: ")
  (let ((symbol (buffer-substring-no-properties start end)))
    ;; prompt user to know which symbol trace
    (setq symbol
      (read-string "Symbol to Untrace: "
        (when (< (abs (- end start)) 30) symbol)))
    ;; checking if mode is variable, function or prop, doing nothing otherwise
    (when (member mode '("v" "f" "p"))
      (when (equal mode "f") (setq mode ""))
      (skill-print-info "Untracing " symbol)
      (skill-eval-string "(untrace" mode " " symbol")")
    );when
  );let
  );defun

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-launch-ide
;;
;; @doc Use Lint on the current SKILL file
;; ------------------------------------------------------------------------------------------------------------
(defun skill-launch-ide (&rest args)
  "Use Lint on the current SKILL file"
  (interactive)
  (let ((fileName (or (car args) (buffer-file-name))))
    ;; saving current buffer
    (unless (car args) (save-buffer))
    ;; Printing "Using Lint on ..." in Virtuoso 
    (skill-print-info "Opening " fileName " with SKILL IDE")
    ;; Using Lint on the file
    (skill-eval-string "(ilgRunSKILLIDE ?fileList '(\"" fileName "\"))")
  );let
);defun

;; ------------------------------------------------------------------------------------------------------------
;; @fun skill-clean-log
;;
;; @doc Opens log window if it is not displayed, then center the end of log in window
;; ------------------------------------------------------------------------------------------------------------
(defun skill-clean-log nil
  "Opens log window if it is not displayed, then center the end of log in window"
  (interactive)
  (let
    (
      (windows (window-list)) ; list of displayed windows
      current-window          ; current skill window
      window                  ; browsing variable
      log-window              ; window where log is displayed
      shell-window            ; window where shell is displayed
    )
    (setq current-window (car (window-list)))
    ;; browsing displayed windows to find skill.log and *skill shell* if they exist
    (while (and (or (not log-window) (not shell-window)) windows)
      (setq window (pop windows))
      ;; if buffer associated file is skill log path, log window already exists
      (when (equal (or (buffer-file-name (window-buffer window)) "") skill-log-path)
        (setq log-window window)
      )
      ;; if buffer name is *SKILL Shell*, shell window already exists
      (when (equal (or (buffer-name (window-buffer window)) "") "*SKILL Shell*")
        (setq shell-window window)
      )
    );while
    ;; log window exists, killing its buffer
    (if log-window (kill-buffer (window-buffer log-window))
      ;; log window does not exists, creating it
      (progn
        (delete-other-windows)
        (split-window-horizontally)
        (other-window 1)
        (view-file skill-log-path) (setf (buffer-name) "*SKILL-LOG*")
        (setq log-window (get-buffer-window))
      )
    )
    ;; going to end of log and centering it
    (select-window log-window)
    (goto-char (point-max))
    (recenter)
    ;(unless shell-window
    ;  ;; shell window does not exists, creating it
    ;  (split-window-vertically 40)
    ;  (other-window 1)
    ;  (switch-to-buffer "*SKILL Shell*")
    ;  (skill-shell-mode)
    ;  (setq shell-window (get-buffer-window))
    ;)
    ;; coming back to original window
    (select-window current-window)
  );let
);defun


;; ============================================================================================================
;; IV. Mode Creation
;; ============================================================================================================
;; ------------------------------------------------------------------------------------------------------------
;; IV. 1. Opening SKILL/SKILL++ files in SKILL mode
;; ------------------------------------------------------------------------------------------------------------

(add-to-list 'auto-mode-alist `(,(regexp-opt '(".il" ".ils" ".cdsinit" ".cdslocal" ".cdsperso")) . skill-mode))

;; ------------------------------------------------------------------------------------------------------------
;; IV. 2. Defining Syntax Table
;; ------------------------------------------------------------------------------------------------------------

(defvar skill-syntax-table
  (let ((skill-syntax-table (make-syntax-table)))
    ;; Allow Underscores in words
    (modify-syntax-entry ?\_ "w"   skill-syntax-table)
    ;; Paragrah comments /* ... */
    (modify-syntax-entry ?/ ". 14" skill-syntax-table)
    (modify-syntax-entry ?* ". 23" skill-syntax-table)
    ;; Line comments     ; ... \n
    (modify-syntax-entry ?\; "< b" skill-syntax-table)
    (modify-syntax-entry ?\n "> b"   skill-syntax-table)
    skill-syntax-table)
  "SKILL syntax table")

;; ------------------------------------------------------------------------------------------------------------
;; IV. 2. Highlighting keywords
;; ------------------------------------------------------------------------------------------------------------

(defun skill-module-lock-couple (module-functions)
  "Returns the couple used to define the font-lock for a module"
  (cons (concat "\\<" (regexp-opt module-functions) "\\>") 'skill-function-face))

(defun skill-associated-lock-couple (type)
  "Returns the couple used to define the font-lock"
  ;; type is function/form/class/method
  (let (string
      (face (intern (concat "skill-" (symbol-name type) "-face"))))
    ;; little trick to avoid error because class plural is classes
    (when (eq type 'class) (setq type 'classe))
    ;; creating a huge string containing all the function/form/class/method names separated by spaces
    (setq string (concat "\\<" (regexp-opt (eval (intern (concat "skill-" (symbol-name type) "s"))) t) "\\>"))
    ;; (two ' because emacs-basic-faces are associated to a symbol returning their name
    ;; [(eval font-lock-variable-name-face) returns font-lock-variable-name-face])
    (cons string `',face)
  );let
);defun

;; Trying to highlight symbols in quoted S-expressions
;; (defvar skill-quoted-symbols-matcher-closed-parenthese nil
;;   "Position of paired parenthese of the last match")

;; (defun skill-quoted-symbols-matcher (limit)
;;   "Search for symbols inside quoted s-expressions"
;;   ;; Check if inside a quoted expression
;;   (if skill-quoted-symbols-matcher-closed-parenthese
;;     ;; Inside a quoted expression
;;     (re-search-forward (concat "\\<" skill-valid-name "\\>") 
;;         (min limit skill-quoted-symbols-matcher-closed-parenthese) t)
;;     ;; Outside a quoted expression, find the next one
;;     (when (search-forward "'(" limit t) ;")" 
;;       ;; Find closing parenthese
;;       (save-excursion (backward-char 1) (ignore-errors (forward-sexp))
;;         (setq skill-quoted-symbols-matcher-closed-parenthese (point)))
;;       (re-search-forward (concat "\\<" skill-valid-name "\\>") 
;;         (min limit skill-quoted-symbols-matcher-closed-parenthese) t)))
;;   ;; Check if closed parenthese is still forward
;;   (when (< skill-quoted-symbols-matcher-closed-parenthese (point))
;;     (setq skill-quoted-symbols-matcher-closed-parenthese nil))
;;   (match-data))

;; (let (res)
;;   ;; Search parentheses
;;   (while (progn (re-search-forward "\'(" limit t)
;;         ;; Find closing parenthese
;;         (save-excursion (backward-char 1) (ignore-errors (forward-sexp)) (setq limit (min limit (point))))
;;         (setq res (re-search-forward (concat "\\<" skill-valid-name "\\>") limit t))))
;;     res))

(defvar skill-font-lock-keywords nil "Keywords to be highlighted in SKILL mode")

(defun skill-generate-keywords nil
  ;; Reset keywords
  (setq skill-font-lock-keywords nil)
  (dolist (keyword `(
        ;; ------------------------------------------------------
        ;; 1. Comments starting with ;;
        ;; ------------------------------------------------------
        (";;.*$" 0 'skill-info-face t)
        ;; ------------------------------------------------------
        ;; 2. nil, t or ()
        ;; ------------------------------------------------------
        ("\\(()\\|\\<\\(\\(nil\\|t\\)\\>\\)\\)" . 'skill-keyword-face)
        ;; ------------------------------------------------------
        ;; 3. SKILL Identifiers used as prefixes
        ;; (cf. Cadence SKILL Language Reference
        ;; -> Identifiers Used to Denote Data Types)
        ;; ------------------------------------------------------
        ("\\(\\<[aAbBCdefFgGhIKlLmMnopqrRsStTuUvwxY]\\)_" . (1 'skill-keyword-face))
        ;; ------------------------------------------------------
        ;; 4. @<symbol> or ?<symbol>
        ;; ------------------------------------------------------
        (,(concat "[@\?]" skill-valid-name "\\>") . 'skill-variable-face)
        ;; ------------------------------------------------------
        ;; 5. C style characters
        ;; ------------------------------------------------------
        ("\\('\\|`\\|,\\|<\\|>\\|=\\|->\\|~>\\|&\\|+\\|-\\|*\\|/\\:\\)" . 'skill-shortcut-face)
        ;; ------------------------------------------------------
        ;; 6. Quoted symbols
        ;; ------------------------------------------------------
        (,(concat "[\'`]" skill-valid-name "\\>") . 'skill-symbol-face)
        ;; ------------------------------------------------------
        ;; 7. Functions being defined
        ;; ------------------------------------------------------
        (,(concat "defun[\s\n]*\\(" skill-valid-name "\\)") . (1 'skill-function-face))
        ;; ------------------------------------------------------
        ;; 8. Functions, macros, classes and methods
        ;; ------------------------------------------------------
        ,(skill-associated-lock-couple 'function)
        ,(skill-associated-lock-couple 'method)
        ,(skill-associated-lock-couple 'class)
        ,(skill-associated-lock-couple 'form)
        ,(skill-associated-lock-couple 'syntax-form)
        ;; ------------------------------------------------------
        ;; 9. Functions defined in documentation
        ;; ------------------------------------------------------
        ,@(mapcar 'skill-module-lock-couple skill-modules-functions)
        ;; ------------------------------------------------------
        ;; 10. Prefixes defined by hand, not awesome but effective
        ;; ------------------------------------------------------
        ;("\\<\\(gpe\\|maal\\|dd\\|dd\\ge\\)[a-zA-Z0-9_]*\\>" . 'skill-function-face)
        ;; ------------------------------------------------------
        ;; 11. Replacing tabs with two spaces
        ;; ------------------------------------------------------
        ("\t" . 'skill-tab-face)
        ;("\t" (0 '(face default display "TAB") append))
        )) (push keyword skill-font-lock-keywords))  
  ;; Return compiled keywords
  ; (setq skill-font-lock-keywords (font-lock-compile-keywords skill-font-lock-keywords))
  skill-font-lock-keywords)

;; (defconst skill-font-lock-keywords-pointer
;;   '`(;("\"\\(.*\n\\)*.*\"" . 'skill-string-face)
;;     ;; /*...*/ and ;...\n comments in skill-info-face but ;;...\n comments in skill-comment-face
;;     ("\\(;;.*\\)$" . (1 'skill-comment-face t))
;;     ,@(mapcar 'skill-module-lock-couple skill-modules-functions)
;;     ;; Prefixes defined by hand, not awesome but effective
;;     ("\\<\\(gpe\\|maal\\|dd\\|dd\\ge\\)[a-zA-Z0-9_]*\\>" . 'skill-function-face)
;;     ,(skill-associated-lock-couple 'function)
;;     ,(skill-associated-lock-couple 'method)
;;     ,(skill-associated-lock-couple 'class)
;;     ,(skill-associated-lock-couple 'form)
;;     ,(skill-associated-lock-couple 'syntax-form)
;;     (,(concat "defun[\s\n]*\\(" skill-valid-name "\\)") . (1 'skill-function-face))
;;     (,(concat "\'" skill-valid-name "\\>") .                          'skill-symbol-face)
;;     ("\\('\\|`\\|,\\|<\\|>\\|=\\|->\\|~>\\|&\\|+\\|-\\|*\\|/\\:\\)" . 'skill-shortcut-face)
;;     (,(concat "[@\?]" skill-valid-name "\\>") .                       'skill-variable-face)
;;     ("\\(()\\|\\<\\(\\(nil\\|t\\)\\>\\)\\)" .                         'skill-keyword-face)
;;     ("\\(\\<[pwgdlxfrsot]\\)_" .                                   (1 'skill-keyword-face))))

;; (defvar skill-font-lock-keywords
;;   (progn (skill-fetch-documentation) (skill-fetch-code) (eval skill-font-lock-keywords-pointer))
;;   "Default highlighting expressions for SKILL mode")

;; (defun skill-update-keywords nil
;;   "Update the list of highlighted functions, forms, classes and methods"
;;   (skill-fetch-documentation)
;;   (skill-fetch-code)
;;   (setq skill-font-lock-keywords (eval skill-font-lock-keywords-pointer)))

;; ------------------------------------------------------------------------------------------------------------
;; IV. 4. Allowing hooks
;; ------------------------------------------------------------------------------------------------------------

(defvar skill-hooks nil)

;; ------------------------------------------------------------------------------------------------------------
;; IV. 5. Providing SKILL Major mode
;; ------------------------------------------------------------------------------------------------------------

(defun skill-mode () "Enable SKILL major mode" (interactive)
  ;; Use only SKILL mode local variables
  (kill-all-local-variables)
  ;; ------------------------------------------------------
  ;; Skill shortcuts
  ;; ------------------------------------------------------
  (use-local-map skill-map)
  ;; Increasing max number of functions that can be fetched
  (set (make-local-variable 'max-lisp-eval-depth) 10000)
  ;; ------------------------------------------------------
  ;; Set syntax table and font lock keywords
  ;; in order to highlight properly
  ;; ------------------------------------------------------
  ;; Fonts
  (set-background-color "gray15") (set-foreground-color "linen")
  (set (make-local-variable 'font-lock-string-face) 'skill-string-face)
  (set (make-local-variable 'font-lock-comment-face) 'skill-comment-face)
  ;; Syntax table
  (set-syntax-table skill-syntax-table)
  (set (make-local-variable 'comment-start) ";")
  (set (make-local-variable 'comment-end) "")
  ;; Keywords
  ;; (first nil to consider strings and comments, second one to consider case)
  (skill-generate-keywords)
  (set (make-local-variable 'font-lock-defaults) (list skill-font-lock-keywords nil nil))
  ;; ------------------------------------------------------
  ;; Set SKILL indentation function
  ;; ------------------------------------------------------
  (set (make-local-variable 'indent-line-function) 'skill-indent-line)
  ;; allow outline mode with SKILL
  (set (make-local-variable 'outline-regexp) "^\\([a-zA-Z_]*(\\|/\\*\\|;.*\n\\)");to define headings (outline-minor-mode)
  ;; Set mode and mode name
  (setq major-mode 'skill-mode) (setq mode-name "SKILL")
  ;; ------------------------------------------------------
  ;; Allow hooks definitions
  ;; ------------------------------------------------------
  (run-mode-hooks 'skill-hooks))

(skill-fetch-documentation)
(skill-fetch-code)
(provide 'skill-mode)


;; ============================================================================================================
;; End of skill-mode.el
;; ============================================================================================================
