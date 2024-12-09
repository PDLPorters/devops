ARG BASE_CONTAINER=perl:5.34
ARG NCPUS=4
FROM $BASE_CONTAINER as base

WORKDIR /pdl

# Set up local::lib.
ENV PERL_LOCAL_LIB_ROOT=/pdl/local

ENV PATH="${PERL_LOCAL_LIB_ROOT}/bin${PATH:+:${PATH}}"
ENV PERL5LIB="${PERL_LOCAL_LIB_ROOT}/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
ENV PERL_MB_OPT="--install_base \"${PERL_LOCAL_LIB_ROOT}\""
ENV PERL_MM_OPT="INSTALL_BASE=${PERL_LOCAL_LIB_ROOT}"

FROM base as deps
# non-free for e.g. pgplot5
RUN apt-get update \
	&& apt-get install -y software-properties-common \
	&& apt-add-repository non-free \
	&& apt-get update \
	&& apt-get install --no-install-recommends -y \
		build-essential gfortran \
		libcfitsio-dev libreadline-dev libvpx-dev \
		netpbm libnetpbm10-dev

FROM deps as builder
COPY . /pdl/src
RUN cd /pdl/src && (cpanm -nq \
	    Carp Devel::CheckLib ExtUtils::Depends ExtUtils::MakeMaker \
	    ExtUtils::F77 ExtUtils::ParseXS File::Path File::Which \
	&& cpanm -nq --installdeps . \
	&& cpanm --verbose --build-args -j${NCPUS} . \
	) || ( cat ~/.cpanm/build.log && false )

FROM deps as run
COPY --from=builder ${PERL_LOCAL_LIB_ROOT} ${PERL_LOCAL_LIB_ROOT}
# Download CPAN metadata for builds
RUN cpanm -nq strict
