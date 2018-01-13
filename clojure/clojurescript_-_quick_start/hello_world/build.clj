;; (c) https://clojurescript.org/guides/quick-start
(require 'cljs.build.api)

(cljs.build.api/build "src"
  {:output-to "out/main.js"
   :main 'hello-world.core}) ;; para evitar o uso do out/goog/base.js
