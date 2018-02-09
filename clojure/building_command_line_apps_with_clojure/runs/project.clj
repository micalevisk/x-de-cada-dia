(defproject runs "0.1.0-SNAPSHOT"
  :description "(c) https://yobriefca.se/blog/2014/03/02/building-command-line-apps-with-clojure"
	:main runs.core
  :plugins [[lein-bin "0.3.4"]]
  :bin { :name "runs" }
	:dependencies [[org.clojure/clojure "1.8.0"]
								 [org.clojure/tools.cli "0.2.4"]])
