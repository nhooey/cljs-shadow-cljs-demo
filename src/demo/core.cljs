(ns demo.core
  (:require [shadow.cljs.devtools.client.browser :as browser]))

(defn ^:export update-message []
  "Updates the message in the DOM with a timestamp, demonstrating code reload."
  (let [el (js/document.getElementById "app")]
    (when el
      (set! (.-innerHTML el) (str "Hello from ClojureScript! Current time: " (js/Date.))))))

(defn init []
  "Initialization function called when the application starts."
  (println "ClojureScript app initialized!")
  (update-message)                                          ;; Call the function to display the initial message
  (js/setInterval update-message 2000))                     ;; Update message every 2 seconds for active reloading demo
