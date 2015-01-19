/*
  This is a little adventure game.  There are three
  entities: you, a treasure, and an ogre.  There are
  six places: a valley, a path, a cliff, a fork, a maze,
  and a mountaintop.  Your goal is to get the treasure
  without being killed first.
*/

/*
  First, text descriptions of all the places in
  the game.
*/
description(valley,
  'You are in a pleasant valley, with a trail ahead.').
description(path,
  'You are on a path, with ravines on both sides.').
description(cliff,
  'You are teetering on the edge of a cliff.').
description(maze(1),
  'You are in a maze of twisty trails, all alike.').
description(fork,
  'You are at a fork in the path.').
description(maze(_),
  'You are in a maze of twisty trails, all alike.').
description(mountaintop,
  'You are on the mountaintop.').
description(dog,
  'a hungry-looking dog.\n').
description(gate,
  'an imposing gate.\n').
description(meat,
  'a hunk of raw, red meat. You do not want to know where it came from...\n').
description(sword,
  'a brilliant sword, just lying there...\n').
description(key,
  'a gold key chased with silver and etched with carvings. \n').
description(ogre,
  'a hideous-looking ogre. \n').
description(treasure,
  'many chests with treasure and gold heaped on them\n').


/*
  report prints the description of your current
  location.
*/
report :-
  at(you,X),
  description(X,Y),
  write(Y), nl.

itemReport:-
  at(you,X),
  at(Y,X),
  description(Y,Z),
  write('You see...'),
  write(Z),
  nl,
  fail.


/*
  These connect predicates establish the map.
  The meaning of connect(X,Dir,Y) is that if you
  are at X and you move in direction Dir, you
  get to Y.  Recognized directions are
  forward, right, and left.
*/
connect(valley,forward,path).
connect(path,right,cliff).
connect(path,left,cliff).
connect(path,forward,fork).
connect(path, back, valley).
connect(fork,left,maze(0)).
connect(fork,right,mountaintop).
connect(mountaintop,left,fork).
connect(fork, back, path).
connect(maze(0),left,maze(1)).
connect(maze(0),right,maze(3)).
connect(maze(0),back, fork).
connect(maze(1),left,maze(0)).
connect(maze(1),right,maze(2)).
connect(maze(2),left,fork).
connect(maze(2),right,maze(0)).
connect(maze(3),left,maze(0)).
connect(maze(3),right,maze(3)).

lookaround :-
  at(you,_Loc),
  itemReport,
  report,
  !.
/*
  move(Dir) moves you in direction Dir, then
  prints the description of your new location.
*/
move(Dir) :-
  at(you,Loc),
  connect(Loc,Dir,Next),
  retract(at(you,Loc)),
  assert(at(you,Next)),
  report,
  !.
/*
  But if the argument was not a legal direction,
  print an error message and don't move.
*/
move(_) :-
  write('That is not a legal move.\n'),
  report.
/*
  Shorthand for moves.
*/
forward :- move(forward).
left :- move(left).
right :- move(right).
back :- move(back).



/*
  If you and the ogre are at the same place, it
  kills you.
*/

ogre :-
  at(sword,you),
  at(ogre,Loc),
  at(you,Loc),
  write('You manage to hide away before the ogre sees you.\nBut what is that glittering in the corner?\n'),
  write('You will have to kill the ogre to find out.'),
  !.

ogre :-
  at(ogre,Loc),
  at(you,Loc),
  write('An ogre sucks your brain out through\n'),
  write('your eye sockets, and you die.\n'),
  retract(at(you,Loc)),
  assert(at(you,done)),
  !.

/*
  But if you and the ogre are not in the same place,
  nothing happens.
*/
ogre.

/*
  If you and the treasure are at the same place, you
  win.
*/
treasure :-
  at(treasure,Loc),
  at(you,Loc),
  write('There is a treasure here.\n'),
  write('Congratulations, you win!\n'),
  retract(at(you,Loc)),
  assert(at(you,done)),
  !.
/*
  But if you and the treasure are not in the same
  place, nothing happens.
*/
treasure.


/*
  If you are at the cliff, you fall off and die.
*/
cliff :-
  at(you,cliff),
  write('You fall off and die.\n'),
  retract(at(you,cliff)),
  assert(at(you,done)),
  !.
/*
  But if you are not at the cliff nothing happens.
*/
cliff.


gate :-
	at(you,Loc),
	at(gate,Loc),
	at(gate,locked),
	write('The gate is barred to you. You will need a key.\n'),
	!.

gate :-
	at(you,Loc),
	at(gate,Loc),
	at(gate,unlocked),
	write('The gate has been opened! What are you waiting for, pass through!\n'),
	!.

gate.



inventory :-
    write('You have:\n'),
    at(X,you),
    write(X),
    nl,
    fail.


/*********ACTIONS***********/

