FROM ros:indigo-ros-core

RUN apt-get update && \
    # install dependencies
    apt-get install -y git \
        blender \
        build-essential \
        python-dev \
        python3-dev \
        xvfb && \

    # install python3 version of rospkg, catkin-tools required by morse
    apt-get install -y python3-setuptools && \
    easy_install3 pip && \
    pip3 install rospkg catkin-tools && \

    # install ros packages necessary for testing
    apt-get install -y \
        ros-$ROS_DISTRO-navigation \
        ros-$ROS_DISTRO-gmapping \
        ros-$ROS_DISTRO-robot-state-publisher \
        ros-$ROS_DISTRO-pr2-common \
        ros-$ROS_DISTRO-pr2-controllers \
        ros-$ROS_DISTRO-pr2-mechanism \
        ros-$ROS_DISTRO-pr2-navigation \
        ros-$ROS_DISTRO-pr2-common-actions \
        ros-$ROS_DISTRO-pr2-teleop && \

    # fix for tuck-arms
    git clone https://github.com/harmishhk/pr2_common_actions.git -b indigo-devel /pr2_ws/src/pr2_common_actions && \
    bash -c "source /opt/ros/indigo/setup.bash && catkin_make -DCMAKE_INSTALL_PREFIX=/opt/ros/indigo -C /pr2_ws install" && \

    # clean-up
    rm -rf /catkin_ws /pr2_ws && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install morse from source
VOLUME /morse/src
COPY . /morse/src/
RUN mkdir -p /morse/build && \
    cd /morse/build && cmake ../src -DCMAKE_INSTALL_PREFIX=/morse && make install

# set-up morse
ENV MORSE_ROOT /morse
ENV PATH $PATH:/morse/bin
ENV HEADLESS true
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
CMD ["morse"]
