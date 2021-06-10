FROM ubuntu:18.04

################################## JUPYTERLAB ##################################

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8


RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -yq dist-upgrade \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
	locales cmake git build-essential sudo \
    python-pip \
	python3-pip python3-setuptools \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools \
 && python3 -m pip install jupyterlab==3.0.9 bash_kernel  \
 && python3 -m bash_kernel.install

ENV SHELL=/bin/bash \
	NB_USER=rapyuta \
	NB_UID=1000 \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8

ENV HOME=/home/${NB_USER}

RUN adduser --disabled-password \
	--gecos "Default user" \
	--uid ${NB_UID} \
	${NB_USER} && usermod -aG sudo ${NB_USER}

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token=''"]


###################################### ROS #####################################

# install packages
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -o Acquire::ForceIPv4=true install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -o Acquire::ForceIPv4=true install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    python-catkin-tools \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
ENV ROS_DISTRO melodic
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -o Acquire::ForceIPv4=true install -y \
    ros-melodic-ros-base=1.4.1-0* \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/rapyuta/.ros
RUN chown rapyuta.rapyuta /home/rapyuta/.ros

##################################### APT ######################################

RUN apt-get -o Acquire::ForceIPv4=true update \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
    ros-melodic-joy  \
    ros-melodic-teleop-twist-joy \
    ros-melodic-teleop-twist-keyboard \
    ros-melodic-laser-proc \
    ros-melodic-rgbd-launch \
    ros-melodic-depthimage-to-laserscan \
    ros-melodic-rosserial-arduino \
    ros-melodic-rosserial-python \
    ros-melodic-rosserial-server \
    ros-melodic-rosserial-client \
    ros-melodic-rosserial-msgs \
    ros-melodic-amcl \
    ros-melodic-map-server \
    ros-melodic-move-base \
    ros-melodic-urdf \
    ros-melodic-xacro \
    ros-melodic-compressed-image-transport \
    ros-melodic-rqt-image-view \
    ros-melodic-gmapping \
    ros-melodic-navigation \
    ros-melodic-interactive-markers \
    ros-melodic-turtlebot3-msgs \
    ros-melodic-turtlebot3 \
    ros-melodic-turtlebot3-gazebo \
    ros-melodic-turtlesim \ 
    git python-pip python-dev libgtk2.0-0 unzip libblas-dev liblapack-dev libhdf5-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*



##################################### COPY #####################################
## Add all install scripts for further steps
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

## Envrionment config
ENV VNCPASSWD=vncpassword
ENV HOME=/home/$USER \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/home/$USER/install \
    NO_VNC_HOME=/home/$USER/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1920x1080 \
    VNC_PW=$VNCPASSWD \
    VNC_VIEW_ONLY=false

ADD ./src/common/install/ $INST_SCRIPTS/
ADD ./src/ubuntu/install/ $INST_SCRIPTS/
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

## Install some common tools
RUN $INST_SCRIPTS/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

## Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc.sh

## Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./src/common/xfce/ $HOME/


## configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME



RUN rm -rf /var/lib/apt/lists/* \
 && apt-get -o Acquire::ForceIPv4=true update \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
    xvfb x11-utils openssh-server\
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN echo 'export NOTVISIBLE="in users profile"' >> ~/.bashrc
RUN echo "export VISIBLE=now" >> /etc/profile

#################################### CATKIN ####################################


RUN mkdir -p ${HOME}/catkin_ws/src && cd ${HOME}/catkin_ws/src && git clone https://github.com/rapyuta-robotics/io_tutorials.git

RUN  cd ${HOME}/catkin_ws \
 && apt-get -o Acquire::ForceIPv4=true update \
 && /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && rosdep update && rosdep install --as-root apt:false --from-paths src --ignore-src -r -y" \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends ipython python-rospkg nginx\
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && catkin build"


################################### CUSTOM #####################################

RUN python2 -m pip install wheel ipykernel 
RUN python2 -m pip install rospkg
RUN python2 -m ipykernel install --user

WORKDIR  ${HOME}/catkin_ws/src/io_tutorials/io_turtlesim/io_turtlesim_webserver/ 
RUN cp ./nginx.conf /etc/nginx/nginx.conf 
RUN cp ./site.conf /etc/nginx/conf.d/default.conf 
RUN chmod -R g+w /var/log/nginx 

RUN cp ./env.sh /usr/bin/
RUN cp -rf ./src/* /usr/share/nginx/html/


##################################### TAIL #####################################
# setup entrypoint
RUN mkdir -p ${HOME}/.lib
COPY --chown=1000:1000 . ${HOME}/.lib

COPY ./ros_entrypoint.sh /
RUN chmod a+x /ros_entrypoint.sh


ENTRYPOINT ["/ros_entrypoint.sh"]

RUN chown ${NB_UID} ${HOME}/.lib
RUN chown -R ${NB_USER} ${HOME}/
RUN echo "root:toor" | chpasswd
RUN echo "${NB_USER}:robotics" | chpasswd


COPY ./start.sh /
COPY ./run-turtle.sh /home/catkin_ws/
RUN chmod a+x /start.sh
RUN chmod a+x /home/catkin_ws/run-turtle.sh

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers

USER ${NB_USER}
ENV WS_ENV_PORT=9090
RUN echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
RUN echo "export PYTHONPATH=$PYTHONPATH:/usr/lib/python2.7/dist-packages" >> ~/.bashrc
RUN echo "source ~/catkin_ws/devel/setup.bash" >> ${HOME}/.bashrc


EXPOSE 6901
EXPOSE 22
EXPOSE 8080
EXPOSE 9090

WORKDIR ${HOME}/catkin_ws
CMD ["bash", "-c", "/start.sh && ./run-turtle.sh  &&  jupyter lab --no-browser --ip=0.0.0.0 --NotebookApp.token=''"]