pet(dog) :-
	at(you,Loc),
	at(fedDog,Loc),
	write('The dog wags her tail as you pet her, delighted to see you!\n'),
	!.


pet(dog) :-
	at(you,Loc),
	at(dog,Loc),
	write('The dog shies away from you as you reach out to pet her.\n'),
	!.


pet(_) :-
	write('Why would you do that?\n').

pickup(dog) :-
	at(you,Loc),
	at(dog,Loc),
	write('The dog cannot be picked up. You silly!\n'),
	!.

pickup(X) :-
	at(you,Loc),
	at(X,Loc),
	write('You picked the '),
	write(X),
	write(' up.\n'),
	retract(at(X,Loc)),
	assert(at(X,you)),
	report,
	!.


pickup(X) :-
	at(you,Loc),
	at(X,Loc),
	at(X,you),
	write('You already have it.'),
	nl,
	!.


pickup(_) :-
	write('There is nothing to take.\n').


drop(X) :-
	at(you,Loc),
	at(X,you),
	write('You dropped the '),
	write(X),
	retract(at(X,you)),
	assert(at(X,Loc)),
	nl,
	report,
	!.

drop(_) :-
	write('There is nothing to drop.\n').

use(sword) :-
	at(you,Loc),
	at(ogre,Loc),
        at(sword,you),
	retract(at(ogre,Loc)),
	write('You charge at the ogre with your sword and kill him!\n'),
	assert(at(key,Loc)),
	report,
	!.


use(sword) :-
	at(you,Loc),
	at(dog,Loc),
	at(sword,you),
	retract(at(dog,Loc)),	write('You hit the poor dog with your sword and she dies instantly.\nDo you feel better now? :C\n'),
	report,
	!.

use(sword) :-
	at(you,Loc),
	at(gate,Loc),
	at(sword,you),
	write('You swing at the gate with your sword but nothing happens.\nYou need to find the key.\n'),
	report,
	!.

use(key) :-
	at(you,Loc),
	at(gate,Loc),
	at(key,you),
	write('You have unlocked the gate. Congratulations.\n'),
	write('Beyond the gate is a portal. Dare you pass through?\n'),
	retract(at(gate,locked)),
	assert(at(gate,unlocked)),
	report,
	!.

use(key) :-
	at(you,Loc),
	at(gate,Loc),
	at(gate,locked),
	write('You do not have a key to open the gate with.\n'),
	report,
	!.

use(key) :-
	at(you,Loc),
	at(gate,Loc),
	at(gate,unlocked),
	write('You have already opened the gate.\n'),
	report,
	!.


use(meat) :-
	at(you,Loc),
	at(dog,Loc),
	at(meat,you),
        retract(at(meat,you)),
	assert(at(fedDog,Loc)),
	write('The dog quickly eats up the meat you toss to her and then woofs at you happily.\nShe wags her tail.\n'),
	report,
	!.



use(_) :-
	write('That isnt going to work!\n'),
	!.

passthrough :-
	at(gate, unlocked),
	at(key,you),
	at(you,Loc),
	write('You failed to drop the key. A pack of ghosts burst out of ground \nand drag you into the cold earth before you get two feet.'),
	retract(at(you,Loc)),
	assert(at(you,done)),
	!.

passthrough :-
    at(gate,unlocked),
	at(you,Loc),
	at(gate,Loc),
	write('You pass through the gate.'),
    retract(at(you,Loc)),
	assert(at(you,mountaintop(1))),
	!.



/*  Main loop.  Stop if player won or lost.
*/

main :-
  at(you,done),
  write('Thanks for playing.\n'),
  !.
/*
  Main loop.  Not done, so get a move from the user
  and make it.  Then run all our special behaviors.
  Then repeat.
*/
main :-
  write('\nNext move -- '),
  read(Move),
  call(Move),
  ogre,
  treasure,
  cliff,
  main.

/*
  This is the starting point for the game.  We
  assert the initial conditions, print an initial
  report, then start the main loop.
*/
go :-
  retractall(at(_,_)), % clean up from previous runs
  assert(at(you,valley)),
  assert(at(ogre,maze(3))),
  assert(at(gate,mountaintop)),
  assert(at(treasure, mountaintop(1))),
  assert(at(dog,maze(1))),
  assert(at(meat,fork)),
  assert(at(sword,path)),
  assert(at(gate,locked)),
  write('This is an adventure game. \n'),
  write('Legal moves are left, right, back or forward.\n'),
  write('You can check your inventory with the keyphrase inventory\n'),
  write('And look around with the keyphrase lookaround\n'),
  write('Other moves are pet(item), pickup(item), use(item), passthrough, and drop(item)\n'),
  write('End each move with a period.\n\n'),
  report,
  main.

/*
  ***************TODO*********************
Everything is done except for picking up something I already have, it seems....

  ****************************************
  */
