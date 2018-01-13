;; Browser REPL (c) https://clojurescript.org/guides/quick-start
(require 'cljs.build.api)
(require 'cljs.repl)
(require 'cljs.repl.browser)

(cljs.build.api/build "src"
  {:main 'hello-world.core ;; para evitar o uso do out/goog/base.js
   :output-to "out/main.js"
   :browser-repl true
   :verbose true})

(cljs.repl/repl (cljs.repl.browser/repl-env)
  :watch "src"
  :output-dir "out")
