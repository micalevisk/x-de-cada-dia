(defproject hello-browser "0.1.0-SNAPSHOT"
  :description "(c) https://coderwall.com/p/02idja/setting-up-a-clojurescript-project"
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [org.clojure/clojurescript "0.0-2411"]]

  :plugins [[lein-cljsbuild "1.0.3"]]

  :cljsbuild {
    :builds [{:source-paths ["src/cljs"]
              :compiler {:output-to "resources/public/core.js"}}]})
