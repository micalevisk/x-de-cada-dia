(ns cli-test.core
  (:require [clojure.string :as string]
            [clojure.tools.cli :refer [parse-opts]])
  (:gen-class :main true :prefix -))
;             ^^^^^^^^^^^^^^^^^^^^ default

(def cli-options
  [["-p", "--port PORT" "The Port Number"
    :default 8080 ; default value for this option
    :parse-fn #(Integer/parseInt %) ; parse the option value
    :validate [#(< 0 % 0x10000) "Should be a number between 0 and 65536"]] ; validate parsed value
   ["-h" "--help"]])

(defn- help [options]
  (->> ["cli-test is a command line tool for starting and stopping a HTTP server"
        ""
        "Usage: cli-test [options] action"
        ""
        "Options:"
        options
        ""
        "Actions:"
        "  start      Start a HTTP server"
        "  stop       Stop a HTTP server"]
        (string/join \newline)))

(defn- exit
  "Simply displays a message and sets the exit code."
  [status msg]
  (println msg)
  (System/exit status))

(def handlers
  {:start #(println "Starting HTTP server on port" (:port %))
   :stop #(println "Stopping HTTP server on port" (:port %))})

(defn error-msg [errors]
  (str "There were errors processing the command line arguments\n\n"
       (string/join \newline errors)))


(defn -main [& args]
  (let [{:keys [options arguments errors summary]} (parse-opts args cli-options)]
    (cond
      (:help options) (exit 0 (help summary)) ;; When we explicitly ask for help
      (not= (count arguments) 1) (exit 1 (help summary)) ;; When we supply no arguments
      errors (exit 1 (error-msg errors)))
    (if-let [handler ((keyword (first arguments)) handlers)]
      (handler options)
      (exit 0 (help summary)))))
