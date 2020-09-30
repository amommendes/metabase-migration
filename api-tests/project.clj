(defproject api-tests "0.1.0-SNAPSHOT"
  :description "Tests api endpoints concurrently"
  :url "http://example.com/FIXME"
  :license {:name "EPL-2.0 OR GPL-2.0-or-later WITH Classpath-exception-2.0"
            :url "https://www.eclipse.org/legal/epl-2.0/"}

  :dependencies [[org.clojure/clojure       "1.10.1"]
                 [http-kit                  "2.4.0-alpha6"] ;; fix SSL exceptions
                 [org.clojure/tools.logging "1.1.0"]
                 [org.clojure/tools.cli     "1.0.194"]
                 [org.clojure/data.json "1.0.0"]
                 [log4j/log4j               "1.2.17"
                  :exclusions [javax.mail/mail
                               javax.jms/jms
                               com.sun.jdmk/jmxtools
                               com.sun.jmx/jmxri]]]
  :main ^:skip-aot api-tests.core
  :port 8081
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}}
  :jvm-opts ["-Dclojure.tools.logging.factory=clojure.tools.logging.impl/log4j-factory"]
  
  )
