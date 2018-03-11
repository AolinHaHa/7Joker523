;;; This is the final project
;;; Author: Bowen Qiu, Aolin Yang

;;; Define card values
(defvar *cards* '(ace king queen jack 10 9 8 7 6 5 4 3 2))

;;; To show the cards played
(defparameter played-cards-show nil)

;;; Define whose turn it is
(defparameter turn 'p)

;;; A switch to end the game
(defparameter endg nil)

;;; Define card suits
(defvar *suits* '(heart diamond club spade))

;;; Define order lists
(defvar *value-order* '(7 joker 5 2 3 ace king queen jack 10 9 8 6 4))
(defvar *suit-order* '(spade heart club diamond red black))

;;; Define an empty deck first
(defparameter *deck* '())

;;; Create a card class
(defclass card()
               ((value
                 :accessor card-value
                 :initarg :value)
                (suit
                 :accessor card-suit
                 :initarg :suit)))

;;; A helper funtion for make-deck using recursion
(defun make-deck-helper(suits cards)
                (if (not (null cards))
                  (if (not (null suits))
                      (cons (make-instance 'card :value (car cards) :suit (car suits)) (make-deck-helper (cdr suits) cards))
                      (make-deck-helper *suits* (cdr cards)))
                  *deck*))

;;; Make a deck and redefine the global parameter *deck*
(defun make-deck()
  (defparameter *deck* nil)
  (defparameter *deck* (make-deck-helper *suits* *cards*)))

;;; Create a deck
(make-deck)
(push (make-instance 'card :value 'joker :suit 'red) *deck*)
(push (make-instance 'card :value 'joker :suit 'black) *deck*)

;;; Override the print-object method
(defmethod print-object((obj card) stream)
  (format stream "[~a of ~a]" (card-value obj) (card-suit obj)))

;;; Shuffle the deck
(defun shuffle(deck)
                (if (not (null deck))
                    (remove-duplicates (append deck (shuffle (remove (nth (random (length deck)) deck) deck))))
                  '()))

;;; Create a shuffled deck using closure
(defun new-deck ()
               (let ((cards (shuffle *deck*)))
                 (defun deal()
                   (if cards
                 (let ((card (car cards)))
                       (setf cards (cdr cards))
                   card)
                     nil))
                 (defun count-cards()
                   (length cards))
               (defun show-deck(&optional (x 1) (y t))
                 (loop for i from 0 to x
                       do(if y
                             (prin1 (nth i cards))
                           (prin1 (format nil "~s" (nth i cards))))))))

;;; Shuffle deck
(new-deck)

;;; Create a player class
(defclass player()
                ((hand
                  :accessor player-hand
                  :initarg :hand
                  :initform nil)
                 (score
                  :accessor player-score
                  :initarg :score
                  :initform 0)
                 ))
;;; New hand
(defmethod new-hand ((p player))
  (setf (player-hand p) nil))

;;; Give a card to a player
(defmethod give-card ((p player) (c card))
                (setf (player-hand p) (cons c (player-hand p))))

;;; Show all cards of a player
(defmethod show-hand ((p player))
                (loop for x in (player-hand p)
                    collect x))

;;; Define a dealer class
(defclass dealer(player)
                ((players
                  :accessor dealer-player
                  :initarg :players
                  :initform nil)))

;;; Make a human player and an AI player
(defparameter human-player (make-instance 'player))
(defparameter ai-player (make-instance 'player))

;;; Make a dealer
(defparameter poker-dealer (make-instance 'dealer :players (list human-player ai-player)))

;;; Deal a card to a player from the deck
(defmethod deal-to ((d dealer) (p player))
  (let ((card (deal)))
    (when card
      (give-card p card))))

;;; Define a variable to store played cards
(defparameter played-cards nil)

;;; To check if the combination of cards is validate
(defun check-validate(cards)
  (if (< (length cards) 5)
      (if (check-same-values cards (card-value (car cards)))
          (if (null played-cards)
              (setf played-cards (list (length cards) (get-largest-card cards)))
            (if (and (eq (car played-cards) (length cards))
                     (compare-ishumanwin (get-largest-card cards) (cadr played-cards)))
                (setf played-cards (list (length cards) (get-largest-card cards)))
              nil))
           nil)
    (if (check-straight cards)
         (if (null played-cards)
              (setf played-cards (list (length cards) (get-largest-card cards)))
            (if (and (eq (car played-cards) (length cards))
                     (compare-ishumanwin (get-largest-card cards) (cadr played-cards)))
                (setf played-cards (list (length cards) (get-largest-card cards)))
              nil))
      nil)))

;;; To check if all played cards have the same value
(defun check-same-values(cards value)
               (if cards
                 (if (equal value (card-value (car cards)))
                     (check-same-values (cdr cards) (card-value (car cards)))
                   nil)
                 t))

;;; To check if a combination is a straight
(defun check-straight(cards)
               (let ((value-list
                       (loop for i in cards
                           collect (card-value i))))
                 (when (member 'ace value-list)
                   (setf value-list (remove 'ace value-list))
                   (push 1 value-list))
                 (when (member 'king value-list)
                   (setf value-list (remove 'king value-list))
                   (push 13 value-list))
                 (when (member 'queen value-list)
                   (setf value-list (remove 'queen value-list))
                   (push 12 value-list))
                 (when (member 'jack value-list)
                   (setf value-list (remove 'jack value-list))
                   (push 11 value-list))
                 (if (every #'numberp value-list)
                     (progn
                       (setf value-list
                         (sort value-list #'<))
                       (if (and 
                            (eq 5 (length (remove-duplicates value-list)))
                            (= 4 (- (nth 4 value-list) (nth 0 value-list))))
                           t
                         nil))
                   nil)))

;;; Get the largest representing card
(defun get-largest-card (cards)
               (let ((largest-card (car cards)))
                 (loop for card in cards
                       do(when (compare-ishumanwin card largest-card)
                           (setf largest-card card)))
                 largest-card))

;;; Play cards
(defun play (p c)
  (if c 
      (if (or (> (length c) 5) (some #'< (list (length (player-hand p))) c)) 
          (progn
                (princ "Invalid cards!")
                (print "Cards in hand")
                  (if (equal turn 'p)
                        (player-hand human-player)
                      (player-hand ai-player)))        
        (let ((latent-cards               
               (loop for i in c                    
                     collect(nth (1- i) (player-hand p)))))
          (let ((played-list (check-validate latent-cards)))
            (if played-list
                (progn
                  (setf played-cards-show latent-cards)
                (let ((temp latent-cards))
                  (setf cardpool (append cardpool latent-cards))
                  (loop for a in temp
                        do (delete a (player-hand p)))
                  (when (member 1 c)
                    (setf (player-hand p) (remove (car (player-hand p)) (player-hand p))))
                  (setf played-cards played-list))
                  (if (equal turn 'p)
                        (setf turn 'a)
                    (progn
                      (setf turn 'p)
                      (print "Cards in hand")
                      (print (player-hand human-player)))))
              (progn
                (princ "Invalid cards!")
                (when (equal turn 'p)
                      (print "Cards in hand")
                        (print (player-hand human-player))))))))
    (progn 
      (if (equal turn 'p)
          (progn
            (setf turn 'a)
            (give-point ai-player))
        (progn
          (setf turn 'p)
          (give-point human-player)))
      (setf cardpool '())
      (setf played-cards '())
      (offer-cards)
      (print "Score of player")
      (print (player-score human-player))
      (print "Score of AI")
      (print (player-score ai-player))
      ))
  (when played-cards
  (if (equal turn 'a)
      (print "You played: ")
    (print "AI played: "))
  (print played-cards-show)))

;;; Initial game
(defun start-game ()
  (loop
    for i from 1 to 5
    do (deal-to poker-dealer human-player)
    do (deal-to poker-dealer ai-player)
    )
  (print (player-hand human-player))
  (game-engine)
  )


;;;initial card-pool
(defparameter cardPool '())

;;; Offer cards after any round
(defun offer-cards ()
  (loop
    for i from 1 to (- 5 (list-length (show-hand human-player)))
    do (deal-to poker-dealer human-player))
  (print "Player's hand")
  (print (player-hand human-player))
  (loop
    for i from 1 to (- 5 (list-length (show-hand ai-player)))
    do (deal-to poker-dealer ai-player)
    )
  (setf played-cards-show nil)
  (when (equal turn 'p)
      (print "AI passed!"))
  (when (or (< (length (player-hand human-player)) 5) (< (length (player-hand ai-player)) 5))
    (end-game)))

;;;compare value. return true if human-card value is bigger
(defun compare-value-isHumanWin (human-card ai-card)
  (if (member (card-value human-card) (member (card-value ai-card) *value-order*))
      Nil
    0))

;;;compare suit, return true if human-card suit is bigger
(defun compare-suit-isHumanWin (human-card ai-card)
  (if (member (card-suit human-card) (member (card-suit ai-card) *suit-order*))
      Nil
    0))

;;;check tie, return true if two cards has tie value
(defun is-tie (human-card ai-card)
  (if (equal (card-value human-card) (card-value ai-card))
      0
    Nil))


;;;compare cards return true if players card beats ai's card
(defun compare-isHumanWin (human-card ai-card)
  (if (compare-value-isHumanWin human-card ai-card)
      t
    (if (and (is-tie human-card ai-card) (compare-suit-isHumanWin human-card ai-card))
        t
      nil)))

;;; add credit to player
(defmethod add-credit ((p player) credit)
  (setf (player-score p) (+ credit (player-score p))))

;;;giving score to ruond winner
(defun give-point (player)
  (loop
    for item in cardPool
    do(if (or (equal (card-value item) 'king)
              (equal (card-value item) '10))
          (add-credit player 10)
        (when (equal (card-value item) '5)
            (add-credit player 5)
          )
        )))

;;; End the game when cards are all drawn
(defun end-game()
  (setf endg t)
  (setf cardpool (player-hand human-player))
  (give-point ai-player)
  (setf cardpool (player-hand ai-player))
  (give-point human-player)
  (cond ((> (player-score human-player) (player-score ai-player))
         (princ "You Win!"))
        ((= (player-score human-player) (player-score ai-player))
         (princ "It is a tie game"))
        ((< (player-score human-player) (player-score ai-player))
         (princ "You Lose!"))))

(defun game-engine()
  (print "Cards left")
  (print (count-cards))
  (if endg
      nil
  (if (equal turn 'p)
      (progn
        (print "Player's turn")
        (let ((input-comm (read-line)))
          (when (equal input-comm "pass")
              (setf input-comm nil))
          (let ((comm
                 (read-from-string
                 (concatenate 'string "(play human-player" " '(" input-comm "))"))))
            (eval comm)))
        (game-engine))
    ;;; Call ai player to play automatically
    (progn
        (search-for-counter)
        (game-engine))
    )))
          
;;; AI part
(defun search-for-counter()
  (if (null played-cards)
      (let ((start-list nil))
        (loop for i from 0 to 4
            do (if (widely-search i 2)
                   (setf start-list (widely-search i 2))))
        (if start-list
            (play ai-player start-list)
          (play ai-player '(5))))
  (if (< (length (player-hand ai-player)) (car played-cards))
      (play ai-player '())
    (progn
      (let ((counter-list nil))
        (if (< (car played-cards) 5)
            (progn
            (loop for i from 0 to (1- (length (player-hand ai-player)))
                do (when (compare-ishumanwin (nth i (player-hand ai-player)) (cadr played-cards))
                     (push i counter-list)))
              (if (null counter-list)
                  (play ai-player '())
                    (progn
                      (setf counter-list (search-helper counter-list (car played-cards)))
                      (if (null counter-list)
                          (play ai-player '())
                        (play ai-player counter-list))
                    )
              ))
          (if (and (check-straight (player-hand ai-player))
                   (compare-ishumanwin (get-largest-card (player-hand ai-player))
                                       (get-largest-card (cadr played-cards))))
              (play ai-player '(1 2 3 4 5))
            (play ai-player '()))))))))
                       
;;; Helper function
(defun search-helper (counter-list n )
  (let ((temp-list nil))
    (loop for i in counter-list
          do(setf temp-list (widely-search i n)))
    temp-list))

;;; Widely search
(defun widely-search (i n)
  (let ((temp-list (list i)))
    (loop for a from 0 to (1- (length (player-hand ai-player)))
        do (if (and (< (length temp-list) n)
                    (equal (card-value (nth a (player-hand ai-player)))
                           (card-value (nth i (player-hand ai-player))))
                    (not (equal (card-suit (nth a (player-hand ai-player)))
                                (card-suit (nth i (player-hand ai-player))))))
               (push a temp-list)))
    (let ((return-list nil))
      (loop for b in temp-list
          do (push (1+ b) return-list))
      (setf temp-list return-list))
    (if (equal (length temp-list) n)
        temp-list
      nil)))