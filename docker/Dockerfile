ARG BASE_CONTAINER=perl:5.34
ARG NCPUS=4
FROM $BASE_CONTAINER as base

WORKDIR /pdl

# Set up HTTPS mirror.
ENV PERL_CPANM_OPT="-M https://cpan.metacpan.org/"

# Set up local::lib.
ENV PERL_LOCAL_LIB_ROOT=/pdl/local

ENV PATH="${PERL_LOCAL_LIB_ROOT}/bin${PATH:+:${PATH}}"
ENV PERL5LIB="${PERL_LOCAL_LIB_ROOT}/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
ENV PERL_MB_OPT="--install_base \"${PERL_LOCAL_LIB_ROOT}\""
ENV PERL_MM_OPT="INSTALL_BASE=${PERL_LOCAL_LIB_ROOT}"

FROM base as deps
RUN apt-get update \
	&& apt-get install --no-install-recommends -y \
		build-essential gfortran libgd-dev libhdf4-alt-dev libproj-dev \
		proj-bin libcfitsio-dev libreadline-dev libvpx-dev libgsl0-dev \
		netpbm libnetpbm10-dev

FROM deps as builder
COPY . /pdl/src
RUN cd /pdl/src && cpanm -nq \
	    Carp Devel::CheckLib ExtUtils::Depends ExtUtils::MakeMaker \
	    ExtUtils::ParseXS File::Path \
	&& cpanm -nq --installdeps . \
	&& cpanm --verbose --build-args -j${NCPUS} .

FROM deps as run
COPY --from=builder ${PERL_LOCAL_LIB_ROOT} ${PERL_LOCAL_LIB_ROOT}
# Download CPAN metadata for builds
RUN cpanm -nq strict
