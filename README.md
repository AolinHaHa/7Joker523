SYMBOLIC PROGRAMMING FINAL PROJECT
TEAMMEMBER: Bowen Qiu, Aolin Yang
Game name: 7 Joker 5 2 3

#Introduction:
This is a traditional Chinese card game, as the name discribed, the decreasing order of cards is (7 joker 5 2 3 ace king queen jack 10 9 8 6 4). Also there are 3 score cards including 5, 10 and king where 5 has score of 5 but 10 and king has score of 10. 

#Evaluating:
Each round if any score card appearing on the cardpool, players are supposed to try win the round. The round-winner will have the score counted into their master score, and the final winner is the one who has higher master score. Dealer will offer new card to players after each round ended to make sure every round players has 5 cards on hand.

Composition: Flush - 3 of a kind - pair - single
Tie: compare suits, the decreasing order of suits is (spade heart club diamond red black)

#Tech used:
we used closure to create the shuffled deck, and using functional programming to check the card type(check if the cards are pairs or singles or flush). Also the algorithms that we used to comparing different sets of cards are based on the idea of member function. Moreover, this project is an great lisp object-oriented experience, we use it for creating player and dealer classes. 

#Functions:
##make-deck() 
	Make a deck and redefine the global parameter *deck*
##shuffle(deck)
	Shuffle the deck
##deal-to((d dealer) (p player))
	Deal card from dealer to any assigned player
##check-validate(cards)
	Check if the combination of cards is validate
##check-same-values(cards value)
	To check if all played cards have the same value
##get-largest-card (cards)
	Get the largest representing card
##play (player cardIndex)
	Frist parameter is the current player, and the cardIndex is the index of the chosen card. The function will return the length of card that player put, and the max-value card in the set. For instance:
	input: (show-hand human-player)
	output: ([10 of SPADE] [ACE of CLUB] [9 of HEART] [6 of SPADE] [QUEEN of DIAMOND])
	input: (play human-player '(1))
	output: (1 [10 of SPADE])
##check-straight(cards)
	Check if there is a flush
##start-game()
	Initial the game, dealer will give human-player and ai-player 5 cards
##offer-cards()
	Refill cards, dealer will give any player cards until they have total 5 cards on hand
##compare-value-isHumanWin (human-card ai-card)
	Return True if human-player beats ai-player based on card value
##is-tie(human-card ai-card)
	Return True if there is a tie based on card value
##compare-suit-isHumanWin (human-card ai-card)
	Return True if human-player beats ai-player based on card suit
##compare-isHumanWin (human-card ai-card)
	Return True if human's card is bigger than ai's card based on card value and suit
##give-point()
	add up card score to round-winner's master score
##end-game()
	End the game when dealer has no more cards 
##AI and run-game functions
	game-engine() - this function will let AI playing the game with the player
	widely-search ()
	search-for-counter() - let AI think smart
	


#Classes:
##player()
	attributes:
	1. hand
	2. score
	methods:
	1. new-hand() 
	2. give-card()
	3. show-hand()
	4. add-credit()
##dealers(players)

#Contributions:
Both of us edited the fundation code which is the card game system(deal, shuffle, make-deck etc). Bowen as the project lead, comes out the idea and also constructed the peojct, such as game-engine, card system and so on. Both of us are doing fairly amount of work and we all agreed and disscussed duties before work on the individual parts. Even we work on different functions but we still had a great communication regarding to the individual parts. 
##Bowen's individual approches: 
AI approches, check-validate(cards), check-same-values(cards value), get-largest-card(cards), play(player cardIndex). check-straight(cards), Merge the project and finish up the run-game code
##Aolin's individual approches:
changed player class, start-game(), offer-cards(), compare-value-isHumanWin (human-card ai-card), play(player cardIndex), player score functions,  compare-suit-isHumanWin (human-card ai-card), compare-isHumanWin (), give-point(), Wrote the READEME documentation file 