# ROS1 CI - Jenkins

## Start Jenkins

### Open a terminal in the repository:

```bash
cd ~/simulation_ws/src/ros1_ci
chmod +x start_jenkins.sh
./start_jenkins.sh
```
### Open Jenkins webpage

After Jenkins starts, the webpage address is saved in:
```bash
~/jenkins__pid__url.txt
```
Print it with:
```
cat ~/jenkins__pid__url.txt
```
Open the Jenkins URL shown in that file.

## Login

### Use these credentials:
```
Username: desire_test

Password: test
```
## Observe the pipeline

After a Pull Request is accepted (merged), Jenkins should automatically start the configured job for this repository.

### In the Jenkins webpage:

- Open the job for ros1_ci
- Open the latest build
- Click Console Output

There you should be able to see:

- the Docker image being built
- the ROS1 TortoiseBot Gazebo simulation being launched
- the Waypoints tests being executed
- the build finishing successfully
