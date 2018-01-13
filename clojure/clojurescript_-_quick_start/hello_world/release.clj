;; Production Builds (c) https://clojurescript.org/guides/quick-start
(require 'cljs.build.api)

(cljs.build.api/build "src"
  {:output-to "out/main.js"
   :optimizations :advanced})

(System/exit 0)
