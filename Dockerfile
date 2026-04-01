FROM osrf/ros:noetic-desktop-full

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV QT_X11_NO_MITSHM=1

SHELL ["/bin/bash", "-c"]

# Basic tools + ROS/Gazebo packages commonly needed by tortoisebot
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    ca-certificates \
    xauth \
    python3-pip \
    python3-rosdep \
    python3-catkin-tools \
    python3-osrf-pycommon \
    ros-noetic-gazebo-ros-pkgs \
    ros-noetic-gazebo-plugins \
    ros-noetic-joint-state-publisher \
    ros-noetic-robot-state-publisher \
    ros-noetic-xacro \
    ros-noetic-tf \
    ros-noetic-tf2 \
    ros-noetic-tf2-ros \
    ros-noetic-rviz \
 && rm -rf /var/lib/apt/lists/*

# Init rosdep
RUN rosdep init || true
RUN rosdep update

# Create catkin workspace
WORKDIR /root/simulation_ws
RUN mkdir -p /root/simulation_ws/src

# Copy tortoisebot repo and extra test packages
# IMPORTANT: these paths are relative to build context = ~/simulation_ws/src
COPY tortoisebot /root/simulation_ws/src/tortoisebot
COPY ros1_ci/tortoisebot_GTests/tortoisebot_msgs /root/simulation_ws/src/tortoisebot_msgs
COPY ros1_ci/tortoisebot_GTests/tortoisebot_waypoints /root/simulation_ws/src/tortoisebot_waypoints

# Install package dependencies from package.xml files
RUN source /opt/ros/noetic/setup.bash && \
    rosdep install --from-paths /root/simulation_ws/src --ignore-src -r -y --rosdistro noetic

# Build workspace
RUN source /opt/ros/noetic/setup.bash && \
    cd /root/simulation_ws && \
    catkin_make

# Auto-source ROS + workspace
RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc && \
    echo "source /root/simulation_ws/devel/setup.bash" >> /root/.bashrc

# Entrypoint
RUN echo '#!/bin/bash' > /ros_entrypoint.sh && \
    echo 'set -e' >> /ros_entrypoint.sh && \
    echo 'source /opt/ros/noetic/setup.bash' >> /ros_entrypoint.sh && \
    echo 'if [ -f /root/simulation_ws/devel/setup.bash ]; then source /root/simulation_ws/devel/setup.bash; fi' >> /ros_entrypoint.sh && \
    echo 'exec "$@"' >> /ros_entrypoint.sh && \
    chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]