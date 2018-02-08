;; -------------------------- ;;
;; -------- Equality -------- ;;
;; -------------------------- ;;

;{1} We shall contemplate truth by testing reality, via equality
(= true true)

;{2} To understand reality, we must compare our expectations against reality
(= 2 (+ 1 1))

;{3} You can test equality of many things
(= (+ 3 4)
   7
  (+ 2 5))

;{4} But you may not string yourself along
(= false (= 2 "2"))

;{5} Something is not equal to nothing
(= true
  (not (= 1 nil)))

;{6} Strings, and keywords, and symbols: oh my!
(= false
  (= "foo" :foo 'foo))

;{7} Make a keyword with yout keyboard
(= :foo
  (keyword "foo"))

;{8} Symbolism is all around us
(= 'foo
  (symbol "foo"))

;{9} When things cannot be equal, they must be different
(not= :fill-in-the-blank '())
(not= :fill-in-the-blank "")



;; ----------------------- ;;
;; -------- Lists -------- ;;
;; ----------------------- ;;

;{1} Lists can be expressed by function or a quoted form
(= '(1 2 3 4 5)
  (list 1 2 3 4 5))

;{2} They are Clojure seqs (sequences), so they allow access to the first
(= 1
  (first '(1 2 3 4 5)))

;{3} As well as the rest
(= '(2 3 4 5)
  (rest '(1 2 3 4 5)))

;{4} Count your blessings
(= 3
  (count '(dracula dooku chocula)))

;{5} Before they are gone
(= 0
  (count '()))

;{6} The rest, when nothing is left, is empty
(= '()
  (rest '(100)))

;{7} Construction by adding an element to the front is easy
(= '(:a :b :c :d :e)
  (cons :a '(:b :c :d :e)))

;{8} Conjoining an element to a list is strikingly similar
(= '(:a :b :c :d :e)
  (conj '(:b :c :d :e) :a))

;{9} You can use a list like a stack to get the first element
(= :a
  (peek '(:a :b :c :d :e)))

;{10} Or the others
(= '(:b :c :d :e)
  (pop '(:a :b :c :d :e)))



;; ------------------------ ;;
;; -------- Vector -------- ;;
;; ------------------------ ;;

;{1} You can use vectors in clojure as array-like structures
(= 1
  (count [42]))

;{2} You can create a vector from a list
(= [1]
  (vec '(1)))

;{3} Or from some elements
(= [nil nil]
  (vector nil nil))

;{4} But you can populate it with any number of elements at once
(= [1 2]
  (vec '(1 2)))

;{5} Conjoining a vector is different than to a list
(= [111 222 333]
  (conj [111 222] 333))

;{6} You can get the first element of a vector like so
(= :peanut
  (first [:peanut :butter :and :jelly]))

;{7} And the last in a similar fashion
(= :jelly
  (last [:peanut :butter :and :jelly]))

;{8} Or any index if you wish
(= :jelly
  (nth [:peanut :butter :and :jelly] 3))

;{9} You can also slice a vector
(= [:butter :and]
  (subvec [:peanut :butter :and :jelly] 1 3))

;{10} Equality with collections is in terms of values
(= (list 1 2 3)
  (vector 1 2 3))

;{11} You can create a set by converting another collection
(= #{3} (set '(3)))



;; ---------------------- ;;
;; -------- Sets -------- ;;
;; ---------------------- ;;

;{1} You can create a set by converting another collection
(= #{3}
  (set '(3)))

;{2} Counting them is like counting other collections
(= 3
  (count #{1 3 2}))

;{3} Remeber that a set is a *mathematical* set
(= #{1 2 3 4 5}
  (set '(1 1 2 2 3 3 4 4 5 5)))



;; ---------------------- ;;
;; -------- Maps -------- ;;
;; ---------------------- ;;

;{1} Don't get lost when creating a map
(= {:a 1, :b 2}
  (hash-map :a 1 :b 2))

;{2} A value must be supplied for each key
(= {:a 1}
  (hash-map :a 1))

;{3} The size is the number of entries
(= 2
  (count {:a 1, :b 2}))

;{4} You can look up the value for a given key
(= 2
  (get {:a 1, :b 2} :b))

;{5} Maps can be used as functions to do lookups
(= 1
  ({:a 1, :b 2} :a))

;{6} And so can keywords
(= 1
  (:a {:a 1, :b 2}))

;{7} But map keys need not be keywords
(= "Vancouver"
  ({2006 "Torino", 2010 "Vancouver", 2014 "Sochi"} 2010))

;{8} You may not be able to find an entry for a key
(= nil
  (get {:a 1, :b 2} :c))

;{9} But you can provide your own default
(= :key-not-found
  (get {:a 1, :b 2} :c :key-not-found))

;{10} You can find out if a key is present
(= true
  (contains? {:a nil, :b nil} :b))

;{11} Or if it is missing
(= false
  (contains? {:a nil, :b nil} :c))

;{12} Maps are immutable, but you can create a new and improved version
(= {1 "January", 2 "February"}
  (assoc {1 "January" 2 "February"}))

;{13} You can also create a new version with an entry removed
(= {1 "January"}
  (dissoc {1 "January", 2 "February"} 2))

;{14} Often you will need to get the keys, but the order is undependable
(= (list 2006 2010 2014s)
  (sort (keys {2010 "Vancouver", 2014 "Sochi", 2006 "Torino"})))

;{15} You can get the values in a similar way
(= (list "Sochi" "Torino" "Vancouver")
  (sort (vals {2010 "Vancouver", 2014 "Sochi", 2006 "Torino"})))



;; --------------------------- ;;
;; -------- Functions -------- ;;
;; --------------------------- ;;

(defn square [n] (* n n))
(defn multiply-by-ten [n] (* 10 n))

;{1} Calling a function is like giving it a hug with parentheses
(= 81
  (square 9))

;{2} Functions are usually defined before they are used
(= 20
  (multiply-by-ten 2))

;{3} But they can also be defined inline
(= 10
  ((fn [n] (* 5 n)) 2))

;{4} Or using an even shorter syntax
(= 60
  (#(* 15 %) 4))

;{5} Even anonymous funcions may take multiple arguments
(= 15
  (#(+ %1 %2 %3) 4 5 6))

;{6} Arguments can also be skipped
(= 30
  (#(* 15 %2) 1 2))

;{7} One function can beget another
(= 9
  (((fn [] +)) 4 5))

;{8} Functions can also take other functions as input
(= 20
  ((fn [f] (f 4 5)) *))

;{9} Higher-order functions take function arguments
(= 25
  (#(% 5) (fn [n] (* n n))))

;{10} But they are often better written using the names of functions
(= 25
  (#(% 5) square))



;; ------------------------------ ;;
;; -------- Conditionals -------- ;;
;; ------------------------------ ;;

(defn explain-defcon-level [exercise-term]
     (case exercise-term
           :fade-out          :you-and-what-army
           :double-take       :call-me-when-its-important
           :round-house       :o-rly
           :fast-pace         :thats-pretty-bad
           :cocked-pistol     :sirens
           :say-what?))

;{1} You will face many decisions
(= :a
  (if (false? (= 4 5)) :a :b))

;{2} Some of them leave you no alternative
(= []
  (if (> 4 3) []))

;{3} And in such a situation you may have nothing
(= nil
  (if (nil? 0) [:a :b :C]))

;{4} In others you alternative may be interesting
(= :glory
  (if (not (empty? ())) :doom :glory))

;{5} You may have a multitude of possible of possible paths
(let [x 5]
  (= :your-road
    (cond
      (= x 1) :road-not-taken
      (= x 2) :another-road-not-taken
      :else   :your-road)))

;{6} Or your fate may be sealed
(= 'doom
  (if-not (zero? :anything) 'doom 'doom))

;{7} In case of emergency, sound the alarms
(= :sirens
  (explain-defcon-level :cocked-pistol))

;{8} But admit it when you don't kwno what to do
(= :say-what?
  (explain-defcon-level :yo-mama))


;; ---------------------------------------- ;;
;; -------- Higher Order Functions -------- ;;
;; ---------------------------------------- ;;

;{1} The map function relates a sequence to another
(= '(4 8 12)
  (map (fn [x] (* 4 x)) [1 2 3]))

;{2} You may create that mapping
(= '(1 4 9 16 25)
  (map (fn [x] (* x x)) [1 2 3 4 5]))

;{2} Or use the names of existing functions
(= '(false false true false false)
  (map nil? [:a :b nil :c :d]))

;{3} A filter can be strong
(= '()
  (filter (fn [x] false) '(:anything :goes :here)))

;{4} Or very weak
(= '(:anything :goes :here)
  (filter (fn [x] true) '(:anything :goes :here)))

;{5} Or somewhere in between
(= [10 20 30]
  (filter (fn [x] (< x 31)) [10 20 30 40 50 60 70 80]))

;{6} Maps and filters may be combined
(= [10 20 30]
  (map (fn [x] (* x 10))
    (filter (fn [x] (< x 4)) [1 2 3 4 5 6 7 8])))

;{7} Reducing can increase the result
(= 24
  (reduce (fn [a b] (* a b)) [1 2 3 4]))

;{8} You can start somewhere else
(= 2400
  (reduce (fn [a b] (* a b)) 100 [1 2 3 4]))

;{9} Numbers are not the only things one can reduce
(= "longest"
  (reduce (fn [a b] (if (< (count a) (count b)) b a)) ["which" "is" "the" "longest" "word"]))



;; -------------------------------------- ;;
;; -------- Runtime Polymorphism -------- ;;
;; -------------------------------------- ;;

(defn hello
  ([] "Hello World!")
  ([a] (str "Hello, you silly " a "."))
  ([a & more] (str "Hello to this group: "
                   (apply str
                          (interpose ", " (concat (list a) more)))
                   "!")))

;{1} Some functions can be used in different ways - with no arguments
(= "Hello World!" (hello))

;{2} With one arguments
(= "Hello, you silly world."
  (hello "world"))

;{3} Or with many arguments
(= "Hello to this group: Peter, Paul, Mary!"
  (hello "Peter" "Paul" "Mary"))

;{4} Multimethods allow more complex dispatching
(defmulti diet (fn [x] (:eater x)))
(defmethod diet :herbivore [a] (str (:name a) " eats veggies."))
(defmethod diet :carnivore [a] (str (:name a) " eats animals."))
(defmethod diet :default [a] (str "I don't know what " (:name a) " eats."))
(= "Bambi eats veggies." (diet {:species "deer", :name "Bambi", :age 1, :eater :herbivore}))

;{5} Different methods are used depending on the dispatch function result
(= "Simba eats animals." (diet {:species "lion", :name "Simba", :age 1, :eater :carnivore}))

;{6} You may use a default method when no others match
(= "I don't know what Rich Hickey eats." (diet {:name "Rich Hickey"}))



;; -------------------------------- ;;
;; -------- Lazy Sequences -------- ;;
;; -------------------------------- ;;

;{1} There are many ways to generate a sequence
(= '(1 2 3 4)
  (range 1 5))

;{2} The range starts at the beginning by default
(= '(0 1 2 3 4)
  (range 5))

;{3} Only take what you need when the sequence is large
(= [0 1 2 3 4 5 6 7 8 9]
  (take 10 (range 100)))

;{4} Or limit results by dropping what you don't need
(= [95 96 97 98 99]
  (drop 95 (range 100)))

;{5} Iteration provides an infinite lazy sequence
(= '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19)
  (take 20 (iterate inc 0)))

;{6} Repetition is key
(= [:a :a :a :a :a :a :a :a :a :a]
  (repeat 10 :a))

;{7} Iteration can be used for repetion
(= (repeat 100 :foo)
  (take 100 (iterate identity :foo)))



;; ----------------------------------------- ;;
;; -------- Sequence Comprehensions -------- ;;
;; ----------------------------------------- ;;

;{1} Sequence comprehensions can bind each element in turn to a symbol
(= '(0 1 2 3 4 5)
  (for [index (range 6)] index))

;{2} They can easily emulate mapping
(= '(0 1 4 9 16 25)
  (map (fn [index] (* index index)) (range 6))
  (for [index (range 6)] (* index index)))

;{3} And also filtering
(= '(1 3 5 7 9)
  (filter odd? (range 10))
  (for [index (range 10)
        :when (odd? index)] index))

;{4} Combinations of these transformations is trivial
(= '(1 9 25 49 81)
  (map #(* % %) (filter odd? (range 10)))
  (for [index (range 10) :when odd?] (* index index)))

;{5} More complex transformations simply take multiple binding forms
(= [[:top :left] [:top :middle] [:top :right] [:middle :left] [:middle :middle] [:middle :right] [:bottom :left] [:bottom :middle] [:bottom :right]]
  (for [row [:top :middle :bottom]
        column [:left :middle :right]]
    [row column]))



;; ------------------------------------ ;;
;; -------- Creating Functions -------- ;;
;; ------------------------------------ ;;

;{1} One may know what they seek by knowing what they do not seek
(= [true false true]
  (let [not-a-symbol? (complement symbol?)]
    (map not-a-symbol? [:a 'b "c"])))

;{2} Praise and 'complement' may help you separate the wheat from the chaff
(= [:wheat "wheat" 'wheat]
  (let [not-nil? (complement nil?)]
    (filter not-nil? [nil :wheat nil "wheat" nil 'wheat nil])))

;{3} Partial functions alllow procrastination
(= 20
  (let [multiply-by-5 (partial * 5)]
    (multiply-by-5 4)))

;{4} Don't forget: first things first
(= [:a :b :c]
  (let [ab-adder (partial concat [:a :b])]
    (ab-adder [:c])))

;{5} Functions can join forces as one 'composed' function
(defn square [x] (* x x))

(= 25
  (let [inc-and-square (comp square inc)]
    (inc-and-square 4)))

;{6} Have a go on a double dec-er
(= 8
  (let [double-dec (comp dec dec)]
    (double-dec 10)))

;{7} Be careful about the order in which you mix your functions
(= 99
  (let [square-and-dec (comp dec square)]
    (square-and-dec 10)))



;; ------------------------------- ;;
;; -------- Destructuring -------- ;;
;; ------------------------------- ;;

;{1} Destructuring is an arbiter: it breaks up arguments
(= ":bar:foo"
  ((fn [[a b]] (str a b)) [:foo :bar]))

;{2} Whether in function definitions
(= (str "First comes love, " "then comes marriage, " "then comes Clojure with the baby carriage")
  ((fn [[a b c]]
    (str "First comes " a ", then comes " b ", " "then comes " c " with the baby carriage")) ["love" "marriage" "Clojure"]))

;{3} Or in let expressions
(= "Rich Hickey aka The Clojurer aka Go Time aka Macro Killah"
  (let [[first-name last-name & aliases] (list "Rich" "Hickey" "The Clojurer" "Go Time" "Macro Killah")]
    (str first-name " " last-name " aka " (nth aliases 0) " aka " (nth aliases 1) " aka " (nth aliases 2))))
    ; (str first-name " " last-name " aka " (clojure.string/join " aka " aliases))))
    ; (clojure.string/join " " (reduce conj [first-name last-name "aka"] (interpose "aka" aliases))

;{4} You can regain the full argument if you like arguing
(= {:original-parts ["Stephen" "Hawking"], :named-parts {:first "Stephen", :last "Hawking"}}
  (let [[first-name last-name :as full-name] ["Stephen" "Hawking"]]
    {:original-parts full-name, :named-parts {:first first-name, :last last-name}}))

;{5} Break up maps by key
(def test-address
  {:street-address "123 Test Lane"
   :city "Testerville"
   :state "TX"})

(= "123 Test Lane, Testerville, TX"
  (let [{street-address :street-address, city :city, state :state} test-address]
    (str street-address ", " city ", " state)))

;{6} Or more succinctly
(= "123 Test Lane, Testerville, TX"
  (let [{:keys [street-address city state]} test-address]
    (str street-address ", " city ", " state)))

;{7} All together now!
(= "Test Testerson, 123 Test Lane, Testerville, TX"
  ((fn [[first-name last-name] {:keys [street-address city state]}]
    (str first-name " " last-name ", " street-address ", " city ", " state)) ["Test" "Testerson"] test-address))



;; ---------------------- ;;
;; -------- Atom -------- ;;
;; ---------------------- ;;

(def atomic-clock (atom 0))

;{1} Atoms are references to values
(= 0
  (deref atomic-clock))

;{2} You can get its value more succintly
(= 0
  (@atomic-clok))

;{3} You can even change at the swap meet
(= 1
  (do (swap! atomic-clock inc) @atomic-clock))

;{4} Keep taxes out of this: swapping requires no transaction
(= 5
  (do (swap! atomic-clock #(+ 5 %)) @atomic-clock))

;{5} Any number of arguments might happen during a swap
(= 15
  (do (swap! atomic-clock + 1 2 3 4 5) @atomic-clock))

;{6} Atomic atoms are atomic
(= 0
  (do (compare-and-set! atomic-clock 100 :fin) @atomic-clock))

;{7} When your expectations are aligned with reality things, proceed that way
(= :fin
  (do (compare-and-set! atomic-clock 0 :fin) @atomic-clock))



;; --------------------------- ;;
;; -------- Partition -------- ;;
;; --------------------------- ;;

;{1} To split a collection you can use the partition function
(=  '((0 1) (2 3))
  (partition 2 (range 4)))

;{2} But watch out if there are not enough elements to form n sequences
(= '((:a :b :c))
  (partition 3 [:a :b :c :d :e]))

;{3} You can use partition-all to also get partitions with less than n elements
(= '((0 1 2) (3 4))
 (partion-all 3 (range 5)))

;{4} If you need to, you can start each sequence with an offset
(= '((0 1 2) (5 6 7) (10 11 12))
  (partition 3 5 (range 13)))

;{5} Consider padding the last sequence with some default values..
(= '((0 1 2) (3 4 5) (6 :hello))
  (partition 3 3 [:hello] (range 7)))

;{6} ..but notice that they will only pad up to given sequence length
(= '( (0 1 2) (3 4 5) (6 :this :are) )
  (partition 3 3 [:this :are "my" "words"] (range 7)))



;; ----------------------------------------- ;;
;; -------- Ref [non-clojurescript] -------- ;;
;; ----------------------------------------- ;;

(def the-world (ref "hello"))
(def bizarro-world (ref {}))

;{1} In the beginning, there was a word
(= "hello"
  (deref the-world))

;{2} You can get the word more succinctly, but it's the same
(= "hello" @the-world)

;{3} You can be the change you wish to see in the world.
(= "better"
  (do
    (dosync (ref-set the-world "better"))
    @the-world))

;{4} Alter where you need not replace
(= "better!!!"
  (let [exclamator (fn [x] (str x "!"))]
    (dosync
      (alter the-world exclamator)
      (alter the-world exclamator)
      (alter the-world exclamator))
      @the-world))

;{5} Don't forget to do your work in a transaction!
(= 0
  (do
    (dosync (ref-set the-world 0))
    @the-world))

;{6} Functions passed to alter may depend on the data in the ref
(= 20
  (do
    (dosync (alter the-world #(+ 20 %)))))

;{7} Two worlds are better than one
(= ["Real Jerry" "Bizarro Jerry"]
  (do
    (dosync
      (ref-set the-world {})
      (alter the-world assoc :jerry "Real Jerry")
      (alter bizarro-world assoc :jerry "Bizarro Jerry")
      [(:jerry @the-world) (:jerry @bizarro-world)])))



;; ----------------------------------------------- ;;
;; -------- Datatypes [non-clojurescript] -------- ;;
;; ----------------------------------------------- ;;

(defrecord Nobel [prize])

(deftype Pulitzer [prize])

(defprotocol Award (present [this recipient]))


;{1} Holding records is meaningful only when the record is worthy of you
(= "peace"
  (.prize (Nobel. "peace")))

;{2} Types are quite similar
(= "literature"
  (.prize (Pulitzer. "literature")))

;{3} Records may be treated like maps
(= "physics"
  (:prize (Nobel. "physics")))

;{4} While types may not
(= nil
  (:prize (Pulitzer. "poetry")))

;{5} Further study reveals why
(= '(true false)
  (map map? [(Nobel. "chemistry")
             (Pulitzer. "music")]))

;{6} Either sort of datatype can define methods in a protocol
(defrecord Oscar [category]
  Award
  (present [this recipient]
    (print (str "Congratulations on your "
                (:category this) " Oscar, "
                recipient
                "!"))))

(= "Congratulations on your Best Picture Oscar, Evil Alien Conquerors!"
  (with-out-str (present (Oscar. "Best Picture") "Evil Alien Conquerors")))

;{7} Surely we can implement our own by now
(defrecord Razzie [category]
  Award
  (present [this recipient]
    (print (str "You're really the "
                (:category this) ", "
                recipient
                "... sorry."))))

(= "You're really the Worst Picture, Final Destination 5... sorry."
  (with-out-str (present (Razzie. "Worst Picture") "Final Destination 5")))
