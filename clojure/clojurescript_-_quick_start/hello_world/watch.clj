;; Less Boilerplate (c) https://clojurescript.org/guides/quick-start
;; run on Windows: java -cp "cljs.jar;src" clojure.main watch.clj
;; to watch changes on core.cljs
(require 'cljs.build.api)

(cljs.build.api/watch "src"
  {:output-to "out/main.js"
   :main 'hello-world.core}) ;; para evitar o uso do out/goog/base.js
