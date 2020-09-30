(ns api-tests.core
  (:gen-class)
  (:require [clojure.java.io :as io]
            [clojure.string :as str]
            [clojure.data.json :as json]
            [clojure.tools
             [logging :as log]]
            [api-tests.requests :as reqs]
            [clojure.tools.cli :refer [parse-opts]]))


(def cli-options
  [["-u" "--username USER" "Metabase user name"]
   ["-p" "--password PASS" "Metabase password"]
   ["-s" "--server SERVER" "Metabase Server"]
   ["-f" "--file-requests-urls \"/path/to/file\"" "File with requests URI (i.e., :method :uri)"]
  ])


(defn -main [& args]

  (log/info "Initializing Metabase UI tests") 
  (def parsed-args (parse-opts args cli-options))

  (log/info "Usage: \n" (get parsed-args :summary))
  
  (def opts
    (get parsed-args :options))

  (def token
    (reqs/get-token (get opts :username) (get opts :password) (get opts :server)))

  (log/info "Metabase Token:"  token)

  (def requests-lines (reqs/parse-url-requests (get opts :file-requests-urls) (get opts :server)))

  (def requests (reqs/mount-requests-parameters requests-lines token))

  (log/info "Sending API requests to endpoints"  )

  (reqs/make-requests requests))

