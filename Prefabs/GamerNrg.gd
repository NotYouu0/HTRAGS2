extends RigidBody

func interact():
	MessageManager.display_message("Energy Restored")
	GlobalFlags.nrg_drank += 1
	
	GlobalStats.total_nrg_drank = GlobalFlags.nrg_drank
	
	$"../../../../../../Player".speed = 10
	$"../../../../../../Player".energy_restored = true
	$"../../../../../../Player".can_jump = true
	$"../../../../../../Player".can_sprint = true
	
	
	if GlobalFlags.nrg_drank == 21:
		MessageManager.display_message("Heart Attack!")
		$"../../../../../..".heart_attack()
	
	print(GlobalStats.total_nrg_drank)
	
	queue_free()
