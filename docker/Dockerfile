ARG BASE_CONTAINER=perl:stable
ARG NCPUS=4
FROM $BASE_CONTAINER AS base

WORKDIR /pdl

# Set up local::lib.
ENV PERL_LOCAL_LIB_ROOT=/pdl/local

ENV PATH="${PERL_LOCAL_LIB_ROOT}/bin${PATH:+:${PATH}}"
ENV PERL5LIB="${PERL_LOCAL_LIB_ROOT}/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
ENV PERL_MB_OPT="--install_base \"${PERL_LOCAL_LIB_ROOT}\""
ENV PERL_MM_OPT="INSTALL_BASE=${PERL_LOCAL_LIB_ROOT}"

FROM base AS deps
# non-free for e.g. pgplot5
RUN sed -i 's/Components: main/Components: main contrib non-free non-free-firmware/g' /etc/apt/sources.list.d/debian.sources \
	&& apt-get update \
	&& apt-get install --no-install-recommends -y \
		build-essential \
		libcfitsio-dev libreadline-dev libvpx-dev \
		netpbm libnetpbm-dev \
	&& rm -rf /var/lib/apt/lists/*

FROM deps AS builder
COPY . /pdl/src
RUN cd /pdl/src && (cpanm -nq \
	    Devel::CheckLib ExtUtils::MakeMaker \
	    ExtUtils::ParseXS File::Path File::Which \
	&& cpanm -nq --installdeps . \
	&& cpanm --verbose --build-args -j${NCPUS} . \
	) || ( cat ~/.cpanm/build.log && false )

FROM deps AS run
COPY --from=builder ${PERL_LOCAL_LIB_ROOT} ${PERL_LOCAL_LIB_ROOT}
# Download CPAN metadata for builds
RUN cpanm -nq strict
