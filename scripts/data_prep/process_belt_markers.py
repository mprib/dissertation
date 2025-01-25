# C:\Program Files (x86)\Vicon\Nexus2.8\SDK\Python for details of ViconNexus.py
# the above file has the methods vicon exposes


import ViconNexus
vicon = ViconNexus.ViconNexus()

print(vicon.GetSubjectNames()[0])

subjectName = str(vicon.GetSubjectNames()[0])

CountUnlabeled = vicon.GetUnlabeledCount()

vicon.CreateModelOutput(subjectName, "Left", "BeltSpeed",  ["Vel"], ["Velocity"])
vicon.CreateModelOutput(subjectName, "Right", "BeltSpeed",  ["Vel"], ["Velocity"])
#vicon.DisplayCommandHelp("SetModelOutputAtFrame")

vicon.CreateModeledMarker(subjectName, "LeftBeltSpeed")
vicon.CreateModeledMarker(subjectName, "RightBeltSpeed")



framerate = vicon.GetFrameRate()

y_vel = []
y_vel_frame = []

listSize = len(vicon.GetUnlabeled(1)[1])

LeftBeltSpeed = [[float(0)]*listSize, [False]*listSize]
RightBeltSpeed = [[float(0)]*listSize, [False]*listSize]

for traj in range(0,CountUnlabeled):
#for traj in range(0,30):
	#print(traj)
	unlabeled = vicon.GetUnlabeled(traj)
	
	x_traj = unlabeled[0]
	y_traj = unlabeled[1]
	z_traj = unlabeled[2]
	
	# print(y_traj)
	
	# get average x position
	x_nzero = []
	for frame in range(1,len(x_traj)):
		if x_traj[frame] != 0:
			x_nzero.append(x_traj[frame])
	
	if len(x_nzero) > 0:
		x_avg = sum(x_nzero)/len(x_nzero)
	else:
		x_avg = 0
	# print("Average X value is " + str(x_avg))
	
	# get average z position
	z_nzero = []
	for frame in range(1,len(z_traj)):
		if z_traj[frame] != 0:
			z_nzero.append(z_traj[frame])
	if len(z_nzero) > 0:
		z_avg = sum(z_nzero)/len(z_nzero)
	else:
		z_avg = 0
	# print("Average Z value is " + str(z_avg))	
	
	print("Length of y traj is " + str(len(y_traj)))
	for frame in range(2,len(y_traj)):
		# remember that these distances are measured in mm, so need to 
		# divide by 1000 below, and 4m == 400mm
		frame_velocity = ((y_traj[frame]-y_traj[frame-1])*framerate)/1000
		if x_avg > 400 and y_traj[frame] != 0 and y_traj[frame] < 900 and y_traj[frame] > -900 and frame_velocity > 0 and frame_velocity < 10:
			print("Left Belt Speed is " + str(frame_velocity))
			LeftBeltSpeed[0][frame] = float(frame_velocity)
			LeftBeltSpeed[1][frame] = True
		if x_avg < -400 and y_traj[frame] != 0 and y_traj[frame] < 900 and y_traj[frame] > -900  and frame_velocity > 0 and frame_velocity < 10:
			RightBeltSpeed[0][frame] = float(frame_velocity)
			RightBeltSpeed[1][frame] = True



vicon.SetModelOutput(subjectName, "Left", [LeftBeltSpeed[0]], LeftBeltSpeed[1])
vicon.SetModelOutput(subjectName, "Right", [RightBeltSpeed[0]], RightBeltSpeed[1])


# print("Type is ", type(LeftBeltSpeed[0][1]))

vicon.SetModelOutput(subjectName, "LeftBeltSpeed", [LeftBeltSpeed[0], [0]*listSize,[0]*listSize] , [True]*listSize)
vicon.SetModelOutput(subjectName, "RightBeltSpeed",[RightBeltSpeed[0], [0]*listSize,[0]*listSize], [True]*listSize)