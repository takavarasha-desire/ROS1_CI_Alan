pipeline {
    agent any

    stages {
        stage('Build Docker image') {
            steps {
                sh '''
                    cd ~/simulation_ws/src
                    sudo docker build -f ros1_ci/Dockerfile -t tortoisebot-unit_tests .
                '''
            }
        }

        stage('Run Gazebo + test') {
            steps {
                sh 'xhost +local:root'
                sh 'sudo docker rm -f tortoisebot_test || true'

                sh '''
                    sudo docker run -d --name tortoisebot_test \
                      -e DISPLAY=$DISPLAY \
                      -e QT_X11_NO_MITSHM=1 \
                      -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
                      tortoisebot-unit_tests \
                      bash -lc '
                        source /opt/ros/noetic/setup.bash
                        cd /root/simulation_ws
                        source devel/setup.bash
                        roslaunch tortoisebot_gazebo tortoisebot_playground.launch
                      '
                '''

                sh 'sleep 30'

                sh '''
                    sudo docker exec tortoisebot_test bash -lc '
                        source /opt/ros/noetic/setup.bash
                        cd /root/simulation_ws
                        source devel/setup.bash
                        rostest tortoisebot_waypoints waypoints_test.test --reuse-master
                    '
                '''
            }

            post {
                always {
                    sh 'sudo docker stop tortoisebot_test || true'
                    sh 'sudo docker rm -f tortoisebot_test || true'
                }
            }
        }

        stage('Done') {
            steps {
                echo 'Pipeline completed'
            }
        }
    }
}