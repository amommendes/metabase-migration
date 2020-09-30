
(ns api-tests.requests
  (:gen-class)
  (:require [org.httpkit [client :as http]]
            [clojure.java.io :as io]
            [clojure.string :as str]
            [clojure.data.json :as json]
            [clojure.tools
             [logging :as log]]
            [clojure.tools.cli :refer [parse-opts]]))
(defn get-token
  "Get Metabase token with user/pass parms"
  [user pass metabase-url]

  (def params
    {:body (json/write-str {:username user :password pass})
     :headers {"Content-Type" "application/json"}})
  (def api-session-url (str metabase-url "api/session"))

  (log/warn "Getting token from user:" user "at" api-session-url)

  (let [response @(http/post api-session-url params)]
    (if (not= 200 (get response :status))
      (throw (Exception. (str "Getting token error. Reponse:" response)))
      (get (json/read-str (response :body) :key-fn keyword) :id))))

(defn parse-url-requests
  "Read file with requests urls"
  [file-path base-url]
  (log/info "Reading file" file-path)

  (def lines
    (with-open [rdr (io/reader file-path)]
      (reduce conj [] (line-seq rdr))))
  (def splitted-values (mapv #(str/split % #"\s") lines))
  (map (fn [value] {:method (keyword (value 0)) :url (str base-url (value 1))}) splitted-values))

(defn mount-requests-parameters
  [requests-lines token]
  (def headers-map {:headers {"X-Metabase-Session" token} :insecure? true })
  (mapv (fn [request] (merge headers-map request)) requests-lines))

(defn make-requests
  [requests-params]
  (let [params requests-params
      futures (doall (map http/request params))]
  (doseq [response futures]
    (spit (str "/tmp/"  "result_sets.txt") (:body @response))
    (log/info "URL ->> " (-> @response :opts :url ) "Method ->> " (-> @response :opts :method ) " Status ->> " (:status @response))
    )
  
  )
)