extends StaticBody

func interact():
	if GlobalFlags.game_grabbed:
		if GlobalFlags.game_paid_for:
			
			EndingManager.end_game("Ability to play HTRAGS 2 coming soon (Good Ending)")
		else:
			
			EndingManager.end_game("Sorry folks, California Prop 47 backs me up on this one")
	elif GlobalFlags.bad_ending:
		
		EndingManager.end_game("There's no point to life anymore (Bad Ending)")
	else:
		MessageManager.display_message("Gotta get this game first")
