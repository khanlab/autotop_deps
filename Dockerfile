FROM continuumio/miniconda3:4.8.2

MAINTAINER alik@robarts.ca

#dependencies for hippocampal autotop
# note: this installs minified versions of fsl and ants to save space.. 

RUN apt-get update && mkdir -p /usr/share/man/man1  &&  apt-get install -y curl tree unzip bc default-jre libgomp1 cmake cmake-curses-gui libpng-dev zlib1g-dev build-essential wget bzip2 ca-certificates gnupg2 squashfs-tools git graphviz-dev && \
mkdir -p /opt/niftyreg-1.3.9/src && \
  echo "Downloading http://sourceforge.net/projects/niftyreg/files/nifty_reg-${NIFTY_VER}/nifty_reg-${NIFTY_VER}.tar.gz/download" && \
  curl -L http://sourceforge.net/projects/niftyreg/files/nifty_reg-1.3.9/nifty_reg-1.3.9.tar.gz/download \
    | tar xz -C /opt/niftyreg-1.3.9/src --strip-components 1 && \
cd /opt/niftyreg-1.3.9  && \
cmake /opt/niftyreg-1.3.9/src \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -DCMAKE_INSTALL_PREFIX=/opt/niftyreg-1.3.9  && \
  make && \
  make install && rm -rf /opt/niftyreg-1.3.9/src && \
mkdir -p /opt && cd /opt && wget -q https://www.humanconnectome.org/storage/app/media/workbench/workbench-linux64-v1.5.0.zip && unzip workbench-linux64-v1.5.0.zip && rm workbench-linux64-v1.5.0.zip && cd /  && \
mkdir -p /opt/ants-2.3.1 && curl -fsSL --retry 5 https://dl.dropbox.com/s/1xfhydsf4t4qoxg/ants-Linux-centos6_x86_64-v2.3.1.tar.gz \
| tar -xz -C /opt/ants-2.3.1 --strip-components 1 && \
mkdir /opt/ants-2.3.1-minify && for bin in antsRegistration antsApplyTransforms N4BiasFieldCorrection ComposeMultiTransform; do mv /opt/ants-2.3.1/${bin} /opt/ants-2.3.1-minify; done  && \
rm -rf /opt/ants-2.3.1  && \
mkdir -p /opt/fsl-5.0.11 && curl -fsSL --retry 5 https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-5.0.11-centos6_64.tar.gz \
| tar -xz -C /opt/fsl-5.0.11 --strip-components 1 && \
mkdir /opt/fsl-5.0.11/bin-minify && for bin in flirt fslmaths fslreorient2std fslroi fslstats; do mv /opt/fsl-5.0.11/bin/${bin} /opt/fsl-5.0.11/bin-minify; done && \
rm -rf /opt/fsl-5.0.11/bin && rm -rf /opt/fsl-5.0.11/data /opt/fsl-5.0.11/extras /opt/fsl-5.0.11/lib /opt/fsl-5.0.11/src /opt/fsl-5.0.11/doc && \
wget -O itksnap.tar.gz 'https://sourceforge.net/projects/itk-snap/files/itk-snap/Nightly/itksnap-nightly-master-Linux-gcc64-qt4.tar.gz/download' \
\
&& tar -zxf itksnap.tar.gz -C /opt/ \
&& mv /opt/itksnap-*/ /opt/itksnap/ \
&& rm itksnap.tar.gz

ENV LD_LIBRARY_PATH=/opt/itksnap/lib/:/opt/niftyreg-1.3.9/lib:/opt/workbench/libs_linux64:/opt/workbench/libs_linux64_software_opengl:${LD_LIBRARY_PATH}
ENV PATH /opt/conda/bin:/opt/itksnap/bin/:/opt/niftyreg-1.3.9/bin:/opt/workbench/bin_linux64:/opt/ants-2.3.1-minify:/opt/fsl-5.0.11/bin-minify:$PATH

ENV FSLDIR "/opt/fsl-5.0.11"
ENV FSLOUTPUTTYPE NIFTI_GZ
ENV FSLMULTIFILEQUIT TRUE


